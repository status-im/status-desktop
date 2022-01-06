add_library(backend
    accounts.cpp
    types.cpp
    utils.cpp
)

target_include_directories(backend
    PUBLIC
        include/
)

target_link_libraries(backend
    PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        statusgo_shared

)
