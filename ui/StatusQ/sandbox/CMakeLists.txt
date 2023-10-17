project(Sandbox)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(
        Qt5
        COMPONENTS Core Quick QuickControls2
        REQUIRED)

file(GLOB_RECURSE QML_FILES "../*.qml" "../qmldir")
file(GLOB_RECURSE JS_FILES "../*.js")

qt5_add_big_resources(STATUSQ_SANDBOX_QRC qml.qrc)

add_executable(${PROJECT_NAME}
        sandboxapp.h
        main.cpp
        sandboxapp.cpp
        ${STATUSQ_SANDBOX_QRC}
        ${QML_FILES}
        ${JS_FILES}
        )

target_compile_definitions(${PROJECT_NAME} PRIVATE
        SANDBOX_SRC_DIR="${CMAKE_CURRENT_LIST_DIR}"
        STATUSQ_MODULE_PATH="${STATUSQ_MODULE_PATH}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )

target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::QuickControls2
        )
