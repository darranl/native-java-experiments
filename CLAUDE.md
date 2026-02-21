# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A C application targeting LED control for a traffic light. Currently in early stages — the code will evolve incrementally toward hardware LED control.

## Build

The project uses CMake with an out-of-source build in `build/`:

```bash
cmake -S . -B build
cmake --build build
```

## Run

```bash
./run-app.sh
```

This runs `./build/traffic-lights`.

## Architecture

- `main.c` — entry point
- `CMakeLists.txt` — builds the `traffic-lights` executable
- `run-app.sh` — launches the binary
