QT += quick

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        handler.cpp \
        main.cpp \
        sandboxapp.cpp

OBJECTIVE_SOURCES += \
    statuswindow_mac.mm

RESOURCES += qml.qrc

DESTDIR = $$PWD/bin
CONFIG -= app_bundle

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

OTHER_FILES += $$files($$PWD/../src/*, true)

HEADERS += \
    handler.h \
    sandboxapp.h \
    statuswindow.h

DISTFILES += \
    ../src/StatusQ/Components/StatusMacWindowButtons.qml \
    ../src/StatusQ/Controls/StatusBaseButton.qml \
    ../src/StatusQ/Controls/StatusButton.qml \
    ../src/StatusQ/Controls/StatusCheckBox.qml \
    ../src/StatusQ/Controls/StatusFlatRoundButton.qml \
    ../src/StatusQ/Controls/StatusRadioButton.qml \
    ../src/StatusQ/Controls/StatusSlider.qml \
    ../src/StatusQ/Controls/StatusSwitch.qml
