project(DOtherSide)

include(GNUInstallDirs)

option(MONITORING "Tools for real-time inspection of the application." OFF)
set(MONITORING_QML_ENTRY_POINT "" CACHE STRING "QML file intended to start the monitoring tool UI.")

if(MONITORING)
    include(../../../ui/MonitoringSources.cmake)
endif()

# Macro for merging common code between static and shared
macro(add_target name type)
    find_package(Qt5 COMPONENTS Core Qml Gui Quick QuickControls2 Widgets Network Multimedia WebView REQUIRED)

    file(GLOB HEADERS include/DOtherSide/*.h include/DOtherSide/Status/*.h)
    file(GLOB SOURCES src/*.cpp src/Status/*.cpp)

    if(APPLE)
        file(GLOB MM_FILES src/*.mm src/Status/*.mm)
        #prepend items because .mm files need build priority to override cpp impl
        list(PREPEND SOURCES ${MM_FILES})
    endif()

    add_library(${name} ${type}
        ${SOURCES} ${HEADERS}
        ${MONITORING_SOURCES} ${MONITORING_HEADERS}
    )

    if (WIN32)
        target_compile_definitions(${name} PRIVATE -DWIN32)
        target_compile_options(${name} PRIVATE /wd4996)
    endif()

    if (UNIX)
        target_compile_options(${name} PRIVATE -Wno-deprecated)
    endif()

    set_target_properties(${name} PROPERTIES CXX_STANDARD 17 AUTOMOC ON)

    target_include_directories(${name} PUBLIC include include/Qt)

    target_link_libraries(${name} PRIVATE Qt5::Core Qt5::Gui Qt5::Widgets Qt5::Qml Qt5::Quick Qt5::Network Qt5::Multimedia Qt5::WebView)

    target_compile_definitions(${name} PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)
    if(DEFINED QML_DEBUG_PORT)
        target_compile_definitions(${name} PRIVATE QML_DEBUG_PORT=${QML_DEBUG_PORT})
    endif()

    if(APPLE)
        find_library(AppKit AppKit)
        find_library(Foundation Foundation)
        find_library(Security Security)
        find_library(LocalAuthentication LocalAuthentication)
        target_link_libraries(${name} PRIVATE ${AppKit} ${Foundation} ${Security} ${LocalAuthentication})
    endif()

    if(MONITORING)
        target_include_directories(${name} PUBLIC ${MONITORING_INCLUDE_PATH})

        target_compile_definitions(${name} PRIVATE MONITORING)
        target_compile_definitions(${name} PRIVATE MONITORING_QML_ENTRY_POINT="${MONITORING_QML_ENTRY_POINT}")
    endif()

    # for DOtherSide.pc
    set(PC_REQUIRES "Qt5Core, Qt5Gui, Qt5Widgets, Qt5Qml, Qt5Quick, Qt5Network, Qt5DBus, Qt5Multimedia, Qt5WebView")
    if (${Qt5QuickControls2_FOUND})
        target_link_libraries(${name} PRIVATE Qt5::QuickControls2)
        set(PC_REQUIRES "${PC_REQUIRES}, Qt5QuickControls2")
    endif()
endmacro()

set(major 0)
set(minor 6)
set(patch 4)
set(DOTHERSIDE_VERSION "${major}.${minor}.${patch}")

# Add shared version
if(ENABLE_DYNAMIC_LIBS)
    add_target(${PROJECT_NAME} SHARED)
    set_target_properties(${PROJECT_NAME}
        PROPERTIES
        SOVERSION "${major}.${minor}"
        VERSION "${major}.${minor}.${patch}"
    )
    install(TARGETS ${PROJECT_NAME}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
endif(ENABLE_DYNAMIC_LIBS)

# Add static version
if(ENABLE_STATIC_LIBS)
    add_target(${PROJECT_NAME}Static STATIC)
    install(TARGETS ${PROJECT_NAME}Static
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
endif(ENABLE_STATIC_LIBS)

# Install directive for header files
install(FILES
    include/DOtherSide/DOtherSide.h
    include/DOtherSide/DOtherSideTypes.h
    DESTINATION include/DOtherSide
)

# pkg-config file
configure_file(${CMAKE_SOURCE_DIR}/DOtherSide.pc.cmake ${CMAKE_BINARY_DIR}/DOtherSide.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/DOtherSide.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

