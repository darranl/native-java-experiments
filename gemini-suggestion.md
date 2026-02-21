Since your mount point is now specifically ~/mnt/pios12_root, we will set that as our CMAKE_SYSROOT.

This file tells CMake to stop looking at your Arch Linux /usr/include and instead use the Raspberry Pi's headers and libraries. It also forces the use of the cross-compiler you installed via the AUR.
pi-toolchain.cmake

Create this file in your project root (or a cmake/ subfolder):
CMake

# Target System Specification
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64) # Use 'arm' if you are on 32-bit Pi OS

# Define the Sysroot (The Pi's filesystem via sshfs)
set(CMAKE_SYSROOT $ENV{HOME}/mnt/pios12_root)

# Specify the Cross-Compiler (Arch AUR package paths)
# For 64-bit Pi OS 12:
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Adjust the search behavior:
# Search for programs in the host (Arch) environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers ONLY in the target (Pi) environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Optional: Set common Pi-specific optimization flags
set(CMAKE_C_FLAGS "-march=armv8-a+crc -mtune=cortex-a72" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)

How to Run the Build

To use this file, you pass it to CMake during the configuration step. On Arch, you would run this from your project's build directory:
Bash

# 1. Configure the project using the toolchain file
cmake -DCMAKE_TOOLCHAIN_FILE=pi-toolchain.cmake ..

# 2. Build the binary (uses your laptop's CPU)
cmake --build .

# 3. Install/Deploy (copies to the Pi via the mount)
# This assumes you have an 'install' target in your CMakeLists.txt
cmake --install . --prefix ~/mnt/pios12_root/home/pi/debug_build

Key Logic in this File:

    CMAKE_FIND_ROOT_PATH_MODE_... ONLY: This is critical. It prevents CMake from accidentally finding an x86 version of a library (like OpenSSL or zlib) on your Arch laptop and trying to link it to an ARM binary, which would cause a "format not recognized" error.

    CMAKE_SYSROOT: This prepends your mount path to every header search. When your code says #include <stdio.h>, the compiler actually looks in ~/mnt/pios12_root/usr/include/stdio.h.

Would you like me to help you set up a matching launch.json so you can start the debugger directly from VS Code using this new path?