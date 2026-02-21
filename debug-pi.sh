#!/bin/bash
set -e

PI_HOST="blackraspberry"
PI_BINARY="~/.local/bin/traffic-lights"
# Port must match LocalForward in ~/.ssh/config (1234 → pi:1234)
GDB_PORT=1234

echo "Starting gdbserver on ${PI_HOST}:${GDB_PORT}"
echo "Tunnel is provided by LocalForward in ~/.ssh/config — connect VS Code 'Pi: Remote Debug'"

ssh "${PI_HOST}" "gdbserver :${GDB_PORT} ${PI_BINARY}"
