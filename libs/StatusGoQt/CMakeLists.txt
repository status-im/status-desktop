# Light helpers library expected to be used by all other libraries
#
cmake_minimum_required(VERSION 3.21)

project(StatusGoQt
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Core REQUIRED)
qt6_standard_project_setup()

add_library(${PROJECT_NAME} SHARED "")

# Use by linker only
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug)

add_subdirectory(src)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Core

        statusgo_shared
)

# Copy status-go lib close to the executable
# Temporary workaround; TODO: see a better alternative that doesn't depend on target order (dedicated dependencies dir?)
get_target_property(STATUSGO_LIBRARY_PATH statusgo_shared IMPORTED_LOCATION)
configure_file(${STATUSGO_LIBRARY_PATH} ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
