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
        property bool communitiesEnabled: false
        property bool walletEnabled: false
        property bool nodeManagementEnabled: false
        property bool browserEnabled: false
        property bool displayChatImages: false
        property bool timelineEnabled: true
        property bool useCompactMode
        property string locale: "en"
        property var recentEmojis: []
        property real volume: 0.2
        property int notificationSetting: Constants.notifyAllMessages
        property bool notificationSoundsEnabled: true
        property bool useOSNotifications: true
        property int notificationMessagePreviewSetting: Constants.notificationPreviewNameAndMessage
        property bool allowNotificationsFromNonContacts: false
        property var whitelistedUnfurlingSites: ({})
        property bool neverAskAboutUnfurlingAgain: false
        property bool hideChannelSuggestions: false
        property bool hideSignPhraseModal: false
        property bool onlyShowContactsProfilePics: true

        property int fontSize: Constants.fontSizeM

        // Browser settings
        property bool showBrowserSelector: true
        property bool openLinksInStatus: true
        property bool showFavoritesBar: false
        property string browserHomepage: ""
        property int browserSearchEngine: Constants.browserSearchEngineNone
        property int browserEthereumExplorer: Constants.browserEthereumExplorerNone
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
        property bool communitiesEnabled: defaultAppSettings.communitiesEnabled
        property bool removeMnemonicAfterLogin: false
        property bool walletEnabled: defaultAppSettings.walletEnabled
        property bool nodeManagementEnabled: defaultAppSettings.nodeManagementEnabled
        property bool browserEnabled: defaultAppSettings.browserEnabled
        property bool displayChatImages: defaultAppSettings.displayChatImages
        property bool useCompactMode: defaultAppSettings.useCompactMode
        property bool timelineEnabled: defaultAppSettings.timelineEnabled
        property string locale: defaultAppSettings.locale
        property var recentEmojis: defaultAppSettings.recentEmojis
        property real volume: defaultAppSettings.volume
        property int notificationSetting: defaultAppSettings.notificationSetting
        property bool notificationSoundsEnabled: defaultAppSettings.notificationSoundsEnabled
        property bool useOSNotifications: defaultAppSettings.useOSNotifications
        property int notificationMessagePreviewSetting: defaultAppSettings.notificationMessagePreviewSetting
        property bool allowNotificationsFromNonContacts: defaultAppSettings.allowNotificationsFromNonContacts
        property var whitelistedUnfurlingSites: defaultAppSettings.whitelistedUnfurlingSites
        property bool neverAskAboutUnfurlingAgain: defaultAppSettings.neverAskAboutUnfurlingAgain
        property bool hideChannelSuggestions: defaultAppSettings.hideChannelSuggestions
        property int fontSize: defaultAppSettings.fontSize
        property bool hideSignPhraseModal: defaultAppSettings.hideSignPhraseModal
        property bool onlyShowContactsProfilePics: defaultAppSettings.onlyShowContactsProfilePics

        // Browser settings
        property bool showBrowserSelector: defaultAppSettings.showBrowserSelector
        property bool openLinksInStatus: defaultAppSettings.openLinksInStatus
        property bool showFavoritesBar: defaultAppSettings.showFavoritesBar
        property string browserHomepage: defaultAppSettings.browserHomepage
        property int browserSearchEngine: defaultAppSettings.browserSearchEngine
        property int browserEthereumExplorer: defaultAppSettings.browserEthereumExplorer
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

    Connections {
        target: profileModel
        onProfileSettingsFileChanged: {
            if (appSettings.locale !== "en") {
                profileModel.changeLocale(appSettings.locale)
            }
            const whitelist = profileModel.getLinkPreviewWhitelist()
            try {
                const whiteListedSites = JSON.parse(whitelist)
                let settingsUpdated = false
                const settings = appSettings.whitelistedUnfurlingSites
                const whitelistedHostnames = []

                // Add whitelisted sites in to app settings that are not already there
                whiteListedSites.forEach(site => {
                    if (!settings.hasOwnProperty(site.address))  {
                        settings[site.address] = false
                        settingsUpdated = true
                    }
                    whitelistedHostnames.push(site.address)
                })
                // Remove any whitelisted sites from app settings that don't exist in the
                // whitelist from status-go
                Object.keys(settings).forEach(settingsHostname => {
                    if (!whitelistedHostnames.includes(settingsHostname)) {
                        delete settings[settingsHostname]
                        settingsUpdated = true
                    }
                })
                if (settingsUpdated) {
                    appSettings.whitelistedUnfurlingSites = settings
                }
            } catch (e) {
                console.error('Could not parse the whitelist for sites', e)
            }
            applicationWindow.settingsLoaded()
        }
    }
    Connections {
        target: profileModel
        ignoreUnknownSignals: true
        enabled: appSettings.removeMnemonicAfterLogin
        onInitialized: {
            profileModel.mnemonic.remove()
        }
    }

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
                appSettings.removeMnemonicAfterLogin = false
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
