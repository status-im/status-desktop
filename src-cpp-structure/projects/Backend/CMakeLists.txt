cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(Status.Backend DESCRIPTION "Status project used to integrate with status-go")

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(${PROJECT_NAME} SHARED)

file(
  GLOB_RECURSE SOURCES
  "*.h"
  "*.cpp"
)

target_sources(${PROJECT_NAME} PRIVATE ${SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC include)

target_link_libraries(
    ${PROJECT_NAME}
    Qt5::Core
    ${STATUS_GO_LIB}
)
