cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(Status.App DESCRIPTION "Main Status App Project")

include("${CMAKE_SOURCE_DIR}/cmake/translation.cmake")

# Building resource.rcc from multiple .qrc files
SET(STATUS_RCC ${CMAKE_SOURCE_DIR}/../resources.rcc)
SET(STATUS_QRC_SOURCE ${CMAKE_SOURCE_DIR}/../ui)
SET(STATUS_QRC ${STATUS_QRC_SOURCE}/resources.qrc)
SET(STATUS_RESOURCES_QRC ${CMAKE_SOURCE_DIR}/../resources/resources.qrc)

add_custom_target(rcc ALL DEPENDS resources.rcc)
add_custom_command(
    OUTPUT resources.rcc
    COMMENT "Building resources.rcc"
    COMMAND ${CMAKE_COMMAND} -E rm -f ${STATUS_RCC}
    COMMAND ${CMAKE_COMMAND} -E rm -f ${STATUS_QRC}
    COMMAND go run ${CMAKE_SOURCE_DIR}/../ui/generate-rcc.go -source=${STATUS_QRC_SOURCE} -output=${STATUS_QRC}
    COMMAND rcc -binary --no-compress ${STATUS_QRC} ${STATUS_RESOURCES_QRC} -o ${STATUS_RCC}
    VERBATIM
    USES_TERMINAL
    PRE_BUILD
)

# Platform specific stuff are place in the corresponding .cmake file.
if (WIN32)
    include("${CMAKE_SOURCE_DIR}/cmake/app-win.cmake")
elseif (APPLE)
    include("${CMAKE_SOURCE_DIR}/cmake/app-mac.cmake")
elseif(UNIX)
    include("${CMAKE_SOURCE_DIR}/cmake/app-linux.cmake")
endif ()

check_translations()

target_sources(${PROJECT_NAME} PRIVATE ${SOURCES})
