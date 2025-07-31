TEMPLATE = app

QT += quick gui qml webview svg widgets multimedia

equals(QT_MAJOR_VERSION, 6) {
    message("qt 6 config!!")
    QT += core5compat core
}

SOURCES += \
        sources/main.cpp

# Add all status-desktop qrc files
RESOURCES += \
    ../../ui/resources.qrc

QML_IMPORT_PATH += $$PWD/../../ui/imports \
                   $$PWD/../../ui/app \
                   $$PWD/../../ui/StatusQ/src

QMLPATHS += $$QML_IMPORT_PATH
LIB_PREFIX = qt$$QT_MAJOR_VERSION

android {
    message("cofiguring for android $${QT_ARCH}, $$(ANDROID_ABI)")
    
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../android/$$LIB_PREFIX

    LIBS += -L$$PWD/../lib/android/$$LIB_PREFIX -lnim_status_client
    ANDROID_EXTRA_LIBS += \
                        $$PWD/../lib/android/$$LIB_PREFIX/libssl_3.so \
                        $$PWD/../lib/android/$$LIB_PREFIX/libcrypto_3.so \
                        $$PWD/../lib/android/$$LIB_PREFIX/libnim_status_client.so \
                        $$PWD/../lib/android/$$LIB_PREFIX/libDOtherSide$$(LIB_SUFFIX)$$(LIB_EXT) \
                        $$PWD/../lib/android/$$LIB_PREFIX/libstatus.so \
                        $$PWD/../lib/android/$$LIB_PREFIX/libStatusQ$$(LIB_SUFFIX)$$(LIB_EXT)
}

ios {
    CONFIG += add_ios_ffmpeg_libraries

    QMAKE_INFO_PLIST = $$PWD/../ios/Info.plist
    QMAKE_IOS_DEPLOYMENT_TARGET=16.0
    QMAKE_TARGET_BUNDLE_PREFIX = im.status
    QMAKE_BUNDLE = status$${QMAKE_BUNDLE_SUFFIX}
    QMAKE_ASSET_CATALOGS += $$PWD/../ios/Images.xcassets

    LIBS += -L$$PWD/../lib/ios/$$LIB_PREFIX -lnim_status_client -lDOtherSideStatic -lstatusq -lstatus -lssl_3 -lcrypto_3 -lqzxing -lresolv -lqrcodegen
}

DESTDIR=$$PWD/../bin/$$LIB_PREFIX

target.path = $$PWD/../lib/$$LIB_PREFIX
INSTALLS += target
