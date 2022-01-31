cmake_minimum_required(VERSION 3.14)

project(status-desktop
  VERSION 0.1.0
  LANGUAGES CXX)

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

message(STATUS "Started CMake for ${PROJECT_NAME} v${PROJECT_VERSION}...\n")

include(ExternalProject)

# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check https://doc.qt.io/qt/deployment-android.html for more information.
# They need to be set before the find_package(...) calls below.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Quick Widgets Concurrent REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Quick Widgets Concurrent REQUIRED)

set(PROJECT_SOURCES
        src-cpp/main.cpp
        src-cpp/constants.cpp
        src-cpp/logs.cpp
        resources.rcc
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(status-desktop
        ${PROJECT_SOURCES}
    )
else()
    if(ANDROID)
        add_library(status-desktop SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(status-desktop
          ${PROJECT_SOURCES}
        )
    endif()
endif()


add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/vendor/status-lib/vendor/status-go bin/status-go)

# The following are dependencies that do not include CMakeList.txt files
# Create a PR in those projects so we can include them just like it was
# done with status-go
include(cmake/QRCodeGen.cmake)
include(cmake/Keycard.cmake)

# Submodiles
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src-cpp/dotherside)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src-cpp/app)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src-cpp/app_service)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src-cpp/backend)

target_include_directories(status-desktop PUBLIC include)


target_compile_definitions(status-desktop
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(status-desktop
  PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Widgets
    DOtherSide
    statusgo_shared # <- Link status-go with this target (remove `_shared` for static linking)
    qrcodegen
    keycard
    app_service
    app
  )


add_custom_target(rcc ALL DEPENDS resources.rcc)
add_custom_command(
    OUTPUT resources.rcc
    COMMENT "Building resources.rcc"
    COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_CURRENT_SOURCE_DIR}/resources.rcc
    COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_CURRENT_SOURCE_DIR}/ui/resources.qrc
    COMMAND go run ${CMAKE_CURRENT_SOURCE_DIR}/ui/generate-rcc.go -source=${CMAKE_CURRENT_SOURCE_DIR}/ui -output=${CMAKE_CURRENT_SOURCE_DIR}/ui/resources.qrc
    COMMAND rcc -binary $<$<CONFIG:Debug>:"-binary --no-compress">$<$<CONFIG:Release>:-binary> ${CMAKE_CURRENT_SOURCE_DIR}/ui/resources.qrc ${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.qrc -o ${CMAKE_CURRENT_SOURCE_DIR}/resources.rcc
    VERBATIM
    USES_TERMINAL
)


# run
add_custom_target(run
  COMMENT "Execute desktop"
  DEPENDS status-desktop
  COMMAND  ./status-desktop
  VERBATIM
  USES_TERMINAL
)


# run debug
add_custom_target(run-debug
  COMMENT "Execute desktop with debugger on port 1234"
  DEPENDS status-desktop
  COMMAND  ./status-desktop -qmljsdebugger=port:1234
  VERBATIM
  USES_TERMINAL
)

include(CTest)
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME AND BUILD_TESTING)
    add_subdirectory(test-cpp)
endif()
