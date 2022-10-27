project(SanityChecker)

find_package(
  Qt5
  COMPONENTS Core Quick QuickControls2
  REQUIRED)

set(QRC_FILES ../src/statusq.qrc ../src/assets.qrc)
qt5_add_resources(QRC_COMPILED ${QRC_FILES})

add_executable(
  ${PROJECT_NAME}
  main.cpp
  ${QRC_FILES}
  ${QRC_COMPILED}
)

target_link_libraries(
  ${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick Qt5::QuickControls2
                          SortFilterProxyModel)

if (APPLE)
  find_library(AppKit AppKit)
  find_library(Foundation Foundation)

  target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation})
endif()
