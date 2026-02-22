#!/bin/bash
set -e

PI_HOST="blackraspberry"
PI_TARGET="pi4"

for arg in "$@"; do
    case $arg in
        --target=*) PI_TARGET="${arg#*=}" ;;
        *)          echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

./build-pi.sh --target="${PI_TARGET}"

# Stop any running instance so the binary is not busy when we overwrite it
ssh "${PI_HOST}" "pkill -f '[t]raffic-lights' || true"

ssh "${PI_HOST}" "mkdir -p ~/.local/bin"
scp -p "build-${PI_TARGET}/traffic-lights" "${PI_HOST}:~/.local/bin/traffic-lights"
echo "Deployed to ${PI_HOST}:~/.local/bin/traffic-lights"
