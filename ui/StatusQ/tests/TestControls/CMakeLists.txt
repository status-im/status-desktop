cmake_minimum_required(VERSION 3.5)

project(TestStatusInputWithRegex LANGUAGES CXX)

enable_testing()

# TODO: Workaround until we make StatusQ a CMake library
list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../../src/")
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra qml import paths")
set(QML2_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra qml import paths")

find_package(QT NAMES Qt6 Qt5 COMPONENTS QuickTest Qml REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS QuickTest Qml REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# no need to copy around qml test files for shadow builds - just set the respective define
add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(TestStatusInputWithRegex main.cpp)
add_test(NAME TestStatusInputWithRegex COMMAND TestStatusInputWithRegex)

target_link_libraries(TestStatusInputWithRegex PRIVATE
    Qt${QT_VERSION_MAJOR}::QuickTest
    Qt${QT_VERSION_MAJOR}::Qml)

