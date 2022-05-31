# Temporary library not to duplicate resources
# TODO: refactor it when switching to C++ code into Assets resource library linked or embed with the app
#
cmake_minimum_required(VERSION 3.21)

project(FontAssets
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.FontsAssets
    VERSION 1.0
    # TODO: temporary until we make qt_target_qml_sources work
    RESOURCES
        Inter/Inter-Regular.otf

    RESOURCE_PREFIX ""
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Qml
)
