TEMPLATE = app

QT += quick qml webview svg widgets

QMAKE_IOS_DEPLOYMENT_TARGET=12.0

SOURCES += \
        sources/main.cpp

# Add all status-desktop qrc files
RESOURCES += \
    ../vendors/status-desktop/ui/resources.qrc \
    ../vendors/status-desktop/ui/StatusQ/src/assets.qrc \
    ../vendors/status-desktop/ui/StatusQ/src/assets2.qrc \
    ../vendors/status-desktop/ui/StatusQ/src/statusq.qrc \
    ../vendors/status-desktop/fleets.json

LIBS += -L$$PWD/../lib -lnim_status_client -lDOtherSideStatic -lstatusq -lstatus -lssl -lcrypto -lqzxing -lresolv -lqrcodegen -lpcre

DESTDIR=$$PWD/../bin

target.path = $$PWD/../lib

deployment.files += ../vendors/status-desktop/fleets.json
deployment.path=
QMAKE_BUNDLE_DATA += deployment

INSTALLS += target
