include(../common/common.pri)
include(../common/statusgo_include.pri)

TEMPLATE = lib

CONFIG += static c++17

TARGET = backend

SOURCES += \
    accounts.cpp \
    types.cpp \
    utils.cpp \
    wallet_accounts.cpp

HEADERS += include/*

INCLUDEPATH += include
