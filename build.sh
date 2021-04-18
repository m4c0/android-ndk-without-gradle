#!/bin/bash

# Usage: ./build.sh <path-to-ndk>

set -ex

[ -z "${ANDROID_SDK_ROOT}" ] && exit 1

cmake -S . -B build -GNinja -DUMBRELLA=1
cmake --build build
