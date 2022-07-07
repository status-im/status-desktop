cmake_minimum_required(VERSION 3.21)

project(TestStatusGoQtModule VERSION 0.1.0 LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Core REQUIRED)
qt6_standard_project_setup()

find_package(GTest REQUIRED)

enable_testing()

add_executable(TestStatusGoQtModule
    test_accounts.cpp
    test_messaging.cpp
    test_onboarding.cpp
    test_wallet.cpp
)

target_link_libraries(TestStatusGoQtModule
    PRIVATE
        Qt6::Core

        GTest::gtest
        GTest::gmock
        GTest::gtest_main

        Status::TestHelpers
        Status::OnboardingTestHelpers

        Status::Onboarding

        Status::StatusGoQt
)

include(GoogleTest)
gtest_add_tests(
    TARGET TestStatusGoQtModule
WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)
