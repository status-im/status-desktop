# Required by QML_ELEMENT
target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/ApplicationController.h
        ${CMAKE_CURRENT_SOURCE_DIR}/ApplicationController.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)
