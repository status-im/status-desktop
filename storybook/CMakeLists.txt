cmake_minimum_required(VERSION 3.19)
project(Storybook)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if (APPLE)
    set(MACOS_VERSION_MIN_FLAGS -mmacosx-version-min=10.14)
endif()

find_package(
  Qt5
  COMPONENTS Core Gui Quick QuickControls2 Test QuickTest Qml WebView
  REQUIRED)

set(STATUSQ_BUILD_SANDBOX OFF)
set(STATUSQ_BUILD_SANITY_CHECKER OFF)
set(STATUSQ_BUILD_TESTS OFF)
add_subdirectory(../ui/StatusQ StatusQ)

file(GLOB_RECURSE CORE_QML_FILES
    "../ui/app/*.qml" "../ui/imports/*.qml"
    "../ui/app/*/qmldir" "../ui/imports/*/qmldir"
)

file(GLOB_RECURSE CORE_JS_FILES "../ui/app/*.js")

file(GLOB_RECURSE STORYBOOK_QML_FILES "stubs/*.qml" "mocks/*.qml" "pages/*.qml"
    "src/*.qml" "src/qmldir")

file(GLOB_RECURSE TEST_QML_FILES "qmlTests/*.qml")

set(PROJECT_LIB "${PROJECT_NAME}Lib")

add_library(${PROJECT_LIB}
    cachecleaner.cpp cachecleaner.h
    directorieswatcher.cpp directorieswatcher.h
    directoryfileswatcher.cpp directoryfileswatcher.h
    figmaio.cpp figmaio.h
    figmalinks.cpp figmalinks.h
    figmalinksmodel.cpp figmalinksmodel.h
    modelutils.cpp modelutils.h
    pagesmodel.h pagesmodel.cpp
    sectionsdecoratormodel.cpp sectionsdecoratormodel.h
    testsrunner.h testsrunner.cpp
    systemutils.cpp systemutils.h
)

add_executable(
  ${PROJECT_NAME}
  main.cpp
  main.qml
  ${CORE_QML_FILES}
  ${CORE_JS_FILES}
  ${STORYBOOK_QML_FILES}
  README.md
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
        QML_IMPORT_ROOT="${CMAKE_CURRENT_LIST_DIR}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
    )

target_link_libraries(
    ${PROJECT_LIB} PUBLIC Qt5::Core Qt5::Gui Qt5::Quick Qt5::QuickControls2 Qt5::WebView)

target_link_libraries(
    ${PROJECT_NAME} PRIVATE ${PROJECT_LIB})

add_dependencies(${PROJECT_NAME} StatusQ)

enable_testing()

add_executable(
  PagesValidator
  validator_main.cpp
)

target_link_libraries(
    PagesValidator PUBLIC Qt5::Core Qt5::Gui Qt5::Quick Qt5::QuickControls2 Qt5::WebView)

add_dependencies(PagesValidator StatusQ)

target_compile_definitions(PagesValidator PRIVATE
        QML_IMPORT_ROOT="${CMAKE_CURRENT_LIST_DIR}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
    )

add_test(NAME PagesValidator COMMAND PagesValidator)

add_executable(SectionsDecoratorModelTest tests/tst_SectionsDecoratorModel.cpp)
target_link_libraries(SectionsDecoratorModelTest PRIVATE Qt5::Test ${PROJECT_LIB})
add_test(NAME SectionsDecoratorModelTest COMMAND SectionsDecoratorModelTest)

add_executable(DirectoryFilesWatcherTest tests/tst_DirectoryFilesWatcher.cpp)
target_link_libraries(DirectoryFilesWatcherTest PRIVATE Qt5::Test ${PROJECT_LIB})
add_test(NAME DirectoryFilesWatcherTest COMMAND DirectoryFilesWatcherTest)

add_executable(QmlTests
    qmlTests/main.cpp
    qmlTests/src/TextUtils.cpp qmlTests/src/TextUtils.h
    ${TEST_QML_FILES})

add_dependencies(QmlTests StatusQ)

target_compile_definitions(QmlTests PRIVATE
        QML_IMPORT_ROOT="${CMAKE_CURRENT_LIST_DIR}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/qmlTests")
target_link_libraries(QmlTests PRIVATE Qt5::QuickTest Qt5::Qml ${PROJECT_LIB} SortFilterProxyModel)
add_test(NAME QmlTests COMMAND QmlTests -platform offscreen)

list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/app")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/imports")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/../ui/StatusQ/src")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/src")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/pages")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/stubs")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}/mocks")
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra QML import paths" FORCE)

if (APPLE)
  find_library(AppKit AppKit)
  find_library(Foundation Foundation)
  target_link_libraries(${PROJECT_LIB} PRIVATE ${AppKit} ${Foundation})
endif()
