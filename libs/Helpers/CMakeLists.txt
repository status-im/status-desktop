# Light helpers library expected to be used by all other libraries
#
cmake_minimum_required(VERSION 3.21)

project(Helpers
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

add_library(${PROJECT_NAME} SHARED "")

# Setup configuration type (Debug/Release)
# Inspired by https://programmingrecluse.wordpress.com/2020/02/04/detect-debug-build-with-cmake/
if(CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES Debug Release)
elseif(NOT CMAKE_BUILD_TYPE)
    message("Missing Build Type! Run cmake with:\n-DCMAKE_BUILD_TYPE=Debug|Release")
endif()

# Use by linker only
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug)

# Setup BUILD_DEBUG and BUILD_REALEASE if single configuration builds
if(CMAKE_BUILD_TYPE)
    string(TOUPPER "${CMAKE_BUILD_TYPE}" _upper_build_type)
    set(BUILD_${_upper_build_type} true)
endif()

set(BUILD_GENERATED_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/generated)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/template/BuildConfiguration.h.in"
               "${BUILD_GENERATED_DIRECTORY}/Helpers/BuildConfiguration.h"
               @ONLY)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${BUILD_GENERATED_DIRECTORY}
    PRIVATE
        ${BUILD_GENERATED_DIRECTORY}/Helpers
)

target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/template/BuildConfiguration.h.in
)

add_subdirectory(src)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)