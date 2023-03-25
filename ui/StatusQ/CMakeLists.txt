cmake_minimum_required(VERSION 3.19)

project(StatusQ)

option(STATUSQ_BUILD_SANDBOX "Enable to build StatusQ Sandbox application" ON)
option(STATUSQ_BUILD_SANITY_CHECKER "Enable to build StatusQ Sanity Checker application" ON)
option(STATUSQ_BUILD_TESTS "Enable to build StatusQ UI auto tests" ON)

if (APPLE)
    set(MACOS_VERSION_MIN_FLAGS -mmacosx-version-min=10.14)
    set(CMAKE_OSX_ARCHITECTURES "x86_64")
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QZXING_USE_QML ON)
set(QZXING_MULTIMEDIA ON)
set(QZXING_USE_DECODER_QR_CODE ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# https://doc.qt.io/qtcreator/creator-qml-modules-with-plugins.html#importing-qml-modules
set(QML_IMPORT_PATH
    ${CMAKE_SOURCE_DIR}/src;${QML_IMPORT_PATH}
    CACHE STRING "")


if (${STATUSQ_BUILD_SANDBOX})
    add_subdirectory(sandbox)
endif()

if (${STATUSQ_BUILD_SANITY_CHECKER})
    add_subdirectory(sanity_checker)
endif()

if (${STATUSQ_BUILD_TESTS})
    add_subdirectory(tests)
endif()

add_subdirectory(../../vendor/SortFilterProxyModel SortFilterProxyModel)
add_subdirectory(../../vendor/qzxing/src qzxing)

### StatusQ library
### TODO: Move to a subdirectory for readability and better structure

#qt5_add_big_resources(QRC_COMPILED
#        src/statusq.qrc
#        src/assets.qrc)

add_library(StatusQ SHARED
#        ${QRC_COMPILED}
        src/plugin.cpp
        src/statusq.qrc
        src/assets.qrc
        include/StatusQ/QClipboardProxy.h
        include/StatusQ/modelutilsinternal.h
        include/StatusQ/rxvalidator.h
        include/StatusQ/statussyntaxhighlighter.h
        include/StatusQ/statuswindow.h
        src/QClipboardProxy.cpp
        src/modelutilsinternal.cpp
        src/rxvalidator.cpp
        src/statussyntaxhighlighter.cpp
        src/statuswindow.cpp
        )

if(APPLE)
    find_library(AppKit AppKit)
    find_library(Foundation Foundation)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation})
    target_sources(StatusQ PRIVATE src/statuswindow_osx.mm)
else()
    target_sources(StatusQ PRIVATE src/statuswindow_other.cpp)
endif()

set(STATUSQ_QML_MODULE_BINARY_DIR ${CMAKE_BINARY_DIR}/bin/StatusQ)

set_target_properties(StatusQ PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${STATUSQ_QML_MODULE_BINARY_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${STATUSQ_QML_MODULE_BINARY_DIR}
        )

set(COPY_QMLDIR_COMMAND
        ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusQ/qmldir
        ${STATUSQ_QML_MODULE_BINARY_DIR}/qmldir)

add_custom_command(
        TARGET StatusQ
        POST_BUILD
        COMMAND ${COPY_QMLDIR_COMMAND}
        COMMENT "Copying qmldir to binary directory")


find_package(Qt5 COMPONENTS Core Qml Quick QuickControls2 REQUIRED)

target_link_libraries(StatusQ PRIVATE
        Qt5::Core
        Qt5::Qml
        Qt5::Quick
        Qt5::QuickControls2
        SortFilterProxyModel
        qzxing
        )

target_include_directories(StatusQ PRIVATE include)

install(TARGETS StatusQ
        LIBRARY DESTINATION StatusQ
        )

install(FILES src/StatusQ/qmldir
        DESTINATION StatusQ
        )