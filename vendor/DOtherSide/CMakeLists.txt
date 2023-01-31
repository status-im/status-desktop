cmake_minimum_required(VERSION 3.2)

project(DOtherSide)

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

add_subdirectory(doc)
add_subdirectory(lib)
add_subdirectory(test)
