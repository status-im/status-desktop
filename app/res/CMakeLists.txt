# TODO workaround until Qt6 API is clarified
target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/app.qrc

        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)

# TODO find out why it isn't working
#
#qt6_target_qml_sources(${PROJECT_NAME}
#    RESOURCES
#        qtquickcontrols2.conf
#    PREFIX ""
#)
