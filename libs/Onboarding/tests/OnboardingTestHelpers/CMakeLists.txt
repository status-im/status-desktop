# Base library. Expect most of the module libraries to depend on it
#
cmake_minimum_required(VERSION 3.21)

project(OnboardingTestHelpers
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(OnboardingTestHelpers
    URI Status.OnboardingTestHelpers
    VERSION 1.0

    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/OnboardingTestHelpers/
)
add_library(Status::OnboardingTestHelpers ALIAS OnboardingTestHelpers)

target_include_directories(OnboardingTestHelpers
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_sources(OnboardingTestHelpers
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/ScopedTestAccount.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Constants.h

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/ScopedTestAccount.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)

target_link_libraries(OnboardingTestHelpers
    PUBLIC
        Qt6::Quick
        Qt6::Qml

    PRIVATE
        Status::TestHelpers
        Status::ApplicationCore
        Status::Onboarding
        Status::StatusGoQt
)
