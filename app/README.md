# CPP App

## Setup dependencies

Note: if not stated otherwise the commands should be run from the root of the source tree

### 1. conancenter

Execute `conan remote list`. It should return this line among the results:

```bash
conancenter: https://center.conan.io [Verify SSL: True]
```

If it doesn't, consider upgrading conan with `pip install conan --upgrade` and then executing. `conan remote add -i 0 conancenter https://center.conan.io`. See [conan's documentation](https://docs.conan.io/en/latest/uploading_packages/remotes.html#conancenter) for more info.

### 2. conan libstdc++11

This applies to linux: the default conan profile does not work, since GCC uses the new C++ ABI since version 5.1 and conan, for compatibility purposes uses the old C++ ABI.
Execute this to update the profile:

```bash
conan profile update settings.compiler.libcxx=libstdc++11 default
```

### 2. Install dependencies

Install latest Qt release 6.3.X

Platform specific conan profile

- Macos:
  - Apple silicon: `conan install . --profile=vendor/conan-configs/apple-arm64.ini -s build_type=Release --build=missing -if=build/conan -of=build`
  - Intel: `conan install . --profile=vendor/conan-configs/apple-x86_64.ini -s build_type=Release --build=missing -if=build/conan -of=build`
- Windows: TODO
- Linux: `conan install . --profile=./vendor/conan-configs/linux.ini -s build_type=Release --build=missing -if=build/conan -of=build`

## Buid, test & run

Update `CMake` to the [Latest Release](https://cmake.org/download/) or use the Qt's "$QTBASE/Tools/CMake/..."

### Build with conan

```bash
# linux
CMAKE_PREFIX_PATH="$HOME/Qt/6.3.2/gcc_64" conan build . -if=build/conan -bf=build

# MacOS: CMAKE_PREFIX_PATH="$HOME/Qt/6.3.2/macos" conan build . -if=build/conan -bf=build

# Windows: CMAKE_PREFIX_PATH="$HOME/Qt/6.3.2/mingw_64" conan build . -if=build/conan -bf=build

ctest -VV -C Release
./status-desktop
```

### Build with cmake

```bash
# linux
cmake -B build -S . -DCMAKE_PREFIX_PATH="$HOME/Qt/6.3.2/gcc_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=build/conan/conan_toolchain.cmake

# MacOS: cmake -B build -S . -DCMAKE_PREFIX_PATH="$HOME/Qt/6.3.2/macos" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=build/conan/conan_toolchain.cmake

# Windows: cmake -B build -S . -DCMAKE_PREFIX_PATH="$HOME/Qt/6.3.2/mingw_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=build/conan/conan_toolchain.cmake

cmake --build build
```

### Run tests

```bash
ctest --test-dir ./build
```
