# Status-desktop

Desktop client for the [Status Network](https://statusnetwork.com/) built with [Nim](https://nim-lang.org/) and [Qt](https://www.qt.io/)

![https://github.com/status-im/nim-status-client/blob/master/screenshot.png](https://github.com/status-im/nim-status-client/blob/master/screenshot.png)

Dev Docs: [https://hackmd.io/@status-desktop/B1naRjxh_/https%3A%2F%2Fhackmd.io%2F%40status-desktop%2FB1eOaf-nd](https://hackmd.io/@status-desktop/B1naRjxh_/https%3A%2F%2Fhackmd.io%2F%40status-desktop%2FB1eOaf-nd)





# CPP App

### Setup `Linux`:
1. conancenter
Execute `conan remote list`. It should return this line among the results. 
```
conancenter: https://center.conan.io [Verify SSL: True]
```
If it doesnt, consider upgrading conan with `pip install conan --upgrade` and then executing. `conan remote add -i 0 conancenter https://center.conan.io` . See [conan's documentation](https://docs.conan.io/en/latest/uploading_packages/remotes.html#conancenter) for more info.


2. conan libstdc++11
This applies to linux: the default conan profile does not work, since GCC uses the new C++ ABI since version 5.1 and conan, for compatibility purposes uses the old C++ ABI.
Execute this to update the profile:
```
conan profile update settings.compiler.libcxx=libstdc++11 default
```

3. Install dependencies:

```
cd build
conan install .. -s build_type=Release --build=missing
```

### Setup `OS X`:

1. Create `conan` profile `~/.conan/profiles/clang`:
```
[settings]
compiler=apple-clang
compiler.version=12.0
compiler.libcxx=libc++
arch=x86_64
os=Macos
build_type=Release

[env]
CC=/usr/bin/clang
CXX=/usr/bin/clang++
```

2. Install dependecies:

```
cd build
conan install .. --profile=clang --build=missing
```

### Buid & test & run:
```
conan build ..
ctest -VV -C Release
./status-desktop
```

Instead of `conan build ..` CMake may be used:
```
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake
cmake --build . --config Release
```
