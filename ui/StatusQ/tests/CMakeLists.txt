cmake_minimum_required(VERSION 3.5)

project(TestStatusQ LANGUAGES CXX)

enable_testing()

set(CMAKE_AUTOMOC ON)

find_package(QT NAMES Qt6 Qt5 COMPONENTS QuickTest Qml Quick WebChannel WebEngine REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS QuickTest Qml Quick WebChannel WebEngine REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# no need to copy around qml test files for shadow builds - just set the respective define
add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(${PROJECT_NAME} main.cpp)

add_test(NAME ${PROJECT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${PROJECT_NAME} -input "${CMAKE_CURRENT_SOURCE_DIR}")

# TODO: move this to a test helpers library
target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

add_subdirectory(src)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::QuickTest
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::WebChannel
    Qt${QT_VERSION_MAJOR}::WebEngine
    StatusQ
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
        STATUSQ_MODULE_PATH="${STATUSQ_MODULE_PATH}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )

add_executable(RolesRenamingModelTest tst_RolesRenamingModel.cpp)
target_link_libraries(RolesRenamingModelTest PRIVATE Qt5::Qml Qt5::Test StatusQ)
add_test(NAME RolesRenamingModelTest COMMAND RolesRenamingModelTest)

add_executable(LeftJoinModelTest tst_LeftJoinModel.cpp)
target_link_libraries(LeftJoinModelTest PRIVATE Qt5::Test StatusQ)
add_test(NAME LeftJoinModelTest COMMAND LeftJoinModelTest)

add_executable(SubmodelProxyModelTest tst_SubmodelProxyModel.cpp)
target_link_libraries(SubmodelProxyModelTest PRIVATE Qt5::Qml Qt5::Test StatusQ)
add_test(NAME SubmodelProxyModelTest COMMAND SubmodelProxyModelTest)

add_executable(AggregatorTest tst_Aggregator.cpp)
target_link_libraries(AggregatorTest PRIVATE Qt5::Test StatusQ)
add_test(NAME AggregatorTest COMMAND AggregatorTest)

add_executable(SingleRoleAggregatorTest tst_SingleRoleAggregator.cpp)
target_link_libraries(SingleRoleAggregatorTest PRIVATE Qt5::Test StatusQ)
add_test(NAME SingleRoleAggregatorTest COMMAND SingleRoleAggregatorTest)

add_executable(SumAggregatorTest tst_SumAggregator.cpp)
target_link_libraries(SumAggregatorTest PRIVATE Qt5::Test StatusQ)
add_test(NAME SumAggregatorTest COMMAND SumAggregatorTest)

add_executable(ConcatModelTest tst_ConcatModel.cpp)
target_link_libraries(ConcatModelTest PRIVATE Qt5::Qml Qt5::Test StatusQ)
add_test(NAME ConcatModelTest COMMAND ConcatModelTest)
