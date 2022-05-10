target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)

# Qt 6.3 fails calling qt6_target_qml_sources
#qt6_target_qml_sources(${PROJECT_NAME}
#    QML_FILES
#        StatusWindow.qml
#        StatusContentView.qml
#        TODO
#)
