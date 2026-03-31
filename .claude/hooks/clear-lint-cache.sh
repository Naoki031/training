#!/bin/bash
# PostToolUse(Edit|Write) — invalidate lint sentinel when source files change
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if echo "$FILE" | grep -qE "\.(ts|vue)$"; then
  rm -f /tmp/claude-attendance-lint-ok
fi
exit 0
