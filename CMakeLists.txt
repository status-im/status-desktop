# Provide general project configuration setup
#
cmake_minimum_required(VERSION 3.21)

set(STATUS_QT_VERSION 6.3)
set(STATUS_VERSION 0.6.0)

project(status-desktop
  VERSION ${STATUS_VERSION}
  LANGUAGES CXX)

set(PROJECT_ORGANIZATION_DOMAIN "status.im")
set(PROJECT_ORGANIZATION_NAME "Status")
set(PROJECT_APPLICATION_NAME "Status Desktop")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

include(CTest)
enable_testing()

if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64" AND APPLE)
  set(STATUSGO_FORCE_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

# status-desktop application
add_subdirectory(vendor)

add_subdirectory(libs/ApplicationCore)
add_subdirectory(libs/Assets)
add_subdirectory(libs/Helpers)
add_subdirectory(libs/Onboarding)
add_subdirectory(libs/StatusGoQt)
add_subdirectory(libs/StatusQ)

add_subdirectory(app)

add_subdirectory(test/libs/StatusGoQt)

# TODO: temporary not to duplicate resources until we switch to c++ app then it can be refactored
add_subdirectory(resources)
add_subdirectory(ui/imports/assets)
add_subdirectory(ui/fonts)
