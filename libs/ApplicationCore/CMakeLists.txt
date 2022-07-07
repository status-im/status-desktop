# Base library. Expect most of the module libraries to depend on it
#
cmake_minimum_required(VERSION 3.21)

project(ApplicationCore
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(ApplicationCore
    URI Status.ApplicationCore
    VERSION 1.0
)
add_library(Status::ApplicationCore ALIAS ApplicationCore)

target_link_libraries(ApplicationCore
    PRIVATE
        Qt6::Quick
        Qt6::Qml

        Status::Helpers
)

install(
    TARGETS
        ApplicationCore
    RUNTIME
)

target_include_directories(ApplicationCore
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ApplicationCore
    # TODO: Workaround to QML_ELEMENT Qt6
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ApplicationCore

    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_sources(ApplicationCore
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ApplicationCore/UserConfiguration.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ApplicationCore/UserConfiguration.cpp
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

