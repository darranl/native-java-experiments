set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_SYSROOT $ENV{HOME}/mnt/pios12_root)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Select tune flags based on PI_TARGET (default: pi4)
if(NOT DEFINED PI_TARGET)
    set(PI_TARGET "pi4" CACHE STRING "Target Pi model (pi4, pi5)")
endif()

if(PI_TARGET STREQUAL "pi5")
    set(PI_TUNE "-mtune=cortex-a76")
elseif(PI_TARGET STREQUAL "pi4")
    set(PI_TUNE "-mtune=cortex-a72")
else()
    message(FATAL_ERROR "Unknown PI_TARGET '${PI_TARGET}'. Valid values: pi4, pi5")
endif()

# Debian/Raspbian uses a multiarch layout: target-specific headers (bits/*, sys/*)
# live under usr/include/aarch64-linux-gnu/ rather than directly in usr/include/.
# Both directories must be on the path, with the multiarch dir first so that
# target-specific headers (e.g. bits/stdio_lim.h) are found before any generic
# fallbacks.  The cross-compiler's --sysroot does not add these automatically.
set(CMAKE_C_FLAGS
    "-march=armv8-a+crc ${PI_TUNE} -isystem ${CMAKE_SYSROOT}/usr/include/aarch64-linux-gnu -isystem ${CMAKE_SYSROOT}/usr/include"
    CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)

# The cross-compiler's own libc.so linker script references /lib/libc.so.6
# (no multilib path), which doesn't exist under the Pi's Debian-layout sysroot.
# Adding the sysroot's multilib lib dir to the search path ensures the linker
# finds the Pi's libc.so script first, which uses paths that do resolve correctly.
#
# -L        : used by the linker to resolve libraries named with -l flags (direct deps)
# --rpath-link: used by the linker to resolve transitive deps of already-found .so files
#               (e.g. libwiringPi.so depends on libm and libcrypt; without rpath-link
#               the linker can't find them and raises "not found" warnings/errors)
set(CMAKE_EXE_LINKER_FLAGS
    "-L${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu \
     -L${CMAKE_SYSROOT}/lib/aarch64-linux-gnu \
     -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu \
     -Wl,-rpath-link,${CMAKE_SYSROOT}/lib/aarch64-linux-gnu"
    CACHE STRING "" FORCE)
