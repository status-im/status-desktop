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

target_compile_definitions(sandbox PRIVATE
        SANDBOX_SRC_DIR="${CMAKE_CURRENT_LIST_DIR}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )

target_link_libraries(sandbox PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::QuickControls2
        )
