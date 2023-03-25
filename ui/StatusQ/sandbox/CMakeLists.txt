project(sandbox)

find_package(
        Qt5
        COMPONENTS Core Quick QuickControls2
        REQUIRED)

file(GLOB_RECURSE QML_FILES "../*.qml" "../qmldir")
file(GLOB_RECURSE JS_FILES "../*.js")

qt5_add_big_resources(STATUSQ_SANDBOX_QRC qml.qrc)

add_executable(sandbox
        sandboxapp.h
        main.cpp
        sandboxapp.cpp
        ${STATUSQ_SANDBOX_QRC}
        ${QML_FILES}
        ${JS_FILES}
        )

target_compile_definitions(sandbox
        PRIVATE SRC_DIR="${CMAKE_CURRENT_LIST_DIR}")

target_link_libraries(sandbox PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::QuickControls2
        )
#
#if (APPLE)
#  find_library(AppKit AppKit)
#  find_library(Foundation Foundation)
#  target_link_libraries(StatusQ_Sandbox PRIVATE ${AppKit} ${Foundation})
#endif()
