project(TestDynamicQObject)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

include_directories(${CMAKE_SOURCE_DIR}/lib/include ${CMAKE_SOURCE_DIR}/lib/include/Qt)

find_package(Qt5Core REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5Test REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5QuickTest REQUIRED)

add_executable(${PROJECT_NAME} Resources.qrc
    test_dotherside.cpp
    MockQObject.h
    MockQObject.cpp
    MockQAbstractItemModel.h
    MockQAbstractItemModel.cpp
    Global.h
    main.qml
    testQObject.qml
    testQAbstractItemModel.qml
    testQDeclarative.qml
)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 14)
target_link_libraries(${PROJECT_NAME} DOtherSideStatic Qt5::Quick Qt5::Widgets Qt5::Test Qt5::Core)
