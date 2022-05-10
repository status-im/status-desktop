# Internally we use includes directly
# External clients have to explicitly use the module name
add_subdirectory(StatusGo)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/StatusGo
    # TODO: Workaround to QML_ELEMENT Qt6
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/StatusGo

    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
