include(../common/common.pri)
include(../common/backend_include.pri)

TEMPLATE = lib

CONFIG += static c++17

TARGET = app_service

SOURCES += \
    constants.cpp \
    service/accounts/dto/account.cpp \
    service/accounts/dto/generated_account.cpp \
    service/accounts/service_accounts.cpp \
    service/wallet_accounts/dto/wallet_account.cpp \
    service/wallet_accounts/service_wallet.cpp
HEADERS = $$files("include/*", true)
INCLUDEPATH += include

