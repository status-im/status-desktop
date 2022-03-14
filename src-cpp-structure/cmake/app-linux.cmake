add_executable(${PROJECT_NAME})

target_link_libraries(
    ${PROJECT_NAME} PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    Qt5::Quick
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::QuickTemplates2
    Qt5::Multimedia
    Qt5::Concurrent
    Status.Services
    ${STATUS_GO_LIB}
    )

file(GLOB_RECURSE SOURCES
    "*.h"
    "*.cpp"
    ${STATUS_RCC}
    ${STATUS_RESOURCES_QRC}
    ${STATUS_QRC}
    )
