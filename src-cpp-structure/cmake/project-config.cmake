set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
#set(CMAKE_AUTORCC ON) This is disabled because of `/ui/generate-rcc.go` script usage for generating .qrc and cmake command for .rcc

# Set this to TRUE if you want to create .ts files and translations.qrc
set(UPDATE_TRANSLATIONS FALSE)

if ($ENV{QTDIR} LESS_EQUAL "")
    message(FATAL_ERROR "Please set the path to your Qt dir as `QTDIR` variable in your ENV. Example: QTDIR=/Qt/Qt5.14.2/5.14.2/clang_64")
endif()

message("Located QtDir: " $ENV{QTDIR})
set(CMAKE_PREFIX_PATH $ENV{QTDIR})

add_definitions(-DSTATUS_SOURCE_DIR="${CMAKE_SOURCE_DIR}")
add_definitions(-DSTATUS_DEVELOPMENT=true)
