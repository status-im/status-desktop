project(Sandbox)

find_package(
  Qt5
  COMPONENTS Core Quick QuickControls2
  REQUIRED)

file(GLOB_RECURSE QML_FILES "../*.qml")
file(GLOB_RECURSE JS_FILES "../*.js")

qt5_add_big_resources(QRC_FILES qml.qrc ../src/statusq.qrc ../src/assets.qrc)

add_executable(
  ${PROJECT_NAME}
  main.cpp
  handler.cpp
  sandboxapp.cpp
  spellchecker.cpp
  ${QRC_FILES}
  ${QML_FILES}
  ${JS_FILES})

if(APPLE)
  target_sources(${PROJECT_NAME} PRIVATE statuswindow_mac.mm)
else()
  target_sources(${PROJECT_NAME} PRIVATE statuswindow.cpp)
endif()

target_compile_definitions(${PROJECT_NAME}
                           PRIVATE SRC_DIR="${CMAKE_CURRENT_LIST_DIR}")
target_link_libraries(${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick
                                              Qt5::QuickControls2)
