cmake_minimum_required(VERSION 3.19)

project(StatusQ)

option(STATUSQ_BUILD_SANDBOX "Enable to build StatusQ Sandbox application" ON)
option(STATUSQ_BUILD_SANITY_CHECKER "Enable to build StatusQ Sanity Checker application" ON)
option(STATUSQ_BUILD_TESTS "Enable to build StatusQ UI auto tests" ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Although SHARED libraries set this to ON by default,
# all static libraries, that are built into this SHARED,
# (which is qzxing in our case) should also be build with -fPIC.
# This fixes it.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(QZXING_USE_QML ON)
set(QZXING_MULTIMEDIA ON)
set(QZXING_USE_DECODER_QR_CODE ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(Qt5 COMPONENTS
        Core Qml Gui Quick QuickControls2 REQUIRED)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_package(Qt5 COMPONENTS QuickTest REQUIRED)
endif()

add_subdirectory(../../vendor/SortFilterProxyModel SortFilterProxyModel)
add_subdirectory(../../vendor/qzxing/src qzxing)

target_compile_options(qzxing PRIVATE -w)
target_compile_options(SortFilterProxyModel PRIVATE -w)

### StatusQ library
### TODO: Move to a subdirectory for readability and better structure

if (NOT DEFINED STATUSQ_SHADOW_BUILD)

    #   About the STATUSQ_SHADOW_BUILD option.
    #
    #   This is an option that defaults to OFF in Debug mode and ON otherwise.
    #   When ON:
    #     - resources are compiled into plugin
    #     - plugin is compiled in the ${CMAKE_BINARY_DIR}/StatusQ
    #   When OFF:
    #     - no resources are compiled, it's expected to use QML/JS sources
    #     - the plugin is compiled in src directory
    #
    #   STATUSQ_SHADOW_BUILD mode is created for sandbox/storybook hot reloading
    #   without copying all qml files to build directory.
    #
    #   It's expected for the app to add ${STATUSQ_MODULE_IMPORT_PATH} to
    #   QQmlApplicationEngine::addImportPath.
    #

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(STATUSQ_SHADOW_BUILD OFF)
    else()
        set(STATUSQ_SHADOW_BUILD ON)
    endif()
endif()

set(STATUSQ_SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src/StatusQ")

if (${STATUSQ_SHADOW_BUILD})
    set(STATUSQ_MODULE_PATH "${CMAKE_BINARY_DIR}/bin/StatusQ")
    set(STATUSQ_MODULE_IMPORT_PATH ":/")
else()
    set(STATUSQ_MODULE_PATH "${STATUSQ_SOURCE_PATH}")
    set(STATUSQ_MODULE_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src")
endif()

if (NOT PROJECT_IS_TOP_LEVEL)
    set(STATUSQ_MODULE_PATH "${STATUSQ_MODULE_PATH}" PARENT_SCOPE)
    set(STATUSQ_MODULE_IMPORT_PATH "${STATUSQ_MODULE_IMPORT_PATH}" PARENT_SCOPE)
    set(STATUSQ_SHADOW_BUILD "${STATUSQ_SHADOW_BUILD}" PARENT_SCOPE)
endif ()

if (${STATUSQ_SHADOW_BUILD})
    qt5_add_big_resources(STATUSQ_QRC_COMPILED
            src/statusq.qrc
            src/assets.qrc)
endif()

add_library(StatusQ SHARED
        ${STATUSQ_QRC_COMPILED}
        include/StatusQ/QClipboardProxy.h
        include/StatusQ/aggregator.h
        include/StatusQ/concatmodel.h
        include/StatusQ/fastexpressionfilter.h
        include/StatusQ/fastexpressionrole.h
        include/StatusQ/fastexpressionsorter.h
        include/StatusQ/formatteddoubleproperty.h
        include/StatusQ/leftjoinmodel.h
        include/StatusQ/modelutilsinternal.h
        include/StatusQ/movablemodel.h
        include/StatusQ/permissionutilsinternal.h
        include/StatusQ/rolesrenamingmodel.h
        include/StatusQ/rxvalidator.h
        include/StatusQ/singleroleaggregator.h
        include/StatusQ/statussyntaxhighlighter.h
        include/StatusQ/statuswindow.h
        include/StatusQ/stringutilsinternal.h
        include/StatusQ/submodelproxymodel.h
        include/StatusQ/sumaggregator.h
        include/StatusQ/undefinedfilter.h
        include/StatusQ/writableproxymodel.h
        src/QClipboardProxy.cpp
        src/aggregator.cpp
        src/concatmodel.cpp
        src/fastexpressionfilter.cpp
        src/fastexpressionrole.cpp
        src/fastexpressionsorter.cpp
        src/formatteddoubleproperty.cpp
        src/leftjoinmodel.cpp
        src/modelutilsinternal.cpp
        src/movablemodel.cpp
        src/permissionutilsinternal.cpp
        src/plugin.cpp
        src/rolesrenamingmodel.cpp
        src/rxvalidator.cpp
        src/singleroleaggregator.cpp
        src/statussyntaxhighlighter.cpp
        src/statuswindow.cpp
        src/stringutilsinternal.cpp
        src/submodelproxymodel.cpp
        src/sumaggregator.cpp
        src/undefinedfilter.cpp
        src/writableproxymodel.cpp

        # wallet
        src/wallet/managetokenscontroller.cpp
        src/wallet/managetokenscontroller.h
        src/wallet/managetokensmodel.cpp
        src/wallet/managetokensmodel.h
        src/wallet/tokendata.cpp
        src/wallet/tokendata.h
        )

target_compile_features(StatusQ PRIVATE cxx_std_17)

set_target_properties(StatusQ PROPERTIES
    ADDITIONAL_CLEAN_FILES bin/StatusQ/qmldir
    RUNTIME_OUTPUT_DIRECTORY ${STATUSQ_MODULE_PATH}
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${STATUSQ_MODULE_PATH}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${STATUSQ_MODULE_PATH}
    LIBRARY_OUTPUT_DIRECTORY ${STATUSQ_MODULE_PATH}
)

if (APPLE)
    find_library(AppKit AppKit)
    find_library(Foundation Foundation)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation})
    target_sources(StatusQ PRIVATE src/statuswindow_osx.mm)
else ()
    target_sources(StatusQ PRIVATE src/statuswindow_other.cpp)
endif ()

if (${STATUSQ_SHADOW_BUILD})
    set(COPY_QMLDIR_COMMAND
            ${CMAKE_COMMAND} -E copy
            ${STATUSQ_SOURCE_PATH}/qmldir
            ${STATUSQ_MODULE_PATH}/qmldir)
    add_custom_command(
            TARGET StatusQ
            POST_BUILD
            COMMAND ${COPY_QMLDIR_COMMAND}
            COMMENT "Copying qmldir to binary directory")
endif ()

target_link_libraries(StatusQ PRIVATE
        Qt5::Core
        Qt5::Qml
        Qt5::Gui
        Qt5::Quick
        Qt5::QuickControls2
        SortFilterProxyModel
        qzxing
        )

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_libraries(StatusQ PRIVATE
            Qt5::QuickTest
            )
endif()

target_include_directories(StatusQ PUBLIC include)

install(TARGETS StatusQ
        RUNTIME DESTINATION StatusQ
        LIBRARY DESTINATION StatusQ
        )

install(FILES src/StatusQ/qmldir
        DESTINATION StatusQ
        )

# https://doc.qt.io/qtcreator/creator-qml-modules-with-plugins.html#importing-qml-modules
set(QML_IMPORT_PATH
        ${CMAKE_SOURCE_DIR}/src;${QML_IMPORT_PATH}
        CACHE STRING "")

### Add other subdirectories

if (${STATUSQ_BUILD_SANDBOX})
    add_subdirectory(sandbox)
endif ()

if (${STATUSQ_BUILD_SANITY_CHECKER})
    add_subdirectory(sanity_checker)
endif ()

if (${STATUSQ_BUILD_TESTS})
    enable_testing()
    add_subdirectory(tests)
endif ()
