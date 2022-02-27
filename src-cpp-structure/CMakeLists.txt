cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(Status DESCRIPTION "Status project" LANGUAGES CXX)

include("${CMAKE_SOURCE_DIR}/cmake/project-config.cmake")
include("${CMAKE_SOURCE_DIR}/cmake/conan.cmake")

find_package(Qt5 REQUIRED COMPONENTS 
    Core
    Gui
    Quick
    Widgets
    Qml
    Quick
    QuickControls2
    QuickTemplates2
    Multimedia
    Concurrent
    LinguistTools)

# The following should be moved to conan.
# But so far we're just adding libs from the vendor folder this way.
# statusgo lib is registered globaly - /vendor/status-go/CMakeLists.txt
SET(STATUS_GO_LIB statusgo_shared)
add_subdirectory(${CMAKE_SOURCE_DIR}/../vendor/status-go bin/status-go)

add_subdirectory(projects)
