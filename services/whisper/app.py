import os
import subprocess
import tempfile
from faster_whisper import WhisperModel
from flask import Flask, request, jsonify

app = Flask(__name__)

MODEL_SIZE = os.environ.get('WHISPER_MODEL', 'small')
model = WhisperModel(MODEL_SIZE, device='cpu', compute_type='int8')


def convert_to_wav(input_path: str) -> str:
    """Convert any audio format to 16kHz mono WAV using ffmpeg.

    Whisper performs best on 16kHz mono PCM — avoids ffmpeg decode artifacts
    that occur when reading WebM/Opus directly.
    """
    output_path = input_path.replace('.webm', '.wav')
    result = subprocess.run(
        [
            'ffmpeg', '-y',
            '-i', input_path,
            '-ar', '16000',   # resample to 16kHz
            '-ac', '1',       # mono
            '-f', 'wav',
            output_path,
        ],
        capture_output=True,
    )
    if result.returncode != 0:
        # Fallback: return original if conversion fails
        return input_path
    return output_path


@app.post('/transcribe')
def transcribe():
    audio_bytes = request.data
    if not audio_bytes:
        return jsonify({'error': 'No audio data provided'}), 400

    language_hint = request.args.get('language') or None
    is_screen_audio = request.args.get('screen_audio') == '1'

    wav_path = None
    with tempfile.NamedTemporaryFile(suffix='.webm', delete=False) as tmp_file:
        tmp_file.write(audio_bytes)
        webm_path = tmp_file.name

    try:
        # Convert to clean 16kHz WAV before transcribing
        wav_path = convert_to_wav(webm_path)

        kwargs = dict(
            beam_size=5,
            language=language_hint,      # None = auto-detect
            vad_filter=True,
            vad_parameters={
                'min_silence_duration_ms': 300 if is_screen_audio else 500,
                'speech_pad_ms': 200,    # pad around speech to avoid cutting off words
                'threshold': 0.5,        # VAD sensitivity — higher = stricter, less noise triggers
            },
            temperature=0.0,             # deterministic output
            condition_on_previous_text=False,  # each chunk is independent

            # Anti-hallucination: reject low-confidence segments
            # no_speech_threshold: if P(no speech) > this → return empty (default 0.6)
            # medium model is more accurate, 0.6 is sufficient
            no_speech_threshold=0.6,
            # log_prob_threshold: avg log-prob below this → treat as failed transcription (default -1.0)
            # medium model produces better log-probs, -0.8 balances safety vs recall
            log_prob_threshold=-0.8,
            # compression_ratio_threshold: zlib ratio above this → likely repetitive hallucination
            # default is 2.4; 2.0 catches loops while allowing normal repeated words
            compression_ratio_threshold=2.0,
        )

        if is_screen_audio:
            kwargs['condition_on_previous_text'] = True
            kwargs['initial_prompt'] = 'This is a video or presentation with clear narration.'
            # Screen audio from videos is higher quality — can relax no_speech_threshold slightly
            kwargs['no_speech_threshold'] = 0.6

        segments, info = model.transcribe(wav_path, **kwargs)
        text = ' '.join(segment.text for segment in segments).strip()
        return jsonify({'text': text, 'language': info.language})

    finally:
        try:
            os.unlink(webm_path)
        except OSError:
            pass
        if wav_path and wav_path != webm_path:
            try:
                os.unlink(wav_path)
            except OSError:
                pass


@app.get('/health')
def health():
    return jsonify({'status': 'ok', 'model': MODEL_SIZE})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=False)
