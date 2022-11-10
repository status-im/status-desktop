cmake_minimum_required(VERSION 3.19)
project(Storybook)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (APPLE)
    set(MACOS_VERSION_MIN_FLAGS -mmacosx-version-min=10.14)
    set(CMAKE_OSX_ARCHITECTURES "x86_64")
endif()

find_package(
  Qt5
  COMPONENTS Core Quick QuickControls2 WebEngine
  REQUIRED)

file(GLOB_RECURSE QML_FILES "stubs/*.qml" "mocks/*.qml" "pages/*.qml" "src/*.qml" "src/qmldir" "../ui/StatusQ/*.qml" "../ui/app/*.qml")
file(GLOB_RECURSE JS_FILES "../ui/StatusQ/*.js" "../ui/app/*.js")

add_executable(
  ${PROJECT_NAME}
  main.cpp
  cachecleaner.cpp cachecleaner.h
  directorieswatcher.cpp directorieswatcher.h
  ${QML_FILES} main.qml
  ${JS_FILES}
)

target_compile_definitions(${PROJECT_NAME}
                           PRIVATE SRC_DIR="${CMAKE_CURRENT_LIST_DIR}")
target_link_libraries(
  ${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick Qt5::QuickControls2 Qt5::WebEngine
                          SortFilterProxyModel)

list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/StatusQ/src")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/app")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/imports")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/src")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/pages")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/stubs")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/mocks")
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra QML import paths" FORCE)

if (APPLE)
  find_library(AppKit AppKit)
  find_library(Foundation Foundation)

  target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation})
endif()

add_subdirectory(../ui/StatusQ/vendor/SortFilterProxyModel ./SortFilterProxyModel)
