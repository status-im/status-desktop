cmake_minimum_required(VERSION 3.5)

project(TestStatusQ LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS QuickTest Qml Quick WebEngine REQUIRED)

##############
# Test Library
##############

add_library(StatusQTestLib
    src/TestHelpers/MonitorQtOutput.cpp
    src/TestHelpers/MonitorQtOutput.h
    src/TestHelpers/modelaccessobserverproxy.cpp
    src/TestHelpers/modelaccessobserverproxy.h
)

target_link_libraries(StatusQTestLib PUBLIC Qt5::Core Qt5::Quick)
target_include_directories(StatusQTestLib PUBLIC src)

enable_testing()

###########
# QML Tests
###########

file(GLOB_RECURSE TEST_QML_FILES "*.qml")
add_executable(QmlTests main.cpp "${TEST_QML_FILES}")

target_compile_definitions(QmlTests PRIVATE
    STATUSQ_MODULE_PATH="${STATUSQ_MODULE_PATH}"
    STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
    # no need to copy around qml test files for shadow builds - just set the respective define
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
)
target_link_libraries(QmlTests PRIVATE Qt5::QuickTest Qt5::Qml Qt5::Quick
    Qt5::WebEngine StatusQ StatusQTestLib
)
add_test(NAME QmlTests WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND QmlTests -input "${CMAKE_CURRENT_SOURCE_DIR}"
)

###########
# C++ Tests
###########

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
