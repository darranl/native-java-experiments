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
ssh "${PI_HOST}" "pkill -f traffic-lights || true"

ssh "${PI_HOST}" "mkdir -p ~/.local/bin && cat > ~/.local/bin/traffic-lights && chmod +x ~/.local/bin/traffic-lights" \
    < "build-${PI_TARGET}/traffic-lights"
echo "Deployed to ${PI_HOST}:~/.local/bin/traffic-lights"
