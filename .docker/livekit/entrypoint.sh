#!/bin/sh
set -e

RUNTIME_CFG=/tmp/livekit-runtime.yaml

# Compose LIVEKIT_KEYS from individual key/secret (env_file provides them separately)
export LIVEKIT_KEYS="${LIVEKIT_API_KEY:-devkey}: ${LIVEKIT_API_SECRET:-devsecret}"

# Inject TURN credentials (LiveKit yaml has no native env var support)
sed \
  -e "s|PLACEHOLDER_TURN_HOST|${LIVEKIT_TURN_HOST:-127.0.0.1}|g" \
  -e "s|PLACEHOLDER_TURN_USERNAME|${TURN_USERNAME:-turn}|g" \
  -e "s|PLACEHOLDER_TURN_PASSWORD|${TURN_PASSWORD:-turnpassword}|g" \
  /etc/livekit/livekit.yaml > "$RUNTIME_CFG"

# When node IP is explicitly set, disable STUN-based external IP discovery.
# use_external_ip + --node-ip conflict: STUN result overwrites the node-ip in the log.
# With use_external_ip disabled, --node-ip is the sole ICE candidate IP.
if [ -n "$LIVEKIT_NODE_IP" ]; then
  sed -i 's/use_external_ip: true/use_external_ip: false/' "$RUNTIME_CFG"
fi

exec /livekit-server --config "$RUNTIME_CFG" ${LIVEKIT_NODE_IP:+--node-ip ${LIVEKIT_NODE_IP}}
