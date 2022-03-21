# Readme

## Developer instructions

CMake

```sh
cd StatusQ/tests/TestControls
cmake -B ./build/ -S .
cmake --build ./build/
./build/TestControls
```

QtCreator

- Open the StatusQ/tests/CMakeLists.txt
- Choose a QT kit to run the tests
- In the `Test Results` panel choose Run All Tests

## TODO

- [ ] Consolidate and integrate with https://github.com/status-im/desktop-ui-tests