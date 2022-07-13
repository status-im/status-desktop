set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

set(CMAKE_AUTORCC On)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick REQUIRED)
qt6_standard_project_setup()

qt6_add_executable(${PROJECT_NAME})

# TODO: Fix temporarly workaround until we make qt6_target_qml_sources work
# Adds qml files as /Status/Application/qml/.../<file name>
qt6_add_qml_module(${PROJECT_NAME}
    URI Status.Application
    VERSION 1.0

    QML_FILES
        qml/main.qml
        qml/Status/Application/Decorators/SplashScreen.qml

        qml/Status/Application/MainView/MainView.qml
        qml/Status/Application/MainView/StatusApplicationSections.qml

        qml/Status/Application/MainView/StatusApplicationSections/Wallet/WalletNavBarSection.qml

        qml/Status/Application/Settings/ApplicationSettings.qml

        qml/Status/Application/System/StatusTrayIcon.qml

        qml/Status/Application/Workflows/CloseApplicationHandler.qml

        qml/Status/Application/StatusContentView.qml
        qml/Status/Application/MainShortcuts.qml
        qml/Status/Application/StatusWindow.qml

    SOURCES
        res/app.qrc

    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Application
)

# Compile time definitions required by the project
target_compile_definitions(${PROJECT_NAME} PRIVATE BUILD_PROJECT_NAME="${PROJECT_NAME}")
target_compile_definitions(${PROJECT_NAME} PRIVATE BUILD_PROJECT_ORGANIZATION_DOMAIN="${PROJECT_ORGANIZATION_DOMAIN}")
target_compile_definitions(${PROJECT_NAME} PRIVATE BUILD_PROJECT_ORGANIZATION_NAME="${PROJECT_ORGANIZATION_NAME}")
target_compile_definitions(${PROJECT_NAME} PRIVATE BUILD_PROJECT_APPLICATION_NAME="${PROJECT_APPLICATION_NAME}")

target_compile_definitions(${PROJECT_NAME} PRIVATE BUILD_BINARY_DIR=${CMAKE_BINARY_DIR})
target_compile_definitions(${PROJECT_NAME} PRIVATE BUILD_SOURCE_DIR=${CMAKE_SOURCE_DIR})

add_subdirectory(qml/Status/Application/Navigation)
add_subdirectory(src)

include(${CMAKE_SOURCE_DIR}/cmake/platform_specific.cmake)
string(TOLOWER ${PROJECT_ORGANIZATION_NAME} URL_ORGANIZATION_NAME)
configure_app_os_specific(${PROJECT_NAME} ${URL_ORGANIZATION_NAME} ${PROJECT_ORGANIZATION_DOMAIN} ${PROJECT_VERSION_MAJOR} ${PROJECT_VERSION_MINOR} ${PROJECT_VERSION_PATCH})

target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick

        Status::Application::Navigation

        # TODO: Use Status:: namespace
        Status::ApplicationCore
        Status::Helpers
        Status::Onboarding
        Status::Assets
        Status::StatusQ
        Status::StatusGoQt
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)
