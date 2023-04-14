project(SanityChecker)

find_package(Qt5
        COMPONENTS Core Quick
        REQUIRED)

add_executable(${PROJECT_NAME}
        main.cpp
        )

add_dependencies(${PROJECT_NAME}
        StatusQ)

target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt5::Core
        Qt5::Quick)

target_compile_definitions(${PROJECT_NAME} PRIVATE
        STATUSQ_MODULE_PATH="${STATUSQ_MODULE_PATH}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )

if (STATUSQ_SHADOW_BUILD)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
            STATUSQ_SHADOW_BUILD
            )
endif ()