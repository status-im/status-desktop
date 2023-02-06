cmake_minimum_required(VERSION 3.19)
project(Storybook)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (APPLE)
    set(MACOS_VERSION_MIN_FLAGS -mmacosx-version-min=10.14)
    set(CMAKE_OSX_ARCHITECTURES "x86_64")
endif()

find_package(
  Qt5
  COMPONENTS Core Quick QuickControls2 Test QuickTest Qml
  REQUIRED)

file(GLOB_RECURSE CORE_QML_FILES "../ui/StatusQ/*.qml" "../ui/app/*.qml" "../ui/imports/*.qml")
file(GLOB_RECURSE CORE_JS_FILES "../ui/StatusQ/*.js" "../ui/app/*.js")

file(GLOB_RECURSE STORYBOOK_QML_FILES "stubs/*.qml" "mocks/*.qml" "pages/*.qml"
    "src/*.qml" "src/qmldir")

file(GLOB_RECURSE TEST_QML_FILES "qmlTests/*.qml")

set(PROJECT_LIB "${PROJECT_NAME}Lib")

set(STATUSQ_DIR ../ui/StatusQ)
set(STATUSQ_HEADERS
    ${STATUSQ_DIR}/include/StatusQ/statuswindow.h
    ${STATUSQ_DIR}/include/StatusQ/typesregistration.h
    ${STATUSQ_DIR}/include/StatusQ/QClipboardProxy.h
)

set(STATUSQ_SOURCES
    ${STATUSQ_DIR}/src/statuswindow.cpp
    ${STATUSQ_DIR}/src/typesregistration.cpp
    ${STATUSQ_DIR}/src/QClipboardProxy.cpp
)

if(APPLE)
    list(APPEND STATUSQ_SOURCES
        ${STATUSQ_DIR}/src/statuswindow_osx.mm
    )
else()
    list(APPEND STATUSQ_SOURCES
        ${STATUSQ_DIR}/src/statuswindow_other.cpp
    )
endif()

add_library(${PROJECT_LIB}
    cachecleaner.cpp cachecleaner.h
    directorieswatcher.cpp directorieswatcher.h
    figmadecoratormodel.cpp figmadecoratormodel.h
    figmaio.cpp figmaio.h
    figmalinks.cpp figmalinks.h
    figmalinksmodel.cpp figmalinksmodel.h
    figmalinkssource.cpp figmalinkssource.h
    modelutils.cpp modelutils.h
    sectionsdecoratormodel.cpp sectionsdecoratormodel.h
    ${STATUSQ_HEADERS} ${STATUSQ_SOURCES}
)

target_include_directories(${PROJECT_LIB} PUBLIC ${STATUSQ_DIR}/include)

add_executable(
  ${PROJECT_NAME}
  main.cpp
  main.qml PagesModel.qml
  ${CORE_QML_FILES}
  ${CORE_JS_FILES}
  ${STORYBOOK_QML_FILES}
  figma.json
)

target_compile_definitions(${PROJECT_NAME}
                           PRIVATE QML_IMPORT_ROOT="${CMAKE_CURRENT_LIST_DIR}")

target_link_libraries(
    ${PROJECT_LIB} PUBLIC Qt5::Core Qt5::Quick Qt5::QuickControls2)
target_link_libraries(
    ${PROJECT_NAME} PRIVATE ${PROJECT_LIB} SortFilterProxyModel)

enable_testing()

add_executable(SectionsDecoratorModelTest tests/tst_SectionsDecoratorModel.cpp)
target_link_libraries(SectionsDecoratorModelTest PRIVATE Qt5::Test ${PROJECT_LIB})
add_test(NAME SectionsDecoratorModelTest COMMAND SectionsDecoratorModelTest)

add_executable(FigmaDecoratorModelTest tests/tst_FigmaDecoratorModel.cpp)
target_link_libraries(FigmaDecoratorModelTest PRIVATE Qt5::Test ${PROJECT_LIB})
add_test(NAME FigmaModelTest COMMAND FigmaModelTest)

add_executable(QmlTests
    qmlTests/main.cpp
    qmlTests/src/TextUtils.cpp qmlTests/src/TextUtils.h
    ${TEST_QML_FILES})
target_compile_definitions(QmlTests
                           PRIVATE QML_IMPORT_ROOT="${CMAKE_CURRENT_LIST_DIR}"
                           PRIVATE -DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/qmlTests")
target_link_libraries(QmlTests PRIVATE Qt5::QuickTest Qt5::Qml)
add_test(NAME QmlTests COMMAND QmlTests)

list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/StatusQ/src")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/app")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/imports")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/src")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/pages")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/stubs")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/mocks")
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra QML import paths" FORCE)

if (APPLE)
  find_library(AppKit AppKit)
  find_library(Foundation Foundation)

  target_link_libraries(${PROJECT_NAME} PRIVATE ${AppKit} ${Foundation})
endif()

add_subdirectory(../ui/StatusQ/vendor/SortFilterProxyModel ./SortFilterProxyModel)
