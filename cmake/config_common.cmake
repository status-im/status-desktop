set(PROJECT_ORGANIZATION_DOMAIN "status.im")
set(PROJECT_ORGANIZATION_NAME "Status")
set(PROJECT_APPLICATION_NAME "Status Desktop")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(NOT (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9"))
    set(SUPPORT_CPP14 1)
  endif()

  if(NOT (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0"))
    set(SUPPORT_CPP17 1)
  endif()

  if(NOT (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "9.1"))
    set(SUPPORT_CPP20 1)
  endif()
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(SUPPORT_CPP14 1)

  if(NOT (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0"))
    set(SUPPORT_CPP17 1)
  endif()
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  set(SUPPORT_CPP14 1)
  set(SUPPORT_CPP17 1)
#  set(SUPPORT_CPP20 1) not yet
endif()

if (MSVC)
  if (${MSVC_VERSION} GREATER 1899)
    set(SUPPORT_CPP14 1)
  endif()

  if (${MSVC_VERSION} GREATER 1909)
    set(SUPPORT_CPP17 1)
  endif()

  if (MSVC_VERSION GREATER 1928)
    set(SUPPORT_CPP20 1)
  endif()
endif()

function(print_supported_feature feature message)
    if(${feature})
        message(STATUS "Compiler supports \"${message}\": YES")
    else()
        message(STATUS "Compiler supports \"${message}\": NO")
    endif()
endfunction()

message("Set cmake version: " ${CMAKE_VERSION})
message("Set compiler version: " ${CMAKE_CXX_COMPILER_VERSION})
message("Set compiler id: " ${CMAKE_CXX_COMPILER_ID})

print_supported_feature(SUPPORT_CPP14 "C++14 support")
print_supported_feature(SUPPORT_CPP17 "C++17 support")
print_supported_feature(SUPPORT_CPP20 "C++20 support")

if(NOT (CMAKE_VERSION VERSION_GREATER_EQUAL "3.21.0"))
    message(FATAL_ERROR "cmake version must be at least 3.21.0")
endif()
if(NOT ${SUPPORT_CPP20})
    message(FATAL_ERROR "compiler must support C++20 for this project")
endif()

if(WIN32)
    include(${CMAKE_CURRENT_LIST_DIR}/platform_specific/windows.cmake)
elseif(APPLE)
    include(${CMAKE_CURRENT_LIST_DIR}/platform_specific/macos.cmake)
endif()
