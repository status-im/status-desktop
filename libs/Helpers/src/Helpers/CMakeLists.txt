target_sources(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/helpers.h
        ${CMAKE_CURRENT_SOURCE_DIR}/logs.h
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/logs.cpp
)
