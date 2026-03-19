#!/bin/sh
set -e

WORKDIR=/home/attendance_api
cd "$WORKDIR"

do_install() {
  echo "[entrypoint] Running npm install..."
  if npm install; then
    echo "[entrypoint] npm install completed."
  else
    echo "[entrypoint] npm install failed (likely stale node_modules). Cleaning and retrying..."
    rm -rf node_modules
    npm install
    echo "[entrypoint] npm install completed after clean."
  fi
}

if [ ! -d "node_modules/.bin" ]; then
  echo "[entrypoint] node_modules missing — installing..."
  do_install
elif [ "package.json" -nt "node_modules/.package-lock.json" ] 2>/dev/null; then
  echo "[entrypoint] package.json changed — syncing..."
  do_install
else
  echo "[entrypoint] node_modules up to date."
fi

exec "$@"
