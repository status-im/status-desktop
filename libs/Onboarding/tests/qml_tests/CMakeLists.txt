cmake_minimum_required(VERSION 3.5)

project(TestOnboardingQml LANGUAGES CXX)

enable_testing(true)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml QuickTest REQUIRED)

add_executable(TestOnboardingQml
    "main.cpp"
)

# no need to copy around qml test files for shadow builds - just set the respective define
add_compile_definitions(QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_test(NAME TestOnboardingQml WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/TestOnboardingQml -input "${CMAKE_CURRENT_SOURCE_DIR}")
add_custom_target("Run_TestOnboardingQml" COMMAND ${CMAKE_CTEST_COMMAND} --test-dir "${CMAKE_CURRENT_SOURCE_DIR}")
add_dependencies("Run_TestOnboardingQml" TestOnboardingQml)

target_link_libraries(TestOnboardingQml PRIVATE
    Qt6::QuickTest
    Qt6::Qml
    Qt6::Quick

    Status::TestHelpers

    Status::Onboarding
)
