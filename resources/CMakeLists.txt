# Temporary library not to duplicate resources
# TODO: refactor it when switching to C++ code
#
cmake_minimum_required(VERSION 3.21)

project(StatusGoConfig
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Qml REQUIRED)
qt6_standard_project_setup()

# Resource path ":/Status/StaticConfig/<file>"
qt6_add_qml_module(${PROJECT_NAME}
    URI Status.StaticConfig
    VERSION 1.0
    RESOURCES
        default-networks.json
        fleets.json
        infura_key
        node-config.json
    RESOURCE_PREFIX ""
)
add_library(Status::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Qml
)
