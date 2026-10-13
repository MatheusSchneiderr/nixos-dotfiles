#!/usr/bin/env bash
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HOME/.local/state/llm-ctl"
mkdir -p "$STATE"
PORT=8901

# Router mode (--models-preset) serves ALL tiers from models.ini on one process/port.
# There's no "start tier X" - the actual model loaded is decided per-request by whatever
# the client (pi/opencode/nvim) sends in its "model" field; the router auto-swaps to
# match, unloading whatever was previously loaded. This script only turns the router
# itself on/off - it doesn't pick a model.

is_running() {
  pgrep -f "llama-server" >/dev/null
}

stop() {
  echo "* stopping llama-server"
  pkill -9 -f "llama-server" 2>/dev/null
}

# to debug verbosely, run directly in a terminal instead of start():
#   llama-server --models-preset "$DIR/models.ini" --models-max 1 --port 8901 --jinja --verbose
start() {
  if is_running; then
    echo "already running - stop first"
    return 1
  fi

  setsid llama-server --models-preset "$DIR/models.ini" --models-max 1 --port "$PORT" --jinja \
    >"$STATE/server.log" 2>&1 &
  echo "started (port $PORT)"
}

case "${1-}" in
  start) start; exit 0 ;;
  stop) stop; exit 0 ;;
  "") ;;
  *) echo "usage: $0 [start|stop]" >&2; exit 1 ;;
esac

while true; do
  echo
  echo "=== llm-ctl ==="
  if is_running; then
    echo "running"
  else
    echo "not running"
  fi
  echo

  PS3="pick a number: "
  select choice in "start" "stop" "quit"; do
    case "$REPLY" in
      1) start ;;
      2) stop ;;
      3) exit 0 ;;
      *) echo "invalid" ;;
    esac
    break
  done
done
