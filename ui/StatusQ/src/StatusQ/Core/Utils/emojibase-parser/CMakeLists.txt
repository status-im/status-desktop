cmake_minimum_required(VERSION 3.16)

project(emojibase-parser LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

add_executable(emojibase-parser
  main.cpp
  emoji-json.qrc
)
target_link_libraries(emojibase-parser Qt${QT_VERSION_MAJOR}::Core)

include(GNUInstallDirs)
install(TARGETS emojibase-parser
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
