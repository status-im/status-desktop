
cmake_minimum_required(VERSION 3.14)
project(status-desktop-test VERSION 0.1.0 LANGUAGES CXX)

macro(add_gtest TESTNAME SRC)
    add_executable(${TESTNAME} ${SRC})
    target_link_libraries(${TESTNAME} PRIVATE GTest::gtest GTest::gmock GTest::gtest_main)
    add_test(${TESTNAME} ${TESTNAME})
endmacro()

find_package(GTest REQUIRED)
find_package(fruit REQUIRED)

add_gtest(TestDeps testDeps.cpp)
target_link_libraries(TestDeps PRIVATE fruit::fruit)
