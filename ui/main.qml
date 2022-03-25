import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1
import Qt.labs.settings 1.0
import QtQuick.Window 2.12
import QtQml 2.13
import QtQuick.Window 2.0
import QtQuick.Controls.Universal 2.12

import DotherSide 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import mainui 1.0
import AppLayouts.Onboarding 1.0

StatusWindow {
    property bool hasAccounts: startupModule.appState !== Constants.appState.onboarding
    property bool displayBeforeGetStartedModal: !hasAccounts
    property bool appIsReady: false

    Universal.theme: Universal.System

    id: applicationWindow
    objectName: "mainWindow"
    minimumWidth: 900
    minimumHeight: 600
    width: localAppSettings.appWidth
    height: localAppSettings.appHeight
    color: Style.current.background
    title: {
        // Set application settings
        //% "Status Desktop"
        Qt.application.name = qsTrId("status-desktop")
        Qt.application.organization = "Status"
        Qt.application.domain = "status.im"
        return Qt.application.name
    }
    visible: true

    function storeWidth() {
        if(!applicationWindow.appIsReady)
            return
        localAppSettings.appWidth = width
    }

    function storeHeight() {
        if(!applicationWindow.appIsReady)
            return
        localAppSettings.appHeight = height
    }

    onWidthChanged: Qt.callLater(storeWidth)
    onHeightChanged: Qt.callLater(storeHeight)

    Action {
        shortcut: StandardKey.FullScreen
        onTriggered: {
            if (visibility === Window.FullScreen) {
                showNormal()
            } else {
                showFullScreen()
            }
        }
    }

    Action {
        shortcut: "Ctrl+M"
        onTriggered: {
            if (visibility === Window.Minimized) {
                showNormal()
            } else {
                showMinimized()
            }
        }
    }

    Action {
        shortcut: "Ctrl+W"
        enabled: loader.item && !!loader.item.appLayout? loader.item.appLayout.appView.currentIndex === Constants.appViewStackIndex.browser
                             : true
        onTriggered: {
            applicationWindow.visible = false;
        }
    }

    Action {
        shortcut: "Ctrl+Q"
        onTriggered: {
            Qt.quit()
        }
    }

    Connections {
        target: startupModule

        onStartUpUIRaised: {
            applicationWindow.appIsReady = true
            applicationWindow.storeWidth()
            applicationWindow.storeHeight()
        }

        onAppStateChanged: {
            if(state === Constants.appState.main) {
                // We set main module to the Global singleton once user is logged in and we move to the main app.
                Global.mainModuleInst = mainModule

                mainModule.openStoreToKeychainPopup.connect(function(){
                    storeToKeychainConfirmationPopup.open()
                })
                if(localAccountSensitiveSettings.recentEmojis === "") {
                    localAccountSensitiveSettings.recentEmojis = [];
                }
                if (localAccountSensitiveSettings.whitelistedUnfurlingSites === "") {
                    localAccountSensitiveSettings.whitelistedUnfurlingSites = {};
                }
                if (localAccountSensitiveSettings.hiddenCommunityWelcomeBanners === "") {
                    localAccountSensitiveSettings.hiddenCommunityWelcomeBanners = [];
                }
                if (localAccountSensitiveSettings.hiddenCommunityBackUpBanners === "") {
                    localAccountSensitiveSettings.hiddenCommunityBackUpBanners = [];
                }
            }
        }
    }

    //! Workaround for custom QQuickWindow
    Connections {
        target: applicationWindow
        onClosing: {
            if (Qt.platform.os === "osx") {
                loader.sourceComponent = undefined
                close.accepted = true
            } else {
                if (loader.sourceComponent != app) {
                    Qt.quit();
                }
                else if (loader.sourceComponent == app) {
                    if (localAccountSensitiveSettings.quitOnClose) {
                        Qt.quit();
                    } else {
                        applicationWindow.visible = false;
                    }
                }
            }
        }
    }

	Connections {
        target: singleInstance

        onSecondInstanceDetected: {
            console.log("User attempted to run the second instance of the application")
            // activating this instance to give user visual feedback
            applicationWindow.show()
            applicationWindow.raise()
            applicationWindow.requestActivate()
        }

        onEventReceived: {
            let event = JSON.parse(eventStr)
            if (event.hasOwnProperty("uri")) {
                // Not Refactored Yet
//                chatsModel.handleProtocolUri(event.uri)
            } else {
                console.warn("Unknown event received: " + eventStr)
            }
        }
    }

    // The easiest way to get current system theme (is it light or dark) without using
    // OS native methods is to check lightness (0 - 1.0) of the window color.
    // If it's too high (0.85+) means light theme is an active.
    SystemPalette {
        id: systemPalette
        function isCurrentSystemThemeDark() {
            return window.hslLightness < 0.85
        }
    }

    function changeThemeFromOutside() {
        Style.changeTheme(localAppSettings.theme, systemPalette.isCurrentSystemThemeDark())
    }

    Component.onCompleted: {
        Global.applicationWindow = this;
        Style.changeTheme(localAppSettings.theme, systemPalette.isCurrentSystemThemeDark())

        if (!localAppSettings.appSizeInitialized) {
            width = Math.min(Screen.desktopAvailableWidth - 125, 1400)
            height =  Math.min(Screen.desktopAvailableHeight - 125, 840)
            localAppSettings.appSizeInitialized = true
        }

        setX(Qt.application.screens[0].width / 2 - width / 2);
        setY(Qt.application.screens[0].height / 2 - height / 2);

        applicationWindow.updatePosition();
    }

    signal navigateTo(string path)

    function makeStatusAppActive() {
        applicationWindow.show()
        applicationWindow.raise()
        applicationWindow.requestActivate()
    }

    SystemTrayIcon {
        id: systemTray
        visible: true
        icon.source: {
            if (production) {
                if (Qt.platform.os == "osx")
                    return "imports/assets/images/status-logo-round-rect.svg"
                else
                    return "imports/assets/images/status-logo-circle.svg"
            } else {
                if (Qt.platform.os == "osx")
                    return "imports/assets/images/status-logo-dev-round-rect.svg"
                else
                    return "imports/assets/images/status-logo-dev-circle.svg"
            }
        }

        menu: Menu {
            MenuItem {
                //% "Open Status"
                text: qsTrId("open-status")
                onTriggered: {
                    applicationWindow.makeStatusAppActive()
                }
            }

            MenuSeparator {
            }

            MenuItem {
                //% "Quit"
                text: qsTrId("quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            if (reason !== SystemTrayIcon.Context) {
                applicationWindow.makeStatusAppActive()
            }
        }
    }

    function prepareForStoring(password, runStoreToKeychainPopup) {
        if(Qt.platform.os == "osx")
        {
            storeToKeychainConfirmationPopup.password = password

            if(runStoreToKeychainPopup)
                storeToKeychainConfirmationPopup.open()
        }
    }

    ConfirmationDialog {
        id: storeToKeychainConfirmationPopup
        property string password: ""
        height: 200
        confirmationText: qsTr("Would you like to store password to the Keychain?")
        showRejectButton: true
        showCancelButton: true
        confirmButtonLabel: qsTr("Store")
        rejectButtonLabel: qsTr("Not now")
        cancelButtonLabel: qsTr("Never")

        function finish()
        {
            password = ""
            storeToKeychainConfirmationPopup.close()
        }

        onConfirmButtonClicked: {
            localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueStore
            mainModule.storePassword(password)
            finish()
        }

        onRejectButtonClicked: {
            localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNotNow
            finish()
        }

        onCancelButtonClicked: {
            localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNever
            finish()
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        opacity: active ? 1.0 : 0.0
        visible: (opacity > 0.0001)
        Behavior on opacity { NumberAnimation { duration: 120 }}
        active: !splashScreen.visible
    }

    Component {
        id: app
        AppMain {
            sysPalette: systemPalette
        }
    }

    OnboardingLayout {
        hasAccounts: applicationWindow.hasAccounts
        onLoadApp: {
            loader.sourceComponent = app;
        }

        onOnBoardingStepChanged: {
            loader.sourceComponent = view;
            loader.item.state = state;
        }
    }

    NotificationWindow {
        id: notificationWindow
    }

    MacTrafficLights {
//        parent: Overlay.overlay
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 13

        visible: Qt.platform.os === "osx" && !applicationWindow.isFullScreen

        onClose: {
            if (loader.sourceComponent != app) {
                Qt.quit();
            }
            else if (loader.sourceComponent == app) {
                if (localAccountSensitiveSettings.quitOnClose) {
                    Qt.quit();
                } else {
                    applicationWindow.visible = false;
                }
            }
        }

        onMinimised: {
            applicationWindow.showMinimized()
        }

        onMaximized: {
            applicationWindow.toggleFullScreen()
        }
    }

    SplashScreen {
        id: splashScreen
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/
