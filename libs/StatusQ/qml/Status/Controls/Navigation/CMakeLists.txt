# Controls specialized on user workflows
project(StatusQ_Controls_Navigation)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

set_source_files_properties(Style.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.Controls.Navigation
    VERSION 1.0

    QML_FILES
        ApplicationContentView.qml
        ApplicationSection.qml
        ApplicationState.qml
        MacTrafficLights.qml
        NavigationBar.qml
        NavigationBarButton.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Controls/Navigation
)
