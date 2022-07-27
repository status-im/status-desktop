# Base library. Expect most of the module libraries to depend on it
#
cmake_minimum_required(VERSION 3.21)

project(TestHelpers
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(GTest REQUIRED)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(TestHelpers
    URI Status.TestHelpers
    VERSION 1.0

    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/TestHelpers
)
add_library(Status::TestHelpers ALIAS TestHelpers)

target_include_directories(TestHelpers
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_sources(TestHelpers
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/MonitorQtOutput.h
        ${CMAKE_CURRENT_SOURCE_DIR}/IOTestHelpers.h

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/MonitorQtOutput.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/IOTestHelpers.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)

target_link_libraries(TestHelpers
    PUBLIC
        Qt6::Quick
        Qt6::Qml

    PRIVATE
        GTest::gtest_main
)
