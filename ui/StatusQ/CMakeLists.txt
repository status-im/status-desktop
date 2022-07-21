cmake_minimum_required(VERSION 3.19)

project(StatusQ)

if (APPLE)
    set(MACOS_VERSION_MIN_FLAGS -mmacosx-version-min=10.14)
    set(CMAKE_OSX_ARCHITECTURES "x86_64")
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# https://doc.qt.io/qtcreator/creator-qml-modules-with-plugins.html#importing-qml-modules
set(QML_IMPORT_PATH
    ${CMAKE_SOURCE_DIR}/src;${QML_IMPORT_PATH}
    CACHE STRING "")

add_subdirectory(vendor/SortFilterProxyModel)
add_subdirectory(sandbox)
add_subdirectory(tests)
