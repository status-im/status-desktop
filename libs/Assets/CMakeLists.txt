# Global not theme dependent assets
# TODO: refactor it when switching to C++ code into Assets resource library linked or embed with the app
#
cmake_minimum_required(VERSION 3.21)

project(Assets
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Qml REQUIRED)
qt6_standard_project_setup()

set_source_files_properties(qml/Status/Assets/Resources.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt6_add_qml_module(Assets
    URI Status.Assets
    VERSION 1.0

    QML_FILES
        qml/Status/Assets/Resources.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Assets/
)
add_library(Status::Assets ALIAS Assets)

target_link_libraries(Assets
    PRIVATE
        Qt6::Qml

        # TODO: refactor when moved to C++ code
        FontAssets
        UiAssets
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

install(
    TARGETS
        Assets
    RUNTIME
)
