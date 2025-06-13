project(SanityChecker)

find_package(Qt${QT_VERSION_MAJOR}
        COMPONENTS Core Quick
        REQUIRED)

add_executable(${PROJECT_NAME}
        main.cpp
        )

target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt::Core
        Qt::Quick
        StatusQ)

target_compile_definitions(${PROJECT_NAME} PRIVATE
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )

if (STATUSQ_SHADOW_BUILD)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
            STATUSQ_SHADOW_BUILD
            )
endif ()

# Add support for excluding files from sanity checking
if (DEFINED STATUSQ_SANITY_CHECKER_EXCLUDE_FILES AND NOT "${STATUSQ_SANITY_CHECKER_EXCLUDE_FILES}" STREQUAL "")
    # Convert semicolon-separated list to comma-separated for C++ array
    string(REPLACE ";" "\",\"" EXCLUDE_FILES_FORMATTED "${STATUSQ_SANITY_CHECKER_EXCLUDE_FILES}")
    target_compile_definitions(${PROJECT_NAME} PRIVATE
            STATUSQ_EXCLUDE_FILES="${EXCLUDE_FILES_FORMATTED}"
            )
endif ()
