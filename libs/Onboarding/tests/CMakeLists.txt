# Unit and interface tests
cmake_minimum_required(VERSION 3.21)

project(TestOnboarding VERSION 0.1.0 LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Core REQUIRED)
qt6_standard_project_setup()

find_package(GTest REQUIRED)

enable_testing()

add_executable(${PROJECT_NAME}
    test_AccountService.cpp
    test_OnboardingController.cpp
    test_OnboardingModule.cpp

    ServiceMock.h
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

add_subdirectory(OnboardingTestHelpers)
add_subdirectory(qml_tests)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Core

        GTest::gtest
        GTest::gmock
        GTest::gtest_main
        
        Status::TestHelpers
        Status::ApplicationCore

        Status::OnboardingTestHelpers
        Status::Onboarding
)

include(GoogleTest)
gtest_add_tests(
    TARGET ${PROJECT_NAME}
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)
