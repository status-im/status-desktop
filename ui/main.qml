import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1
import QtQml.StateMachine 1.14 as DSM
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

import "./app/AppLayouts/Onboarding/views"
import "./app"

StatusWindow {
    property bool hasAccounts: startupModule.appState !== Constants.appState.onboarding
    property alias dragAndDrop: dragTarget
    property bool displayBeforeGetStartedModal: !hasAccounts

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
        localAppSettings.appWidth = width
    }

    function storeHeight() {
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
        onAppStateChanged: {
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

    //! Workaround for custom QQuickWindow
    Connections {
        target: applicationWindow
        onClosing: {
            if (Qt.platform.os === "osx") {
                loader.sourceComponent = undefined
                close.accepted = true
            } else {
                if (loader.sourceComponent == login) {
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

        onActiveChanged: {
            if (applicationWindow.active && currentlyHasANotification) {
                currentlyHasANotification = false
                // QML doesn't have a function to hide notifications, but this does the trick
                systemTray.hide()
                systemTray.show()
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
        setX(Qt.application.screens[0].width / 2 - width / 2);
        setY(Qt.application.screens[0].height / 2 - height / 2);

        if (!localAppSettings.appSizeInitialized) {
            width = Screen.desktopAvailableWidth - 125
            height = Screen.desktopAvailableHeight - 125
            localAppSettings.appSizeInitialized = true
        }
        applicationWindow.updatePosition();
    }

    signal navigateTo(string path)

    property bool currentlyHasANotification: false

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

    DSM.StateMachine {
        id: stateMachine
        initialState: onboardingState
        running: true

        DSM.State {
            id: onboardingState
            initialState: hasAccounts ? stateLogin : keysMainState

            DSM.State {
                id: keysMainState
                onEntered: loader.sourceComponent = keysMain

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.State {
                id: existingKeyState
                onEntered: loader.sourceComponent = existingKey

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state == Constants.appState.main
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: loader.sourceComponent = genKey

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state == Constants.appState.main
                }
            }

            DSM.State {
                id: keycardState
                onEntered: loader.sourceComponent = keycardFlowSelection

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state == Constants.appState.main
                }
            }

            DSM.State {
                id: stateLogin
                onEntered: loader.sourceComponent = login

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state == Constants.appState.main
                }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.SignalTransition {
                targetState: hasAccounts ? stateLogin : keysMainState
                signal: applicationWindow.navigateTo
                guard: path === "InitialState"
            }

            DSM.SignalTransition {
                targetState: existingKeyState
                signal: applicationWindow.navigateTo
                guard: path === "ExistingKey"
            }

            DSM.SignalTransition {
                targetState: keysMainState
                signal: applicationWindow.navigateTo
                guard: path === "KeysMain"
            }

            DSM.SignalTransition {
                targetState: keycardState
                signal: applicationWindow.navigateTo
                guard: path === "KeycardFlowSelection"
            }

            DSM.FinalState {
                id: onboardingDoneState
            }
        }

        DSM.State {
            id: appState
            onEntered: loader.sourceComponent = app

            DSM.SignalTransition {
                targetState: stateLogin
                signal: startupModule.logOut
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    DropArea {
        id: dragTarget

        signal droppedOnValidScreen(var drop)
        property alias droppedUrls: rptDraggedPreviews.model
        property bool enabled: !drag.source && !!loader.item && !!loader.item.appLayout

        // Not Refactored Yet
//                               && (
//                                   // in chat view
//                                   (loader.item.appLayout.appView.currentIndex === Constants.appViewStackIndex.chat &&
//                                    (
//                                        // in a one-to-one chat
//                                        chatsModel.channelView.activeChannel.chatType === Constants.chatType.oneToOne ||
//                                        // in a private group chat
//                                        chatsModel.channelView.activeChannel.chatType === Constants.chatType.privateGroupChat
//                                        )
//                                    ) ||
//                                   // In community section
//                                   chatsModel.communities.activeCommunity.active
//                                   )

        width: applicationWindow.width
        height: applicationWindow.height

        function cleanup() {
            rptDraggedPreviews.model = []
        }

        onDropped: (drop) => {
                       if (enabled) {
                           droppedOnValidScreen(drop)
                       } else {
                           drop.accepted = false
                       }
                       cleanup()
                   }
        onEntered: {
            if (!enabled || !!drag.source) {
                drag.accepted = false
                return
            }

            // needed because drag.urls is not a normal js array
            rptDraggedPreviews.model = drag.urls.filter(img => Utils.hasDragNDropImageExtension(img))
        }
        onPositionChanged: {
            rptDraggedPreviews.x = drag.x
            rptDraggedPreviews.y = drag.y
        }
        onExited: cleanup()
        Rectangle {
            id: dropRectangle

            width: parent.width
            height: parent.height
            color: Style.current.transparent
            opacity: 0.8

            states: [
                State {
                    when: dragTarget.enabled && dragTarget.containsDrag
                    PropertyChanges {
                        target: dropRectangle
                        color: Style.current.background
                    }
                }
            ]
        }
        Repeater {
            id: rptDraggedPreviews

            Image {
                source: modelData
                width: 80
                height: 80
                sourceSize.width: 160
                sourceSize.height: 160
                fillMode: Image.PreserveAspectFit
                x: index * 10 + rptDraggedPreviews.x
                y: index * 10 + rptDraggedPreviews.y
                z: 1
            }
        }
    }

    Component {
        id: app
        AppMain {
            sysPalette: systemPalette
        }
    }

    Component {
        id: keysMain
        KeysMainView {
            btnGenKey.onClicked: applicationWindow.navigateTo("GenKey")
            btnExistingKey.onClicked: applicationWindow.navigateTo("ExistingKey")
            btnKeycard.onClicked: applicationWindow.navigateTo("KeycardFlowSelection")
        }
    }

    Component {
        id: existingKey
        ExistingKeyView {
            onClosed: function () {
                if (hasAccounts) {
                    applicationWindow.navigateTo("InitialState")
                } else {
                    applicationWindow.navigateTo("KeysMain")
                }
            }
        }
    }

    Component {
        id: genKey
        GenKeyView {
            onClosed: function () {
                if (hasAccounts) {
                    applicationWindow.navigateTo("InitialState")
                } else {
                    applicationWindow.navigateTo("KeysMain")
                }
            }
        }
    }

    Component {
        id: keycardFlowSelection
        KeycardFlowSelectionView {
            onClosed: function () {
                if (hasAccounts) {
                    applicationWindow.navigateTo("InitialState")
                } else {
                    applicationWindow.navigateTo("KeysMain")
                }
            }
        }
    }

    Component {
        id: login
        LoginView {
            onGenKeyClicked: function () {
                applicationWindow.navigateTo("GenKey")
            }
            onExistingKeyClicked: function () {
                applicationWindow.navigateTo("ExistingKey")
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
            if (loader.sourceComponent == login) {
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
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/
