import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1
import Qt.labs.settings 1.0
import QtQuick.Window 2.12
import QtQml 2.13
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
    property bool appIsReady: false

    Universal.theme: Universal.System

    id: applicationWindow
    objectName: "mainWindow"
    minimumWidth: 900
    minimumHeight: 600
    color: Style.current.background
    title: {
        // Set application settings
        Qt.application.name = "Status Desktop"
        Qt.application.displayName = qsTr("Status Desktop")
        Qt.application.organization = "Status"
        Qt.application.domain = "status.im"
        return Qt.application.displayName
    }
    visible: true

    function restoreAppState() {
        let geometry = localAppSettings.geometry;
        let visibility = localAppSettings.visibility;

        if (visibility !== Window.Windowed &&
            visibility !== Window.Maximized &&
            visibility !== Window.FullScreen) {
            visibility = Window.Windowed;
        }

        if (geometry === undefined) {
            let screen = Qt.application.screens[0];

            geometry = Qt.rect(0,
                               0,
                               Math.min(Screen.desktopAvailableWidth - 125, 1400),
                               Math.min(Screen.desktopAvailableHeight - 125, 840));
            geometry.x = (screen.width - geometry.width) / 2;
            geometry.y = (screen.height - geometry.height) / 2;
        }

        applicationWindow.visibility = visibility;
        if (visibility === Window.Windowed) {
            applicationWindow.x = geometry.x;
            applicationWindow.y = geometry.y;
            applicationWindow.width = geometry.width;
            applicationWindow.height = geometry.height;
        }
    }

    function storeAppState() {
        if (!applicationWindow.appIsReady)
            return;

        localAppSettings.visibility = applicationWindow.visibility;
        if (applicationWindow.visibility === Window.Windowed) {
            localAppSettings.geometry = Qt.rect(applicationWindow.x, applicationWindow.y,
                                                applicationWindow.width, applicationWindow.height);
        }
    }

    onXChanged: Qt.callLater(storeAppState)
    onYChanged: Qt.callLater(storeAppState)
    onWidthChanged: Qt.callLater(storeAppState)
    onHeightChanged: Qt.callLater(storeAppState)

    Action {
        shortcut: StandardKey.FullScreen
        onTriggered: {
            if (applicationWindow.visibility === Window.FullScreen) {
                showNormal()
            } else {
                showFullScreen()
            }
        }
    }

    Action {
        shortcut: "Ctrl+M"
        onTriggered: {
            if (applicationWindow.visibility === Window.Minimized) {
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

        function onStartUpUIRaised() {
            applicationWindow.appIsReady = true;
            applicationWindow.storeAppState();
        }

        function onAppStateChanged(state) {
            if(state === Constants.appState.main) {
                // We set main module to the Global singleton once user is logged in and we move to the main app.
                Global.mainModuleInst = mainModule

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
        function onClosing(close) {
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

        function onSecondInstanceDetected() {
            console.log("User attempted to run the second instance of the application")
            // activating this instance to give user visual feedback
            applicationWindow.show()
            applicationWindow.raise()
            applicationWindow.requestActivate()
        }

        function onEventReceived(eventStr) {
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
        Style.changeTheme(localAppSettings.theme, systemPalette.isCurrentSystemThemeDark());

        restoreAppState();
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
                    return "imports/assets/icons/status-logo-round-rect.svg"
                else
                    return "imports/assets/icons/status-logo-circle.svg"
            } else {
                if (Qt.platform.os == "osx")
                    return "imports/assets/icons/status-logo-dev-round-rect.svg"
                else
                    return "imports/assets/icons/status-logo-dev-circle.svg"
            }
        }

        menu: Menu {
            MenuItem {
                text: qsTr("Open Status")
                onTriggered: {
                    applicationWindow.makeStatusAppActive()
                }
            }

            MenuSeparator {
            }

            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            if (reason !== SystemTrayIcon.Context) {
                applicationWindow.makeStatusAppActive()
            }
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
            if (!!state) {
                loader.item.state = state;
            }
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
