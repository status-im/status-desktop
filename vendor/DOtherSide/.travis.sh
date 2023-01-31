#!/bin/bash

# Early exit on first error
set -e

# Build DOtherSide
mkdir build
cd build
cmake -GNinja -DENABLE_COVERAGE=ON -DCMAKE_BUILD_TYPE=Debug ..
cmake --build .

# Start framebuffer
Xvfb :99 -screen 0 1024x768x24 > /dev/null &
export DISPLAY=:99.0

# Execute Tests
./test/TestDynamicQObject

# Collect coverage info
lcov --directory . --capture --output-file coverage.info

# Clean it up
lcov --remove coverage.info "/usr/*" -o coverage.info
lcov --remove coverage.info "*/build/*" -o coverage.info
lcov --remove coverage.info "*/test/*" -o coverage.info
