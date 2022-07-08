target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)

add_subdirectory(Application)
