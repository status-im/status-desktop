add_executable(${PROJECT_NAME} WIN32)

target_link_libraries(
    ${PROJECT_NAME}
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    Qt5::Quick
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::QuickTemplates2
    Qt5::Multimedia
    )

file(GLOB_RECURSE SOURCES
    "*.h"
    "*.cpp"
    ${STATUS_RCC}
    ${STATUS_RESOURCES_QRC}
    ${STATUS_QRC}
    )
