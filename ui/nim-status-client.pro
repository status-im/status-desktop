QT += quick
QT += webchannel

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

lupdate_only{
SOURCES += $$files("$$PWD/*qmldir", true)
SOURCES += $$files("$$PWD/*.qml", true)
SOURCES += $$files("$$PWD/*.js", true)
SOURCES += $$files("$$PWD/../monitoring/*.qml", true)
SOURCES += $$files("$$PWD/../*.md", false)
}

# Other *.ts files will be provided by Lokalise platform
TRANSLATIONS += \
    i18n/qml_base.ts \
    i18n/qml_en.ts \


OTHER_FILES += $$files("$$PWD/*qmldir", true)
OTHER_FILES += $$files("$$PWD/*.qml", true)
OTHER_FILES += $$files("$$PWD/*.js", true)
OTHER_FILES += $$files("$$PWD/../src/*.nim", true)
OTHER_FILES += $$files("$$PWD/../monitoring/*.qml", true)

OTHER_FILES += $$files("$$PWD/../vendor/DOtherSide/lib/*.cpp", true)
OTHER_FILES += $$files("$$PWD/../vendor/DOtherSide/lib/*.h", true)

OTHER_FILES += $$files("$$PWD/../vendor/SortFilterProxyModel/*.cpp", true)
OTHER_FILES += $$files("$$PWD/../vendor/SortFilterProxyModel/*.h", true)

OTHER_FILES += $$files("$$PWD/../vendor/nimqml/src/*.nim", true)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $$PWD/imports \
                  $$PWD/StatusQ \
                  $$PWD/StatusQ/src \
                  $$PWD/app

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH = $$PWD/imports

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += resources.qrc StatusQ/src/assets.qrc StatusQ/src/statusq.qrc
