cmake_minimum_required(VERSION 3.19)

project(DOtherSide)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(ENABLE_DOCS "Enable docs" ON)
option(ENABLE_TESTS "Enable tests" ON)
option(ENABLE_DYNAMIC_LIBS "Enable dynamic libraries" ON)
option(ENABLE_STATIC_LIBS "Enable static libraries" ON)

# Add additional source path for cmake
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/)

# Add strict warning checking for C++
if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
    # Add Coverage option
    option(ENABLE_COVERAGE "Enable coverage" OFF)

    add_compile_options(-Wall -Wno-long-long -pedantic)

    if (ENABLE_COVERAGE)
        message(STATUS "Enabling coverage")
        set(CMAKE_BUILD_TYPE Debug)
        add_compile_options(-g -O0 --coverage)
        add_link_options(--coverage)
    endif()
endif()

add_subdirectory(lib)

if(ENABLE_DOCS)
    add_subdirectory(doc)
endif()

if(ENABLE_TESTS)
    add_subdirectory(test)
endif()

