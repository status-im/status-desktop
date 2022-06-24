# Provide general project configuration setup
#
cmake_minimum_required(VERSION 3.21)

set(STATUS_QT_VERSION 6.3)
set(STATUS_VERSION 0.6.0)

project(status-desktop
  VERSION ${STATUS_VERSION}
  LANGUAGES CXX)

include(cmake/config_common.cmake)
include(CTest)
enable_testing()

if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64" AND APPLE)
  set(STATUSGO_FORCE_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

# status-desktop application
add_subdirectory(vendor)
add_subdirectory(libs)
add_subdirectory(app)
add_subdirectory(test)
# TODO: temporary not to duplicate resources until we switch to c++ app then it can be refactored
add_subdirectory(ui/imports/assets)
