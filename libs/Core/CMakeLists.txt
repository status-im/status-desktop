# Base library. Expect most of the module libraries to depend on it
#
cmake_minimum_required(VERSION 3.21)

project(Core
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.Core
    VERSION 1.0
    # TODO: temporary until we make qt_target_qml_sources work
    QML_FILES
        qml/Status/Core/DevTest.qml
    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Core
)

add_subdirectory(qml/Status/Core)
add_subdirectory(src)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)