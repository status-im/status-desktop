set(CONAN_WORKING_DIR ${CMAKE_BINARY_DIR}/conan)

if (EXISTS ${CONAN_WORKING_DIR})
    file(REMOVE_RECURSE ${CONAN_WORKING_DIR})
endif ()

file(MAKE_DIRECTORY ${CONAN_WORKING_DIR})

if (${CMAKE_BUILD_TYPE} STREQUAL Debug)
    set(CONAN_PROFILE ${PROJECT_SOURCE_DIR}/conan-debug-profile)
else ()
    set(CONAN_PROFILE ${PROJECT_SOURCE_DIR}/conan-release-profile)
endif ()

execute_process(
    COMMAND conan install ${PROJECT_SOURCE_DIR} -pr=${CONAN_PROFILE}
    WORKING_DIRECTORY ${CONAN_WORKING_DIR}
    RESULT_VARIABLE CONAN_RESULT
    )

if (NOT ${CONAN_RESULT} EQUAL 0)
    message(FATAL_ERROR "Conan failed: ${CONAN_RESULT}.")
endif ()

include(${CONAN_WORKING_DIR}/conanbuildinfo.cmake)

conan_basic_setup(KEEP_RPATHS)
