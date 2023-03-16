project(Sandbox)

find_package(
  Qt5
  COMPONENTS Core Quick QuickControls2
  REQUIRED)

include (../StatusQSources.cmake)

file(GLOB_RECURSE QML_FILES "../*.qml" "../qmldir")
file(GLOB_RECURSE JS_FILES "../*.js")

set(HEADERS sandboxapp.h)
set(SOURCES main.cpp sandboxapp.cpp)

set(QRC_FILES qml.qrc ../src/statusq.qrc ../src/assets.qrc)
qt5_add_big_resources(QRC_COMPILED ${QRC_FILES})

add_executable(
  ${PROJECT_NAME}
  ${HEADERS}
  ${SOURCES}
  ${STATUSQ_HEADERS}
  ${STATUSQ_SOURCES}
  ${QRC_FILES}
  ${QRC_COMPILED}
  ${QML_FILES}
  ${JS_FILES})

target_include_directories(${PROJECT_NAME} PUBLIC ${STATUSQ_DIR}/include)
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
