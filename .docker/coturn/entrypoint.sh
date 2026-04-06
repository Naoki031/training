#!/bin/sh
set -e

# Auto-detect public IP if TURN_EXTERNAL_IP not set
if [ -z "$TURN_EXTERNAL_IP" ]; then
  TURN_EXTERNAL_IP=$(curl -sf --max-time 5 https://api.ipify.org 2>/dev/null || \
                     curl -sf --max-time 5 https://ifconfig.me 2>/dev/null || \
                     echo "")
fi

INTERNAL_IP=$(hostname -i | awk '{print $1}')
EXTERNAL_IP_FLAG=""
if [ -n "$TURN_EXTERNAL_IP" ] && [ "$TURN_EXTERNAL_IP" != "$INTERNAL_IP" ]; then
  EXTERNAL_IP_FLAG="--external-ip=$TURN_EXTERNAL_IP/$INTERNAL_IP"
fi

TURN_USERNAME="${TURN_USERNAME:-turn}"
TURN_PASSWORD="${TURN_PASSWORD:-turnpassword}"

echo "[coturn] external-ip: ${TURN_EXTERNAL_IP:-auto-detect failed, using internal only}"
echo "[coturn] internal-ip: $INTERNAL_IP"

exec turnserver \
  -n \
  --log-file=stdout \
  --lt-cred-mech \
  --fingerprint \
  --no-multicast-peers \
  --no-cli \
  --realm=attendance.local \
  --min-port=49152 \
  --max-port=49200 \
  --user="${TURN_USERNAME}:${TURN_PASSWORD}" \
  $EXTERNAL_IP_FLAG \
  "$@"
