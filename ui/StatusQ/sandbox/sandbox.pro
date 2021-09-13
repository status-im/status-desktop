QT += quick svg

CONFIG += c++11 warn_on

DEFINES += QT_DEPRECATED_WARNINGS


# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        handler.cpp \
        main.cpp \
        sandboxapp.cpp \
        spellchecker.cpp

!macx {
    SOURCES += statuswindow.cpp
}

TARGET = sandboxapp

macx {
    CONFIG -= app_bundle
    OBJECTIVE_SOURCES += \
        statuswindow_mac.mm

    hunspellTarget.depends = FORCE
    hunspellTarget.commands = brew install hunspell
    QMAKE_EXTRA_TARGETS += hunspellTarget


    LIBS += -L"/usr/local/lib" -lhunspell-1.7
    INCLUDEPATH += /usr/local/include/hunspell
}

ios {
   LIBS += -framework UIKit

   QMAKE_TARGET_BUNDLE_PREFIX = "im.status"
   #QMAKE_XCODE_CODE_SIGN_IDENTITY = "iPhone Developer"
   MY_DEVELOPMENT_TEAM.name = "STATUS HOLDINGS PTE.LTD"
   MY_DEVELOPMENT_TEAM.value = "DTX7Z4U3YA"
   QMAKE_MAC_XCODE_SETTINGS += MY_DEVELOPMENT_TEAM

}

RESOURCES += qml.qrc \
            $$PWD/../statusq.qrc

DESTDIR = $$PWD/bin

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
#OTHER_FILES += $$files($$PWD/../src/*, true)

HEADERS += \
    handler.h \
    sandboxapp.h \
    statuswindow.h \
    spellchecker.h

OTHER_FILES += $$files($$PWD/../*.qml, true)
OTHER_FILES += $$files($$PWD/*.qml, true)

android {

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

    contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
        ANDROID_PACKAGE_SOURCE_DIR = \
            $$PWD/android
    }
}
