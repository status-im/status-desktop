# Onboarding Module build definition
#
cmake_minimum_required(VERSION 3.21)

project(Onboarding
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml Concurrent REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(Onboarding
    URI Status.Onboarding
    VERSION 1.0

    QML_FILES
        qml/Status/Onboarding/base/SetupNewProfilePageBase.qml
        qml/Status/Onboarding/base/OnboardingPageBase.qml

        qml/Status/Onboarding/ConfirmPasswordPage.qml
        qml/Status/Onboarding/CreatePasswordPage.qml
        qml/Status/Onboarding/LoginView.qml
        qml/Status/Onboarding/OnboardingView.qml
        qml/Status/Onboarding/SetupNewProfileView.qml
        qml/Status/Onboarding/SetUserNameAndPicturePage.qml
        qml/Status/Onboarding/TempTextInput.qml
        qml/Status/Onboarding/WelcomeView.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Onboarding/
)
add_library(Status::Onboarding ALIAS Onboarding)

add_subdirectory(src)
add_subdirectory(tests)

target_link_libraries(Onboarding
    PUBLIC
        Status::StatusGoQt

    PRIVATE
        Qt6::Quick
        Qt6::Qml
        Qt6::Concurrent

        Status::ApplicationCore
        Status::Helpers

        Status::StatusGoConfig
)

# Required by the MacOS authenticator. Consider moving platform particular implementation in its own static linked library
if(APPLE)
    target_link_libraries(Onboarding
        PRIVATE
            "-framework Security"
            "-framework LocalAuthentication"
    )
endif()

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

install(
    TARGETS
        Onboarding
    RUNTIME
)
