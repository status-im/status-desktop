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

import "./onboarding"
import "./app"
import "./sounds"
import "./shared"
import "./imports"

ApplicationWindow {
    property bool hasAccounts: !!loginModel.rowCount()
    property bool removeMnemonicAfterLogin: false
    property alias dragAndDrop: dragTarget
    property bool popupOpened: false

    Universal.theme: Universal.System

    id: applicationWindow
    minimumWidth: 900
    minimumHeight: 600
    width: 1232
    height: 770
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

    onClosing: {
        if(loader.sourceComponent == app){
            if(loader.item.appSettings.quitOnClose){
                Qt.quit();
            } else {
                applicationWindow.visible = false;
                close.accepted = false;
            }
        }
    }

    Component.onCompleted: {
        // Change the theme to the system theme (dark/light) until we get the
        // user's saved setting from status-go (after login)
        Style.changeTheme(Universal.theme === Universal.Dark ? "dark" : "light")
        setX(Qt.application.screens[0].width / 2 - width / 2);
        setY(Qt.application.screens[0].height / 2 - height / 2);
    }

    signal navigateTo(string path)
    
    property bool currentlyHasANotification: false

    onActiveChanged: {
        if (active && currentlyHasANotification) {
            currentlyHasANotification = false
            // QML doesn't have a function to hide notifications, but this does the trick
            systemTray.hide()
            systemTray.show()
        }
    }

    SystemTrayIcon {
        id: systemTray
        visible: true
        icon.source: applicationWindow.Universal.theme === Universal.Dark ?
            "shared/img/status-logo.svg" :
            "shared/img/status-logo-light-theme.svg";
        menu: Menu {
            MenuItem {
                visible: !applicationWindow.visible
                text: qsTr("Open Status")
                onTriggered: {
                    applicationWindow.visible = true;
                    applicationWindow.requestActivate();
                }
            }
            
            MenuSeparator { 
                visible: !applicationWindow.visible
            }

            MenuItem {
                //% "Quit"
                text: qsTrId("quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            if (reason === SystemTrayIcon.Context) {
                return
            }
            applicationWindow.show()
            applicationWindow.raise()
            applicationWindow.requestActivate()
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
                id: stateIntro
                onEntered: loader.sourceComponent = intro
            }

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
                    signal: onboardingModel.loginResponseChanged
                    guard: !error
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: loader.sourceComponent = genKey

                DSM.SignalTransition {
                    targetState: appState
                    signal: onboardingModel.loginResponseChanged
                    guard: !error
                }
            }

            DSM.State {
                id: stateLogin
                onEntered: loader.sourceComponent = login

                DSM.SignalTransition {
                    targetState: appState
                    signal: loginModel.loginResponseChanged
                    guard: !error
                }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.SignalTransition {
                targetState: hasAccounts ? stateLogin : stateIntro
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

            DSM.FinalState {
                id: onboardingDoneState
            }
        }

        DSM.State {
            id: appState
            onEntered: loader.sourceComponent = app

            DSM.SignalTransition {
                targetState: stateLogin
                signal: loginModel.onLoggedOut
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        property var appSettings
    }

    DropArea {
        id: dragTarget

        signal droppedOnValidScreen(var drop)
        property alias droppedUrls: rptDraggedPreviews.model
        readonly property int chatView: Utils.getAppSectionIndex(Constants.chat)
        readonly property int timelineView: Utils.getAppSectionIndex(Constants.timeline)
        property bool enabled: containsDrag && loader.item &&
            (
                // in chat view
                (loader.item.currentView === chatView &&
                    (
                        // in a one-to-one chat
                        chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne ||
                        // in a private group chat
                        chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat
                    )
                ) ||
                // in timeline view
                loader.item.currentView === timelineView
            )

        width: applicationWindow.width
        height: applicationWindow.height

        function cleanup() {
            rptDraggedPreviews.model = []
        }

        onDropped: (drop) => {
            if (enabled) {
                droppedOnValidScreen(drop)
            }
            cleanup()
        }
        onEntered: {
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
                    when: dragTarget.enabled
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
        AppMain {}
    }

    Component {
        id: intro
        Intro {
            btnGetStarted.onClicked: applicationWindow.navigateTo("KeysMain")
        }
    }

    Component {
        id: keysMain
        KeysMain {
            btnGenKey.onClicked: applicationWindow.navigateTo("GenKey")
            btnExistingKey.onClicked: applicationWindow.navigateTo("ExistingKey")
        }
    }

    Component {
        id: existingKey
        ExistingKey {
            onClosed: function () {
                removeMnemonicAfterLogin = false
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
        GenKey {
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
        Login {
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
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/
