cmake_minimum_required(VERSION 3.19)

project(StatusQ)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# add_subdirectory(src)
add_subdirectory(sandbox)
add_subdirectory(tests)
