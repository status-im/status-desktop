project(DOtherSide)

include(GNUInstallDirs)

# Macro for merging common code between static and shared
macro(add_target name type)
    find_package(Qt5 COMPONENTS Core Qml Gui Quick QuickControls2 Widgets Network REQUIRED)

    add_library(${name} ${type}
        include/DOtherSide/DOtherSideTypes.h
        include/DOtherSide/DOtherSideTypesCpp.h
        include/DOtherSide/DOtherSide.h
        include/DOtherSide/DosQDeclarative.h
        include/DOtherSide/DosQObjectWrapper.h
        include/DOtherSide/DosQAbstractItemModelWrapper.h
        include/DOtherSide/DosQObject.h
        include/DOtherSide/DosQObjectImpl.h
        include/DOtherSide/DosIQObjectImpl.h
        include/DOtherSide/DosQMetaObject.h
        include/DOtherSide/DosIQAbstractItemModelImpl.h
        include/DOtherSide/DosQAbstractItemModel.h
        include/DOtherSide/Utils.h
        include/DOtherSide/StatusEvents/StatusDockShowAppEvent.h
        include/DOtherSide/StatusEvents/StatusOSThemeEvent.h
        include/DOtherSide/DOtherSideStatusWindow.h
        include/DOtherSide/DOtherSideSingleInstance.h
        include/DOtherSide/DOtherSideStatusSyntaxHighlighter.h
        src/DOtherSide.cpp
        src/DosQMetaObject.cpp
        src/DosQDeclarative.cpp
        src/DosQObject.cpp
        src/DOtherSideTypesCpp.cpp
        src/DosQObjectImpl.cpp
        src/DosQAbstractItemModel.cpp
        src/DosQQuickImageProvider.cpp
        src/StatusEvents/StatusDockShowAppEvent.cpp
        src/StatusEvents/StatusOSThemeEvent.cpp
        src/DOtherSideStatusWindow.cpp
        src/DOtherSideSingleInstance.cpp
        src/DOtherSideStatusSyntaxHighlighter.cpp
    )

    if (APPLE)
        target_sources(${name} PUBLIC src/DOtherSideStatusWindow_osx.mm)
    else()
        target_sources(${name} PUBLIC ${CMAKE_SOURCE_DIR}/lib/src/DOtherSideStatusWindow_other.cpp)
    endif()

    if (WIN32)
        target_compile_definitions(${name} PRIVATE -DWIN32)
    endif()

    set_target_properties(${name} PROPERTIES CXX_STANDARD 11 AUTOMOC ON)

    target_include_directories(${name} PUBLIC include include/Qt)

    target_link_libraries(${name} PRIVATE Qt5::Core Qt5::Gui Qt5::Widgets Qt5::Qml Qt5::Quick Qt5::Network)

    # for DOtherSide.pc
    set(PC_REQUIRES "Qt5Core, Qt5Gui, Qt5Widgets, Qt5Qml, Qt5Quick, Qt5Network, Qt5DBus")
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

