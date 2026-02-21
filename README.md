# traffic-lights

A Raspberry Pi C application that drives three GPIO pins through a complete 4-phase UK traffic light cycle using WiringPi.

## Prerequisites

- `cmake` (≥ 3.10.0), `gcc` — for native build
- `aarch64-linux-gnu-gcc` — for Pi cross-compilation
- Pi OS 12 sysroot **pre-mounted** at `$HOME/mnt/pios12_root` — required before any Pi build
- SSH host `blackraspberry` configured — required for deploy/run/debug scripts

## Key files

| File | Purpose |
|------|---------|
| `main.c` | Entry point |
| `CMakeLists.txt` | Builds the `traffic-lights` executable |
| `cmake/pi-toolchain.cmake` | CMake cross-compilation toolchain for Pi (aarch64) |
| `run-app.sh` | Run the native build locally |
| `build-pi.sh` | Cross-compile for Pi4 or Pi5 |
| `deploy-pi.sh` | Build and deploy binary to Pi over SSH |
| `run-pi.sh` | Run the deployed binary on the Pi over SSH |
| `debug-pi.sh` | Start `gdbserver` on the Pi for remote debugging (port 1234) |
| `.vscode/c_cpp_properties.json` | IntelliSense configuration for aarch64 cross-compilation |
| `.vscode/launch.json` | Remote GDB debug launch configuration |

## Build

**Native:**
```bash
cmake -S . -B build
cmake --build build
```

**Raspberry Pi:**
```bash
./build-pi.sh [--target=pi4|pi5]
```
> Use `--target=pi4` (default) or `--target=pi5` to select the board.
> Requires sysroot at `$HOME/mnt/pios12_root`.

## Run

| Scenario | Command |
|----------|---------|
| Local | `./run-app.sh` |
| Deploy to Pi | `./deploy-pi.sh [--target=pi4\|pi5]` |
| Run on Pi (SSH) | `./run-pi.sh` |
| Remote debug (gdbserver) | `./debug-pi.sh` |
