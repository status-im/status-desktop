# Unit tests for StatusGoQt
cmake_minimum_required(VERSION 3.21)

project(TestStatusGoQt VERSION 0.1.0 LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Core REQUIRED)
qt6_standard_project_setup()

find_package(GTest REQUIRED)

enable_testing()

add_executable(TestStatusGoQt
    test_StatusGo.cpp
)

target_include_directories(TestStatusGoQt
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(TestStatusGoQt
    PRIVATE
        Qt6::Core

        GTest::gtest
        GTest::gmock
        GTest::gtest_main

        Status::StatusGoQt
)


include(GoogleTest)
gtest_add_tests(
    TARGET TestStatusGoQt
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)
