# Light helpers library expected to be used by all other libraries
#
cmake_minimum_required(VERSION 3.21)

project(Helpers
    VERSION 0.1.0
    LANGUAGES CXX)

find_package(nlohmann_json 3.10.5 REQUIRED)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

add_library(Helpers SHARED)
add_library(Status::Helpers ALIAS Helpers)

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

target_include_directories(Helpers
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${BUILD_GENERATED_DIRECTORY}

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers
        ${BUILD_GENERATED_DIRECTORY}/Helpers
)

target_link_libraries(Helpers
    PUBLIC
        nlohmann_json::nlohmann_json

    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

install(
    TARGETS
        Helpers
    RUNTIME
)

target_sources(Helpers
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/conversions.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/conversions.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/helpers.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/logs.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/logs.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/NamedType.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Helpers/Singleton.h
)
