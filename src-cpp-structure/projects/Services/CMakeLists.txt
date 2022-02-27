cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(Status.Services DESCRIPTION "Status services")

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(${PROJECT_NAME} SHARED)

# Platform specific stuff are place in the corresponding .cmake file.
if (WIN32)
    include("${CMAKE_SOURCE_DIR}/cmake/services-win.cmake")
elseif (APPLE)
    include("${CMAKE_SOURCE_DIR}/cmake/services-mac.cmake")
elseif(UNIX)
    include("${CMAKE_SOURCE_DIR}/cmake/services-linux.cmake")
endif ()

target_sources(${PROJECT_NAME} PRIVATE ${SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC include)

# default token is a free-tier token with limited capabilities and usage
# limits; setup your own infura key with
# cmake -DINFURA_KEY=infura_key_goes_here ..
if( "${INFURA_KEY}" STREQUAL "")
    message("-- Using default Infura key")
    file (STRINGS ${CMAKE_SOURCE_DIR}/../resources/infura_key INFURA_KEY)
else()
    message("-- Using custom Infura key")
endif()

# Build constants
target_compile_definitions(${PROJECT_NAME} PRIVATE INFURA_KEY="${INFURA_KEY}")
