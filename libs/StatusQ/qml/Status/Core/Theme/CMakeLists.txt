# Theme dependent components and assets
project(StatusQ_Core_Theme)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

set_source_files_properties(
    StatusColors.qml
    Style.qml
    Theme.qml
    Utils.qml

    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.Core.Theme
    VERSION 1.0

    QML_FILES
        StatusColors.qml
        StatusDarkPalette.qml
        StatusDarkTheme.qml
        StatusLayouting.qml
        StatusLightPalette.qml
        StatusLightTheme.qml
        StatusPalette.qml
        StatusTheme.qml
        Style.qml
        Theme.qml
        Utils.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Core/Theme
)
