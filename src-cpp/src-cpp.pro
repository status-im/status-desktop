include(common/common.pri)
include(common/dotherside_include.pri)
include(common/app_service_include.pri)
include(common/app_include.pri)
include(common/backend_include.pri)
include(common/statusgo_include.pri)

TEMPLATE = app
TARGET = status-desktop.com

QT += core quick qml concurrent gui widgets svg

HEADERS += \
   constants.h \
   logs.h

SOURCES += \
   main.cpp \
   constants.cpp \
   logs.cpp

RESOURCES += \
   ../ui/resources.qrc \
   ../resources/resources.qrc

ios {
    Q_ENABLE_BITCODE.name = ENABLE_BITCODE
    Q_ENABLE_BITCODE.value = NO
    QMAKE_MAC_XCODE_SETTINGS += Q_ENABLE_BITCODE

    QMAKE_APPLE_DEPLOYMENT_TARGET = 13.0
#    QMAKE_TARGET_BUNDLE_PREFIX = status-desktop.com
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 2
}
