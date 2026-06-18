#!/usr/bin/env bash

set -uo pipefail

echo "=== Spawn process ==="

# Chạy sleep ở background
sleep 300 &
PID=$!

echo "PID : $PID"

# Lấy PPID
PPID=$(ps -o ppid= -p "$PID" | tr -d ' ')
echo "PPID: $PPID"

echo
echo "Process information:"
ps -o pid,ppid,stat,cmd -p "$PID"

echo
echo "=== Send SIGTERM ==="
kill -TERM "$PID"

# Chờ process kết thúc và lấy exit code
wait "$PID"
EXIT_CODE=$?

echo
echo "Exit code: $EXIT_CODE"

if [ "$EXIT_CODE" -eq 143 ]; then
    echo "Process terminated by SIGTERM."
fi