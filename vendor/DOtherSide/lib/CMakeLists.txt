project(DOtherSide)

# Macro for merging common code between static and shared
macro(add_target name type)
    find_package(Qt5 COMPONENTS Core Qml Gui Quick QuickControls2 Widgets)

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
        src/DOtherSide.cpp
        src/DosQMetaObject.cpp
        src/DosQDeclarative.cpp
        src/DosQObject.cpp
        src/DOtherSideTypesCpp.cpp
        src/DosQObjectImpl.cpp
        src/DosQAbstractItemModel.cpp
        src/DosQQuickImageProvider.cpp
    )

    if (WIN32)
        target_compile_definitions(${name} PRIVATE -DWIN32)
    endif()

    set_target_properties(${name} PROPERTIES CXX_STANDARD 11 AUTOMOC ON)

    target_include_directories(${name} PUBLIC include include/Qt)

    target_link_libraries(${name} PRIVATE Qt5::Core Qt5::Gui Qt5::Widgets Qt5::Qml Qt5::Quick)

    if (${Qt5QuickControls2_FOUND})
        target_link_libraries(${name} PRIVATE Qt5::QuickControls2)
    endif()
endmacro()

# Add shared version
add_target(${PROJECT_NAME} SHARED)
set(major 0)
set(minor 6)
set(patch 4)
set_target_properties(${PROJECT_NAME}
PROPERTIES
    SOVERSION "${major}.${minor}"
    VERSION "${major}.${minor}.${patch}"
)

# Add static version
add_target(${PROJECT_NAME}Static STATIC)

# Install directive for header files
install(FILES
  include/DOtherSide/DOtherSide.h
  include/DOtherSide/DOtherSideTypes.h
  DESTINATION include/DOtherSide
)

# Install directive for binaries
install(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
)
