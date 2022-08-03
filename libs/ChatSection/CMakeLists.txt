cmake_minimum_required(VERSION 3.21)

project(ChatSection
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml Concurrent REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.ChatSection
    VERSION 1.0

    QML_FILES
       qml/Status/ChatSection/NavigationView.qml
       qml/Status/ChatSection/ContentView.qml
       qml/Status/ChatSection/MainView.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/${PROJECT_NAME}/
)
add_library(Status::ChatSection ALIAS ChatSection)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include

    # Workaround to Qt6's *_qmltyperegistrations.cpp
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include/Status/ChatSection/

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::Qml
        Qt6::Concurrent

        Status::ApplicationCore

        Status::StatusGoQt
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)

target_sources(${PROJECT_NAME}
    PRIVATE
        include/Status/ChatSection/ChatSectionController.h
        src/ChatSectionController.cpp
        include/Status/ChatSection/ChatItem.h
        src/ChatItem.cpp
        include/Status/ChatSection/ChatDataProvider.h
        src/ChatDataProvider.cpp
)
