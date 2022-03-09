include(../common/common.pri)
include(../common/app_service_include.pri)
include(../common/statusgo_include.pri)

TEMPLATE = lib
TARGET = app
QT += concurrent quick core

CONFIG += static c++17

INCLUDEPATH += \
   include \
   boot \
   modules/shared \
   modules/main \
   modules/startup

HEADERS += \
   include/signals.h

HEADERS += $$files("include/*.h", true)
HEADERS += $$files("boot/*.h", true)
HEADERS += $$files("modules/shared/*.h", true)
HEADERS += $$files("modules/main/*.h", true)
HEADERS += $$files("modules/startup/*.h", true)


SOURCES += \
    boot/app_controller.cpp \
    core/signals/signals.cpp \
    global/singleton.cpp \
    modules/main/controller_main.cpp \
    modules/main/module_main.cpp \
    modules/main/view_main.cpp \
    modules/shared/section_item.cpp \
    modules/shared/section_model.cpp \
    modules/startup/controller_startup.cpp \
    modules/startup/login/controller_login.cpp \
    modules/startup/login/item_login.cpp \
    modules/startup/login/model_login.cpp \
    modules/startup/login/module_login.cpp \
    modules/startup/login/view_login.cpp \
    modules/startup/module_startup.cpp \
    modules/startup/onboarding/controller_onboarding.cpp \
    modules/startup/onboarding/item_onboarding.cpp \
    modules/startup/onboarding/model_onboarding.cpp \
    modules/startup/onboarding/module_onboarding.cpp \
    modules/startup/onboarding/view_onboarding.cpp \
    modules/startup/login/selected_account.cpp \
    modules/main/wallet/controller_wallet.cpp \
    modules/main/wallet/module_wallet.cpp \
    modules/main/wallet/view_wallet.cpp \
    modules/main/wallet/accounts/controller_accounts.cpp \
    modules/main/wallet/accounts/module_accounts.cpp \
    modules/main/wallet/accounts/view_accounts.cpp \
    modules/main/wallet/accounts/model_accounts.cpp \
    modules/main/wallet/accounts/item_accounts.cpp \
    modules/startup/view_startup.cpp
