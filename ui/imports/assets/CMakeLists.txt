# Temporary library not to duplicate resources
# TODO: refactor it when switching to C++ code into Assets resource library linked or embed with the app
#
cmake_minimum_required(VERSION 3.21)

project(UiAssets
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.UiAssets
    VERSION 1.0
    # TODO: temporary until we make qt_target_qml_sources work
    RESOURCES
        gif/status_splash_dark.gif
        gif/status_splash_light.gif

        icons/status-logo-icon.svg
        icons/status-logo-dark.svg

        png/traffic_lights/close.png
        png/traffic_lights/close_pressed.png
        png/traffic_lights/maximize.png
        png/traffic_lights/maximize_pressed.png
        png/traffic_lights/minimise.png
        png/traffic_lights/minimise_pressed.png
        png/status-logo.png

    RESOURCE_PREFIX ""
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Qml
)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)