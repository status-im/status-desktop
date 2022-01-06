if(APPLE)
    file(GLOB_RECURSE SOURCES *.cpp *.mm)
else()
    file(GLOB_RECURSE SOURCES *.cpp)
endif()

add_library(DOtherSide
    ${SOURCES})

if(APPLE)
    target_include_directories(DOtherSide
        PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/../../bottles/hunspell/include)
else()
    target_include_directories(DOtherSide 
        PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR})
endif()

target_link_libraries(DOtherSide
    PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Gui
)

include_directories(
    # Add here any vendor folder
    #../../vendor/vendor_name_goes_here/
)