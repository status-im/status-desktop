# Note that the automatic plugin generation is only possible if the module does not do anything besides registering the types.
# If it needs to do something more advanced like registering an image provider in initializeEngine, you still need to manually write the plugin. qt6_add_qml_module has support for this with NO_GENERATE_PLUGIN_SOURCE.

target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)

add_subdirectory(Status/Application)

# Qt 6.3 fails calling qt6_target_qml_sources
#qt6_target_qml_sources(${PROJECT_NAME}
#    QML_FILES
#        main.qml
#)
