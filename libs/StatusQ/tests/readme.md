# Readme

## Developer instructions

CMake

```sh
cd ./tests/
cmake -B ./build/ -S .
cmake --build ./build/
ctest --test-dir ./build/
```

QtCreator

- Open the `./tests/CMakeLists.txt`
- Choose a QT kit to run the tests
- Set `%{sourceDir}/tests` as Working Directory for the TestStatusQ target
- In the *Test Results* panel choose Run All Tests or just run the *TestStatusQ* target

## TODO

- [ ] TestHelpers library
- [ ] Consolidate and integrate with https://github.com/status-im/desktop-ui-tests
