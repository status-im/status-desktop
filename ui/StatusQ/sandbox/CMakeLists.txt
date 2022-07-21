project(Sandbox)

find_package(
  Qt5
  COMPONENTS Core Quick QuickControls2
  REQUIRED)

file(GLOB_RECURSE QML_FILES "../*.qml")
file(GLOB_RECURSE JS_FILES "../*.js")
file(GLOB_RECURSE HEADERS *.h)
if(APPLE)
  file(GLOB_RECURSE SOURCES *.cpp *.mm)
else()
  file(GLOB_RECURSE SOURCES *.cpp)
endif()

qt5_add_big_resources(QRC_FILES qml.qrc ../src/statusq.qrc ../src/assets.qrc)

add_executable(
  ${PROJECT_NAME}
  ${HEADERS}
  ${SOURCES}
  ${QRC_FILES}
  ${QML_FILES}
  ${JS_FILES})

target_compile_definitions(${PROJECT_NAME}
                           PRIVATE SRC_DIR="${CMAKE_CURRENT_LIST_DIR}")
target_link_libraries(
  ${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick Qt5::QuickControls2
                          SortFilterProxyModel)

if (APPLE)
  find_library(AppKit AppKit)
  find_library(Foundation Foundation)

  target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation})
endif()
