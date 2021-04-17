#!/bin/bash

# Usage: ./build.sh <path-to-ndk>

set -ex

NDK=$1
[ -z "${NDK}" ] && exit 1;

cmake -S . -B build -GNinja -DUMBRELLA=1 -DANDROID_NDK=${NDK}
cmake --build build
