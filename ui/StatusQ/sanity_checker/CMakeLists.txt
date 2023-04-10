project(SanityChecker)

find_package(Qt5
        COMPONENTS Core Quick
        REQUIRED)

add_executable(${PROJECT_NAME}
        main.cpp
        )

target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt5::Core
        Qt5::Quick)
