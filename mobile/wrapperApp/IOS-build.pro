TEMPLATE = app

QT += quick qml webview svg widgets

QMAKE_IOS_DEPLOYMENT_TARGET=12.0

SOURCES += \
        sources/main.cpp

# Add all status-desktop qrc files
RESOURCES += \
    ../vendors/status-desktop/ui/resources.qrc

QML_IMPORT_PATH += $$PWD/../vendors/status-desktop/ui/imports \
                   $$PWD/../vendors/status-desktop/ui/app \
                   $$PWD/../vendors/status-desktop/ui/StatusQ/src

QMLPATHS += $$QML_IMPORT_PATH

android {
    message("cofiguring for android $${QT_ARCH}, $$(ANDROID_ABI)")

    LIBS += -L$$PWD/../lib/android -lnim_status_client
    ANDROID_EXTRA_LIBS += \
                        $$PWD/../lib/android/libnim_status_client.so \
                        $$PWD/../lib/android/libssl_1_1.so \
                        $$PWD/../lib/android/libcrypto_1_1.so \
                        $$PWD/../lib/android/libDOtherSide_$$(ANDROID_ABI).so \
                        $$PWD/../lib/android/libpcre.so \
                        $$PWD/../lib/android/libstatus.so \
                        $$PWD/../lib/android/libStatusQ_$$(ANDROID_ABI).so
                                    
}

ios {
    LIBS += -L$$PWD/../lib/ios -lnim_status_client -lDOtherSide -lstatusq -lstatus -lssl_1_1 -lcrypto_1_1 -lqzxing -lresolv -lqrcodegen -lpcre
}

DESTDIR=$$PWD/../bin

target.path = $$PWD/../lib
INSTALLS += target
