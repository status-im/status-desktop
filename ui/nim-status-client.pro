QT += quick

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES +=

RESOURCES += \
    imports/Theme.qml \
    imports/Constants.qml \
    main.qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $$PWD/imports

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH = $$PWD/imports

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    Inter-Black.otf \
    Inter-BlackItalic.otf \
    Inter-Bold.otf \
    Inter-BoldItalic.otf \
    Inter-ExtraBold.otf \
    Inter-ExtraBoldItalic.otf \
    Inter-ExtraLight.otf \
    Inter-ExtraLightItalic.otf \
    Inter-Italic.otf \
    Inter-Light.otf \
    Inter-LightItalic.otf \
    Inter-Medium.otf \
    Inter-MediumItalic.otf \
    Inter-Regular.otf \
    Inter-SemiBold.otf \
    Inter-SemiBoldItalic.otf \
    Inter-Thin.otf \
    Inter-ThinItalic.otf \
    Inter-V.otf \
    Theme.qml \
    app/AppLayouts/Browser/BrowserLayout.qml \
    app/AppLayouts/Chat/ChatColumn.qml \
    app/AppLayouts/Chat/ChatColumn/MessagesData.qml \
    app/AppLayouts/Chat/ChatLayout.qml \
    app/AppLayouts/Chat/ContactsColumn.qml \
    app/AppLayouts/Chat/components/PublicChatPopup.qml \
    app/AppLayouts/Chat/components/PrivateChatPopup.qml \
    app/AppLayouts/Chat/components/SuggestedChannel.qml \
    app/AppLayouts/Chat/components/qmldir \
    app/AppLayouts/Chat/qmldir \
    app/AppLayouts/Node/NodeLayout.qml \
    app/AppLayouts/Profile/LeftTab/qmldir \
    app/AppLayouts/Profile/ProfileLayout.qml \
    app/AppLayouts/Wallet/LeftTab.qml \
    app/AppLayouts/Wallet/SendModal.qml \
    app/AppLayouts/Wallet/WalletLayout.qml \
    app/AppLayouts/Wallet/qmldir \
    app/AppLayouts/WalletLayout.qml \
    app/AppLayouts/qmldir \
    app/AppMain.qml \
    app/img/arrow-btn-active.svg \
    app/img/arrow-btn-inactive.svg \
    app/img/compass.svg \
    app/img/compassActive.svg \
    app/img/close.svg \
    app/img/group_chat.svg \
    app/img/hash.svg \
    app/img/message.svg \
    app/img/messageActive.svg \
    app/img/new_chat.svg \
    app/img/profile.svg \
    app/img/profileActive.svg \
    app/img/public_chat.svg \
    app/img/search.svg \
    app/img/wallet.svg \
    app/img/walletActive.svg \
    app/qmldir \
    imports/qmldir \
    onboarding/ExistingKey.qml \
    onboarding/GenKey.qml \
    onboarding/Intro.qml \
    onboarding/KeysMain.qml \
    onboarding/OnboardingMain.qml \
    onboarding/img/browser-dark@2x.jpg \
    onboarding/img/browser-dark@3x.jpg \
    onboarding/img/browser@2x.jpg \
    onboarding/img/browser@3x.jpg \
    onboarding/img/chat-dark@2x.jpg \
    onboarding/img/chat-dark@3x.jpg \
    onboarding/img/chat@2x.jpg \
    onboarding/img/chat@3x.jpg \
    onboarding/img/key.png \
    onboarding/img/key@2x.png \
    onboarding/img/next.svg \
    onboarding/img/wallet-dark@2x.jpg \
    onboarding/img/wallet-dark@3x.jpg \
    onboarding/img/wallet@2x.jpg \
    onboarding/img/wallet@3x.jpg \
    onboarding/qmldir \
    shared/PopupMenu.qml \
    shared/Separator.qml \
    shared/StyledButton.qml \
    shared/RoundedIcon.qml \
    shared/qmldir
