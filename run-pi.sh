#!/bin/bash
set -e

PI_HOST="blackraspberry"
PI_BINARY="~/.local/bin/traffic-lights"

ssh -t "${PI_HOST}" "${PI_BINARY}"
