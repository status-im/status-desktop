import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1
import QtQml.StateMachine 1.14 as DSM
import QtMultimedia 5.13
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

    Universal.theme: Universal.System

    id: applicationWindow
    minimumWidth: 800
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

    Component.onCompleted: {
        // Change the theme to the system theme (dark/light) until we get the
        // user's saved setting from status-go (after login)
        Style.changeTheme(Universal.theme === Universal.Dark ? "dark" : "light")
        setX(Qt.application.screens[0].width / 2 - width / 2);
        setY(Qt.application.screens[0].height / 2 - height / 2);
    }

    signal navigateTo(string path)

    ErrorSound {
        id: errorSound
    }

    Audio {
        id: sendMessageSound
        audioRole: Audio.NotificationRole
        source: "../../../../sounds/send_message.wav"
        volume: appSettings.volume
        muted: !appSettings.notificationSoundsEnabled
    }

    Audio {
        id: notificationSound
        audioRole: Audio.NotificationRole
        source: "../../../../sounds/notification.wav"
        volume: appSettings.volume
        muted: !appSettings.notificationSoundsEnabled
    }

    signal settingsLoaded()

    Settings {
        id: defaultAppSettings
        property bool walletEnabled: false
        property bool browserEnabled: false
        property bool displayChatImages: false
        property bool compactMode
        property string locale: "en"
        property var recentEmojis: []
        property real volume: 0.2
        property int notificationSetting: Constants.notifyAllMessages
        property bool notificationSoundsEnabled: true
        property int notificationMessagePreviewSetting: Constants.notificationPreviewNameAndMessage
        property bool allowNotificationsFromNonContacts: false
        property var whitelistedUnfurlingSites: ({})
        property bool neverAskAboutUnfurlingAgain: false
        property bool hideChannelSuggestions: false
        property bool hideSignPhraseModal: false

        property int fontSize: Constants.fontSizeM

        // Browser settings
        property var bookmarkFavicons: ({})
        property bool autoLoadImages: true
        property bool javaScriptEnabled: true
        property bool errorPageEnabled: true
        property bool pluginsEnabled: true
        property bool autoLoadIconsForPage: true
        property bool touchIconsEnabled: true
        property bool webRTCPublicInterfacesOnly: false
        property bool devToolsEnabled: false
        property bool pdfViewerEnabled: true
        property bool compatibilityMode: true
    }

    Settings {
        id: appSettings
        fileName: profileModel.profileSettingsFile
        property var chatSplitView
        property var walletSplitView
        property var profileSplitView
        property bool walletEnabled: defaultAppSettings.walletEnabled
        property bool browserEnabled: defaultAppSettings.browserEnabled
        property bool displayChatImages: defaultAppSettings.displayChatImages
        property bool compactMode: defaultAppSettings.compactMode
        property string locale: defaultAppSettings.locale
        property var recentEmojis: defaultAppSettings.recentEmojis
        property real volume: defaultAppSettings.volume
        property int notificationSetting: defaultAppSettings.notificationSetting
        property bool notificationSoundsEnabled: defaultAppSettings.notificationSoundsEnabled
        property int notificationMessagePreviewSetting: defaultAppSettings.notificationMessagePreviewSetting
        property bool allowNotificationsFromNonContacts: defaultAppSettings.allowNotificationsFromNonContacts
        property var whitelistedUnfurlingSites: defaultAppSettings.whitelistedUnfurlingSites
        property bool neverAskAboutUnfurlingAgain: defaultAppSettings.neverAskAboutUnfurlingAgain
        property bool hideChannelSuggestions: defaultAppSettings.hideChannelSuggestions
        property int fontSize: defaultAppSettings.fontSize
        property bool hideSignPhraseModal: defaultAppSettings.hideSignPhraseModal

        // Browser settings
        property bool autoLoadImages: defaultAppSettings.autoLoadImages
        property bool javaScriptEnabled: defaultAppSettings.javaScriptEnabled
        property bool errorPageEnabled: defaultAppSettings.errorPageEnabled
        property bool pluginsEnabled: defaultAppSettings.pluginsEnabled
        property bool autoLoadIconsForPage: defaultAppSettings.autoLoadIconsForPage
        property bool touchIconsEnabled: defaultAppSettings.touchIconsEnabled
        property bool webRTCPublicInterfacesOnly: defaultAppSettings.webRTCPublicInterfacesOnly
        property bool devToolsEnabled: defaultAppSettings.devToolsEnabled
        property bool pdfViewerEnabled: defaultAppSettings.pdfViewerEnabled
        property bool compatibilityMode: defaultAppSettings.compatibilityMode
    }

    signal whitelistChanged()

    function changeUnfurlingWhitelist(site, enabled) {
        appSettings.whitelistedUnfurlingSites[site] = enabled
        applicationWindow.whitelistChanged()
    }

    Connections {
        target: profileModel
        onProfileSettingsFileChanged: {
            settingsLoaded()
            if (appSettings.locale !== "en") {
                profileModel.changeLocale(appSettings.locale)
            }
        }
    }

    SystemTrayIcon {
        visible: true
        icon.source: "shared/img/status-logo.png"
        menu: Menu {
            MenuItem {
                //% "Quit"
                text: qsTrId("quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
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
            initialState: hasAccounts ? stateLogin : stateIntro

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
