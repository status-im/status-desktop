project(TestStatusQ LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt${QT_VERSION_MAJOR} COMPONENTS
        QuickTest Qml Quick REQUIRED)

if (${QT_VERSION_MAJOR} EQUAL 6)
    find_package(Qt6 COMPONENTS WebEngineQuick REQUIRED)
else()
    find_package(Qt5 COMPONENTS WebEngine REQUIRED)
endif()

##############
# Test Library
##############

add_library(StatusQTestLib
    src/TestHelpers/MonitorQtOutput.cpp
    src/TestHelpers/MonitorQtOutput.h
    src/TestHelpers/listmodelwrapper.cpp
    src/TestHelpers/listmodelwrapper.h
    src/TestHelpers/modelaccessobserverproxy.cpp
    src/TestHelpers/modelaccessobserverproxy.h
    src/TestHelpers/modelsignalsspy.cpp
    src/TestHelpers/modelsignalsspy.h
    src/TestHelpers/modeltestutils.cpp
    src/TestHelpers/modeltestutils.h
    src/TestHelpers/persistentindexestester.cpp
    src/TestHelpers/persistentindexestester.h
    src/TestHelpers/testmodel.cpp
    src/TestHelpers/testmodel.h
)

target_link_libraries(StatusQTestLib PUBLIC Qt::Core Qt::Quick Qt::Test StatusQ)
target_include_directories(StatusQTestLib PUBLIC src)

enable_testing()

###########
# QML Tests
###########

file(GLOB_RECURSE TEST_QML_FILES "*.qml")
add_executable(QmlTests main.cpp "${TEST_QML_FILES}")

target_compile_definitions(QmlTests PRIVATE
    STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
    # no need to copy around qml test files for shadow builds - just set the respective define
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
)
target_link_libraries(QmlTests PRIVATE Qt::QuickTest Qt::Qml Qt::Quick
    $<$<EQUAL:${QT_VERSION_MAJOR},6>:Qt::WebEngineQuick>
    $<$<EQUAL:${QT_VERSION_MAJOR},5>:Qt::WebEngine>
    StatusQ StatusQTestLib
)
add_test(NAME QmlTests WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND QmlTests -input "${CMAKE_CURRENT_SOURCE_DIR}"
)

###########
# C++ Tests
###########

add_executable(ModelUtilsInternalTest tst_ModelUtilsInternal.cpp)
target_link_libraries(ModelUtilsInternalTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME ModelUtilsInternalTest COMMAND ModelUtilsInternalTest)

add_executable(RolesRenamingModelTest tst_RolesRenamingModel.cpp)
target_link_libraries(RolesRenamingModelTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME RolesRenamingModelTest COMMAND RolesRenamingModelTest)

add_executable(LeftJoinModelTest tst_LeftJoinModel.cpp)
target_link_libraries(LeftJoinModelTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME LeftJoinModelTest COMMAND LeftJoinModelTest)

add_executable(ObjectProxyModelTest tst_ObjectProxyModel.cpp)
target_link_libraries(ObjectProxyModelTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME ObjectProxyModelTest COMMAND ObjectProxyModelTest)

add_executable(AggregatorTest tst_Aggregator.cpp)
target_link_libraries(AggregatorTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME AggregatorTest COMMAND AggregatorTest)

add_executable(SingleRoleAggregatorTest tst_SingleRoleAggregator.cpp)
target_link_libraries(SingleRoleAggregatorTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME SingleRoleAggregatorTest COMMAND SingleRoleAggregatorTest)

add_executable(SumAggregatorTest tst_SumAggregator.cpp)
target_link_libraries(SumAggregatorTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME SumAggregatorTest COMMAND SumAggregatorTest)

add_executable(FunctionAggregatorTest tst_FunctionAggregator.cpp)
target_link_libraries(FunctionAggregatorTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME FunctionAggregatorTest COMMAND FunctionAggregatorTest)

add_executable(ConcatModelTest tst_ConcatModel.cpp)
target_link_libraries(ConcatModelTest PRIVATE StatusQ StatusQTestLib SortFilterProxyModel)
add_test(NAME ConcatModelTest COMMAND ConcatModelTest)

add_executable(WritableProxyModelTest tst_WritableProxyModel.cpp)
target_link_libraries(WritableProxyModelTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME WritableProxyModelTest COMMAND WritableProxyModelTest)

add_executable(MovableModelTest tst_MovableModel.cpp)
target_link_libraries(MovableModelTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME MovableModelTest COMMAND MovableModelTest)

add_executable(ModelSyncedContainerTest tst_ModelSyncedContainer.cpp)
target_link_libraries(ModelSyncedContainerTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME ModelSyncedContainerTest COMMAND ModelSyncedContainerTest)

add_executable(ModelEntryTest tst_ModelEntry.cpp)
target_link_libraries(ModelEntryTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME ModelEntryTest COMMAND ModelEntryTest)

add_executable(SnapshotObjectTest tst_SnapshotObject.cpp)
target_link_libraries(SnapshotObjectTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME SnapshotObjectTest COMMAND SnapshotObjectTest)

add_executable(GroupingModelTest tst_GroupingModel.cpp)
target_link_libraries(GroupingModelTest PRIVATE Qt::Qml StatusQ StatusQTestLib)
add_test(NAME GroupingModelTest COMMAND GroupingModelTest)

add_executable(ModelCountTest tst_ModelCount.cpp)
target_link_libraries(ModelCountTest PRIVATE StatusQ StatusQTestLib)
add_test(NAME ModelCountTest COMMAND ModelCountTest)
