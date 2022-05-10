# CPP App

## Setup dependencies

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

```bash
conan install . --profile=<Platform specific conan profile> -s build_type=Release --build=missing -if=build/conan
```

Platform specific conan profile

- Macos:
  - Intel: `vendor/conan-configs/apple-arm64.ini`
  - Apple silicon: `vendor/conan-configs/apple-x86_64.ini`
- Windows: TODO
- Linux: TODO

## Buid, test & run

Platform specific Qt prefix path

- Macos: `$HOME/Qt/6.3.0/macos`
- Windows: TODO
- Linux: TODO

### Build with conan

```bash
CMAKE_PREFIX_PATH=<Qt prefix path> conan build . -if=build/conan -bf=build
ctest -VV -C Release
./status-desktop
```

### Build with cmake

```bash
cmake -B build -S . -DCMAKE_PREFIX_PATH=<Qt prefix path> -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=build/conan/conan_toolchain.cmake
cmake --build build --config Release
```
