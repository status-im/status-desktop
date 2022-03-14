target_link_libraries(
    ${PROJECT_NAME} PRIVATE
    Qt5::Core
    Status.Backend
    )

file(GLOB_RECURSE SOURCES
    "*.h"
    "*.cpp"
    )
