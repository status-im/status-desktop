# Status-desktop

Desktop client for the [Status Network](https://statusnetwork.com/) built with [Nim](https://nim-lang.org/) and [Qt](https://www.qt.io/)

![https://github.com/status-im/nim-status-client/blob/master/screenshot.png](https://github.com/status-im/nim-status-client/blob/master/screenshot.png)

Dev Docs: [https://hackmd.io/@status-desktop/B1naRjxh_/https%3A%2F%2Fhackmd.io%2F%40status-desktop%2FB1eOaf-nd](https://hackmd.io/@status-desktop/B1naRjxh_/https%3A%2F%2Fhackmd.io%2F%40status-desktop%2FB1eOaf-nd)





# CPP App
Buid&test&run:
```
cd build
conan install .. -s build_type=Release --build=missing
conan build ..
ctest -VV -C Release
./status-desktop
```

Instead of `conan build ..` CMake may be used:
```
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake
cmake --build . --config Release
```
