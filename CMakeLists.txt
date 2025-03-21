cmake_minimum_required(VERSION 3.19)
project(StatusDesktop)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if (APPLE)
    set(MACOS_VERSION_MIN_FLAGS -mmacosx-version-min=11.0)
endif()

set(STATUSQ_SHADOW_BUILD ON)
set(STATUSQ_BUILD_SANDBOX OFF)
set(STATUSQ_BUILD_SANITY_CHECKER OFF)
set(STATUSQ_BUILD_TESTS OFF)

find_package(QT NAMES Qt5 Qt6 REQUIRED COMPONENTS Core)
find_package(OpenSSL REQUIRED)

find_package(Qt${QT_VERSION_MAJOR} COMPONENTS
    Core Gui Quick QuickControls2 Widgets Test Multimedia WebChannel Svg
    QuickTest Qml WebView REQUIRED)

add_subdirectory(ui/StatusQ)

add_executable(${PROJECT_NAME} main.cpp)
qt_add_binary_resources(resources ${CMAKE_SOURCE_DIR}/ui/resources.qrc)

set(VENDOR_DIR "${CMAKE_SOURCE_DIR}/vendor")

set(STATUSCLIENT_LOCATION
    "${CMAKE_SOURCE_DIR}/bin/${CMAKE_STATIC_LIBRARY_PREFIX}nim_status_client${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(DOTHERSIDE_LOCATION
    "${VENDOR_DIR}/DOtherSide/build/lib/${CMAKE_STATIC_LIBRARY_PREFIX}DOtherSideStatic${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(QRCODEGEN_LOCATION
    "${VENDOR_DIR}/QR-Code-generator/c/${CMAKE_STATIC_LIBRARY_PREFIX}qrcodegen${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(STATUSGO_LOCATION
    "${VENDOR_DIR}/status-go/build/bin/${CMAKE_SHARED_LIBRARY_PREFIX}status${CMAKE_SHARED_LIBRARY_SUFFIX}")
set(STATUSKEYCARD_LOCATION
    "${VENDOR_DIR}/status-keycard-go/build/libkeycard/${CMAKE_SHARED_LIBRARY_PREFIX}keycard${CMAKE_SHARED_LIBRARY_SUFFIX}")

find_program(MAKE_EXE NAMES gmake nmake make)

add_custom_target(BuildStatusDekstopLib ALL
  BYPRODUCTS
    ${STATUSCLIENT_LOCATION}
    ${DOTHERSIDE_LOCATION}
    ${QRCODEGEN_LOCATION}
    ${STATUSGO_LOCATION}
    ${STATUSKEYCARD_LOCATION}
    ${CMAKE_SOURCE_DIR}/ui/resources.qrc
  COMMAND ${MAKE_EXE} nim_status_lib
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Building nim_status_lib"
)

add_library(DOtherSideStatic STATIC IMPORTED)
set_target_properties(DOtherSideStatic PROPERTIES IMPORTED_LOCATION ${DOTHERSIDE_LOCATION})

add_library(qrcodegen STATIC IMPORTED)
set_target_properties(qrcodegen PROPERTIES IMPORTED_LOCATION ${QRCODEGEN_LOCATION})

add_library(StatusGo SHARED IMPORTED)
set_target_properties(StatusGo PROPERTIES IMPORTED_LOCATION ${STATUSGO_LOCATION})

add_library(StatusKeycard SHARED IMPORTED)
set_target_properties(StatusKeycard PROPERTIES IMPORTED_LOCATION ${STATUSKEYCARD_LOCATION})

add_library(StatusDesktopLib STATIC IMPORTED)

set_target_properties(StatusDesktopLib PROPERTIES
    IMPORTED_LOCATION ${STATUSCLIENT_LOCATION}
    INTERFACE_LINK_LIBRARIES "rt;m;pthread;dl;pcre;StatusGo;StatusKeycard;qrcodegen;DOtherSideStatic;OpenSSL::SSL;OpenSSL::Crypto"
)

add_dependencies(StatusDesktopLib BuildStatusDekstopLib)

target_link_libraries(
    ${PROJECT_NAME} PUBLIC StatusDesktopLib
        Qt::Core Qt::Qml Qt::Gui Qt::Quick Qt::QuickControls2 Qt::Widgets
        Qt::Svg Qt::Multimedia Qt::WebView Qt::WebChannel
    StatusQ
)

file(GLOB_RECURSE NIM_SRC_FILES ${PROJECT_SOURCE_DIR}/src *.nim)
add_custom_target(nim SOURCES ${NIM_SRC_FILES})

add_custom_command(
        TARGET BuildStatusDekstopLib POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_SOURCE_DIR}/fleets.json"
                "${CMAKE_CURRENT_BINARY_DIR}")
