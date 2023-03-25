project(sanity_checker)

find_package(Qt5
        COMPONENTS Core Quick
        REQUIRED)

add_executable(sanity_checker
        main.cpp
        )

target_link_libraries(sanity_checker PRIVATE
        Qt5::Core
        Qt5::Quick)
