project(Sandbox)

find_package(
        Qt${QT_VERSION_MAJOR}
        COMPONENTS Core Quick QuickControls2
        REQUIRED)

if (${QT_VERSION_MAJOR} EQUAL 6)
    find_package(Qt6 COMPONENTS Core5Compat REQUIRED)
endif()

file(GLOB_RECURSE QML_FILES "../*.qml" "../qmldir")
file(GLOB_RECURSE JS_FILES "../*.js")

qt_add_big_resources(STATUSQ_SANDBOX_QRC qml.qrc)

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
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )

target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt::Core
        Qt::Quick
        Qt::QuickControls2
        $<$<EQUAL:${QT_VERSION_MAJOR},6>:Qt::Core5Compat>
        StatusQ
        )
