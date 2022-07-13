cmake_minimum_required(VERSION 3.5)

project(TestStatusQ LANGUAGES CXX)

enable_testing(true)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml QuickTest REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.TestHelpers
    VERSION 1.0

    QML_FILES

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/TestHelpers
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# no need to copy around qml test files for shadow builds - just set the respective define
add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_test(NAME ${PROJECT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME} -input "${CMAKE_CURRENT_SOURCE_DIR}")
add_custom_target("Run_${PROJECT_NAME}" COMMAND ${CMAKE_CTEST_COMMAND} --test-dir "${CMAKE_CURRENT_BINARY_DIR}")
add_dependencies("Run_${PROJECT_NAME}" ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

add_subdirectory(TestHelpers)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::QuickTest
    Qt6::Qml
    Qt6::Quick

    Status::TestHelpers
)
