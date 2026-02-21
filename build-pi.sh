#!/bin/bash
set -e

PI_TARGET="pi4"

for arg in "$@"; do
    case $arg in
        --target=*)
            PI_TARGET="${arg#*=}"
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

BUILD_DIR="build-${PI_TARGET}"

cmake -S . -B "${BUILD_DIR}" \
    -DCMAKE_TOOLCHAIN_FILE=cmake/pi-toolchain.cmake \
    -DPI_TARGET="${PI_TARGET}" \
    -DCMAKE_BUILD_TYPE=Debug
cmake --build "${BUILD_DIR}"
