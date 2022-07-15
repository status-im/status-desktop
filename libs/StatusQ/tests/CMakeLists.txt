cmake_minimum_required(VERSION 3.21)

project(TestStatusQ LANGUAGES CXX)

enable_testing(true)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml QuickTest REQUIRED)

add_executable(TestStatusQ
    "main.cpp"
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# no need to copy around qml test files for shadow builds - just set the respective define
add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")


add_test(NAME TestStatusQ WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/TestStatusQ -input "${CMAKE_CURRENT_SOURCE_DIR}")
add_custom_target("Run_TestStatusQ" COMMAND ${CMAKE_CTEST_COMMAND} --test-dir "${CMAKE_CURRENT_SOURCE_DIR}")
add_dependencies("Run_TestStatusQ" TestStatusQ)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

add_subdirectory(TestHelpers)

target_link_libraries(TestStatusQ PRIVATE
    Qt6::QuickTest
    Qt6::Qml
    Qt6::Quick

    Status::TestHelpers
)
