cmake_minimum_required(VERSION 3.21)

project(StatusQ
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status
    VERSION 1.0

    QML_FILES

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status
)
add_library(Status::StatusQ ALIAS StatusQ)

add_subdirectory(qml/Status/Containers)
add_subdirectory(qml/Status/Controls)
add_subdirectory(qml/Status/Core)
add_subdirectory(tests)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::Qml

        Assets
        StatusQ_Containers
        StatusQ_Controls
        StatusQ_Core
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)
