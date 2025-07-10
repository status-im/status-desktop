cmake_minimum_required(VERSION 3.19)

project(StatusQ)

option(STATUSQ_BUILD_SANDBOX "Enable to build StatusQ Sandbox application" ON)
option(STATUSQ_BUILD_SANITY_CHECKER "Enable to build StatusQ Sanity Checker application" ON)
option(STATUSQ_BUILD_TESTS "Enable to build StatusQ UI auto tests" ON)
option(STATUSQ_STATIC_LIB "Enable to build StatusQ as a static library" OFF)

# Allow files to be excluded
set(STATUSQ_SANITY_CHECKER_EXCLUDE_FILES "" CACHE STRING "Semicolon-separated list of files to exclude from sanity checker")


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
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if(MSVC)
  add_definitions(/MP)
endif()

find_package(QT NAMES Qt5 Qt6 REQUIRED COMPONENTS Core)

find_package(Qt${QT_VERSION_MAJOR} COMPONENTS
        Core Qml Gui Quick QuickControls2 REQUIRED)

if (${QT_VERSION_MAJOR} EQUAL 6)
    find_package(Qt6 COMPONENTS Core5Compat REQUIRED)
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_package(Qt${QT_VERSION_MAJOR} COMPONENTS QuickTest REQUIRED)
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
    #     - resources are compiled into a shared library
    #   When OFF:
    #     - no resources are compiled, it's expected to use QML/JS sources
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
    set(STATUSQ_MODULE_IMPORT_PATH ":/")
else()
    set(STATUSQ_MODULE_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src")
endif()

if (NOT PROJECT_IS_TOP_LEVEL)
    set(STATUSQ_MODULE_IMPORT_PATH "${STATUSQ_MODULE_IMPORT_PATH}" PARENT_SCOPE)
    set(STATUSQ_SHADOW_BUILD "${STATUSQ_SHADOW_BUILD}" PARENT_SCOPE)
endif ()

if (${STATUSQ_STATIC_LIB})
    set(LIB_TYPE STATIC)
else()
    set(LIB_TYPE SHARED)
endif ()

if (${STATUSQ_SHADOW_BUILD})
    add_definitions(-DBUNDLE_QML_RESOURCES)
    set(STATUSQ_QRC_FILES src/statusq.qrc
        src/assets/fonts/fonts.qrc
        src/assets/img/img.qrc
        src/assets/png/png.qrc
        src/assets/twemoji/twemoji.qrc
        src/assets/twemoji/twemoji-big.qrc
        src/assets/twemoji/twemoji-svg.qrc)
    if (${STATUSQ_STATIC_LIB})
        # randlib would complain about the generated .o files. Generate cpp files instead.
        qt_add_resources(STATUSQ_QRC_COMPILED ${STATUSQ_QRC_FILES})
    else()
        qt_add_big_resources(STATUSQ_QRC_COMPILED ${STATUSQ_QRC_FILES})
    endif()
endif()

add_library(StatusQ ${LIB_TYPE}
        ${STATUSQ_QRC_COMPILED}
        include/StatusQ/audioutils.h
        include/StatusQ/clipboardutils.h
        include/StatusQ/constantrole.h
        include/StatusQ/fastexpressionfilter.h
        include/StatusQ/fastexpressionrole.h
        include/StatusQ/fastexpressionsorter.h
        include/StatusQ/formatteddoubleproperty.h
        include/StatusQ/genericvalidator.h
        include/StatusQ/keychain.h
        include/StatusQ/networkchecker.h
        include/StatusQ/permissionutilsinternal.h
        include/StatusQ/rxvalidator.h
        include/StatusQ/statusemojimodel.h
        include/StatusQ/statussyntaxhighlighter.h
        include/StatusQ/statuswindow.h
        include/StatusQ/stringutilsinternal.h
        include/StatusQ/systemutilsinternal.h
        include/StatusQ/typesregistration.h
        include/StatusQ/undefinedfilter.h
        include/StatusQ/urlutils.h
        src/audioutils.cpp
        src/clipboardutils.cpp
        src/constantrole.cpp
        src/externc.cpp
        src/fastexpressionfilter.cpp
        src/fastexpressionrole.cpp
        src/fastexpressionsorter.cpp
        src/formatteddoubleproperty.cpp
        src/genericvalidator.cpp
        src/keychain.cpp
        src/networkchecker.cpp
        src/permissionutilsinternal.cpp
        src/rxvalidator.cpp
        src/statusemojimodel.cpp
        src/statussyntaxhighlighter.cpp
        src/statuswindow.cpp
        src/stringutilsinternal.cpp
        src/systemutilsinternal.cpp
        src/typesregistration.cpp
        src/undefinedfilter.cpp
        src/urlutils.cpp

        # wallet
        src/wallet/managetokenscontroller.cpp
        src/wallet/managetokenscontroller.h
        src/wallet/managetokensmodel.cpp
        src/wallet/managetokensmodel.h
        src/wallet/tokendata.cpp
        src/wallet/tokendata.h

        # onboarding
        src/onboarding/enums.h
        )

target_compile_features(StatusQ PRIVATE cxx_std_17)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    find_library(AppKit AppKit)
    find_library(Foundation Foundation)
    find_library(Security Security)
    find_library(LocalAuthentication LocalAuthentication)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation} ${Security} ${LocalAuthentication})
    target_sources(StatusQ PRIVATE
        src/statuswindow_osx.mm
        src/keychain_osx.mm
    )
else ()
    target_sources(StatusQ PRIVATE
        src/statuswindow_other.cpp
        src/keychain_other.cpp
    )
endif ()

include(FetchContent)
FetchContent_Declare(
  QtModelsToolkit
  GIT_REPOSITORY https://github.com/status-im/QtModelsToolkit.git
  GIT_TAG 99588ada4371dc639c46836b0fca1a880428ef7c
)

FetchContent_MakeAvailable(QtModelsToolkit)

target_link_libraries(StatusQ PRIVATE
        Qt::Core
        Qt::Qml
        Qt::Gui
        Qt::Quick
        Qt::QuickControls2
        $<$<EQUAL:${QT_VERSION_MAJOR},6>:Qt::Core5Compat>
        SortFilterProxyModel
        QtModelsToolkit
        qzxing
        )

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_libraries(StatusQ PRIVATE
            Qt::QuickTest
            )
endif()

target_include_directories(StatusQ PUBLIC include)

install(TARGETS StatusQ
        RUNTIME DESTINATION StatusQ
        LIBRARY DESTINATION StatusQ
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
