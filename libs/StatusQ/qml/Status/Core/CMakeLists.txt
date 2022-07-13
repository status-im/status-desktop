# QML generic elements used by the other components
project(StatusQ_Core)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.Core
    VERSION 1.0

    QML_FILES
        StatusBaseText.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Core
)

add_subdirectory(Theme)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::Qml

        StatusQ_Core_Theme
)
