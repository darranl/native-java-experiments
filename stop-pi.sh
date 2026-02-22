#!/bin/bash
set -e

PI_HOST="blackraspberry"

# Stop any running instance
ssh "${PI_HOST}" "pkill -f '[t]raffic-lights' || true"

# Turn off all BCM GPIO pins 0-27; suppress errors for reserved pins
ssh "${PI_HOST}" 'for pin in $(seq 0 27); do gpioset gpiochip0 $pin=0 2>/dev/null || true; done'
