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
SOURCES = *.qml \
          app/*.qml \
          imports/*.qml \
          imports/shared/*.qml \
          imports/shared/controls/*.qml \
          imports/shared/keycard/*.qml \
          imports/shared/panels/*.qml \
          imports/shared/popups/*.qml \
          imports/shared/status/*.qml \
          imports/shared/views/*.qml \
          app/AppLayouts/*.qml \
          app/AppLayouts/Browser/*.qml \
          app/AppLayouts/Chat/*.qml \
          app/AppLayouts/Chat/CommunityComponents/*.qml \
          app/AppLayouts/Chat/ChatColumn/*.qml \
          app/AppLayouts/Chat/ChatColumn/ChatComponents/*.qml \
          app/AppLayouts/Chat/ChatColumn/MessageComponents/*.qml \
          app/AppLayouts/Chat/ChatColumn/MessageComponents/TransactionComponents/*.qml \
          app/AppLayouts/CommunitiesPortalLayout/*.qml \
          app/AppLayouts/Chat/ContactsColumn/*.qml \
          app/AppLayouts/Chat/components/*.qml \
          app/AppLayouts/Node/*.qml \
          app/AppLayouts/Profile/*.qml \
          app/AppLayouts/Profile/LeftTab/*.qml \
          app/AppLayouts/Profile/LeftTab/components/*.qml \
          app/AppLayouts/Profile/Sections/*.qml \
          app/AppLayouts/Profile/Sections/BrowserModals/*.qml \
          app/AppLayouts/Profile/Sections/Contacts/*.qml \
          app/AppLayouts/Profile/Sections/Data/*.qml \
          app/AppLayouts/Profile/Sections/Ens/*.qml \
          app/AppLayouts/Profile/Sections/Privileges/*.qml \
          app/AppLayouts/Wallet/*.qml \
          app/AppLayouts/Wallet/components/*.qml \
          app/AppLayouts/Wallet/components/collectiblesComponents/*.qml \
          app/AppLayouts/Wallet/data/Currencies.qml \          
}

# Other *.ts files will be provided by Lokalise platform
TRANSLATIONS += \
    i18n/qml_en.ts \

OTHER_FILES += $$files("$$PWD/*.qml", true)
OTHER_FILES += $$files("$$PWD/*.js", true)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $$PWD/imports \
                  $$PWD/StatusQ/src \
                  $$PWD/app

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH = $$PWD/imports

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += resources.qrc
