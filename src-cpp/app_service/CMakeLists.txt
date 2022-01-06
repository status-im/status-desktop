add_library(app_service
    constants.cpp
    service/accounts/dto/account.cpp
    service/accounts/dto/generated_account.cpp
    service/accounts/service.cpp
)

target_include_directories(app_service
    PUBLIC
        include
)

# default token is a free-tier token with limited capabilities and usage
# limits; setup your own infura key with
# cmake -DINFURA_KEY=infura_key_goes_here ..
if( "${INFURA_KEY}" STREQUAL "")
    message("-- Using default Infura key")
    file (STRINGS "../../resources/infura_key" INFURA_KEY)
else()
    message("-- Using custom Infura key")
endif()

# Build constants
target_compile_definitions(app_service
    PRIVATE
        INFURA_KEY="${INFURA_KEY}"
)

target_link_libraries(app_service
    PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        backend
)
