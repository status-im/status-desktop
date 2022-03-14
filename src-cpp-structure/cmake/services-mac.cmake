find_library(FOUNDATION_FRAMEWORK Foundation)
find_library(IO_KIT_FRAMEWORK IOKit)
find_library(SECURITY_FRAMEWORK Security)
find_library(CORE_SERVICES_FRAMEWORK CoreServices)
find_library(LOCAL_AUTHENTICATION_FRAMEWORK LocalAuthentication)

target_link_libraries(
    ${PROJECT_NAME} PRIVATE
    Qt5::Core
    ${FOUNDATION_FRAMEWORK}
    ${IO_KIT_FRAMEWORK}
    ${SECURITY_FRAMEWORK}
    ${CORE_SERVICES_FRAMEWORK}
    ${LOCAL_AUTHENTICATION_FRAMEWORK}
    Status.Backend
    )

file(GLOB_RECURSE SOURCES
    "*.h"
    "*.cpp"
    "*.mm"
    )
