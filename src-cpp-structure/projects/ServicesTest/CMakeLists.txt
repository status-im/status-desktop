cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(Status.ServicesTest DESCRIPTION "Test Status Services Project")

SET(STATUS_RCC ${CMAKE_SOURCE_DIR}/../resources.rcc)
SET(STATUS_QRC ${CMAKE_SOURCE_DIR}/../ui/resources.qrc)
SET(STATUS_RESOURCES_QRC ${CMAKE_SOURCE_DIR}/../resources/resources.qrc)

conan_basic_setup(KEEP_RPATHS)

add_executable(${PROJECT_NAME})

add_dependencies(${PROJECT_NAME} Status.Services)

target_link_libraries(
    ${PROJECT_NAME}
    Qt5::Core
    ${CONAN_LIBS_GTEST}
    ${FOUNDATION_FRAMEWORK}
    ${IO_KIT_FRAMEWORK}
    Status.Services
    )

file(GLOB_RECURSE SOURCES
    "*.h"
    "*.cpp"
    ${STATUS_RCC}
    ${STATUS_RESOURCES_QRC}
    ${STATUS_QRC}
    )

target_sources(${PROJECT_NAME} PRIVATE ${SOURCES})
