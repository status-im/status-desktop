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

import "./onboarding"
import "./app"
import "./sounds"
import "./shared"
import "./imports"

StatusWindow {
    property bool hasAccounts: !!loginModel.rowCount()
    property bool removeMnemonicAfterLogin: false
    property alias dragAndDrop: dragTarget
    property bool popupOpened: false
    property bool displayBeforeGetStartedModal: !hasAccounts

    Universal.theme: Universal.System

    Settings {
        id: globalSettings
        category: "global"
        fileName: profileModel.globalSettingsFile
        property string locale: "en"
        property int theme: 2

        Component.onCompleted: {
            profileModel.changeLocale(locale)
        }
    }

    Settings {
        id: appSettings
        fileName: profileModel.settingsFile
        property string storeToKeychain: ""

        property var chatSplitView
        property var walletSplitView
        property var profileSplitView
        property bool communitiesEnabled: false
        property bool isWalletEnabled: false
        property bool isWalletV2Enabled: false
        property bool nodeManagementEnabled: false
        property bool isBrowserEnabled: false
        property bool isActivityCenterEnabled: false
        property bool showOnlineUsers: false
        property bool expandUsersList: false
        property bool isGifWidgetEnabled: false
        property bool isTenorWarningAccepted: false
        property bool displayChatImages: false
        property bool useCompactMode: true
        property bool timelineEnabled: true
        property var recentEmojis: []
        property var hiddenCommunityWelcomeBanners: []
        property var hiddenCommunityBackUpBanners: []
        property real volume: 0.2
        property int notificationSetting: Constants.notifyJustMentions
        property bool notificationSoundsEnabled: true
        property bool useOSNotifications: true
        property int notificationMessagePreviewSetting: Constants.notificationPreviewNameAndMessage
        property bool notifyOnNewRequests: true
        property var whitelistedUnfurlingSites: ({})
        property bool neverAskAboutUnfurlingAgain: false
        property bool hideChannelSuggestions: false
        property int fontSize: Constants.fontSizeM
        property bool hideSignPhraseModal: false
        property bool onlyShowContactsProfilePics: true
        property bool quitOnClose: false
        property string skinColor: ""
        property bool showDeleteMessageWarning: true
        property bool downloadChannelMessagesEnabled: false
        property int lastModeActiveTab: 0
        property string lastModeActiveCommunity: ""

        // Browser settings
        property bool showBrowserSelector: true
        property bool openLinksInStatus: true
        property bool shouldShowFavoritesBar: true
        property string browserHomepage: ""
        property int shouldShowBrowserSearchEngine: Constants.browserSearchEngineDuckDuckGo
        property int useBrowserEthereumExplorer: Constants.browserEthereumExplorerEtherscan
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

        // Ropsten settings
        property bool stickersEnsRopsten: false
    }

    id: applicationWindow
    objectName: "mainWindow"
    minimumWidth: 900
    minimumHeight: 600
    width: Math.min(1232, Screen.desktopAvailableWidth - 64)
    height: Math.min(770, Screen.desktopAvailableHeight - 64)
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
        enabled: loader.item ? loader.item.currentView !== Utils.getAppSectionIndex(Constants.browser)
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

    //! Workaround for custom QQuickWindow
    Connections {
        target: applicationWindow
        onClosing: {
            loader.sourceComponent = undefined
            close.accepted = true
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
                chatsModel.handleProtocolUri(event.uri)
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
        Style.changeTheme(globalSettings.theme, systemPalette.isCurrentSystemThemeDark())
    }

    Component.onCompleted: {
        Style.changeTheme(globalSettings.theme, systemPalette.isCurrentSystemThemeDark())
        setX(Qt.application.screens[0].width / 2 - width / 2);
        setY(Qt.application.screens[0].height / 2 - height / 2);

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
                    return "shared/img/status-logo-round-rect.svg"
                else
                    return "shared/img/status-logo-circle.svg"
            } else {
                if (Qt.platform.os == "osx")
                    return "shared/img/status-logo-dev-round-rect.svg"
                else
                    return "shared/img/status-logo-dev-circle.svg"
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

    function checkForStoringPassToKeychain(username, password, clearStoredValue) {
        if(Qt.platform.os == "osx")
        {
            if(clearStoredValue)
            {
                appSettings.storeToKeychain = ""
            }

            if(appSettings.storeToKeychain === "" ||
               appSettings.storeToKeychain === Constants.storeToKeychainValueNotNow)
            {
                storeToKeychainConfirmationPopup.password = password
                storeToKeychainConfirmationPopup.username = username
                storeToKeychainConfirmationPopup.open()
            }
        }
    }

    ConfirmationDialog {
        id: storeToKeychainConfirmationPopup
        property string password: ""
        property string username: ""
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
            username = ""
            storeToKeychainConfirmationPopup.close()
        }

        onConfirmButtonClicked: {
            appSettings.storeToKeychain = Constants.storeToKeychainValueStore
            loginModel.storePassword(username, password)
            finish()
        }

        onRejectButtonClicked: {
            appSettings.storeToKeychain = Constants.storeToKeychainValueNotNow
            finish()
        }

        onCancelButtonClicked: {
            appSettings.storeToKeychain = Constants.storeToKeychainValueNever
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
                    signal: onboardingModel.moveToAppState
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: loader.sourceComponent = genKey

                DSM.SignalTransition {
                    targetState: appState
                    signal: onboardingModel.moveToAppState
                }
            }

            DSM.State {
                id: stateLogin
                onEntered: loader.sourceComponent = login

                DSM.SignalTransition {
                    targetState: appState
                    signal: loginModel.moveToAppState
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

    DropArea {
        id: dragTarget

        signal droppedOnValidScreen(var drop)
        property alias droppedUrls: rptDraggedPreviews.model
        readonly property int chatView: Utils.getAppSectionIndex(Constants.chat)
        readonly property int timelineView: Utils.getAppSectionIndex(Constants.timeline)
        property bool enabled: !drag.source && !!loader.item && !!loader.item.appLayout &&
                               (
                                   // in chat view
                                   (loader.item.appLayout.appView.currentIndex === chatView &&
                                    (
                                        // in a one-to-one chat
                                        chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne ||
                                        // in a private group chat
                                        chatsModel.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat
                                        )
                                    ) ||
                                   // in timeline view
                                   loader.item.appLayout.appView.currentIndex === timelineView ||
                                   // In community section
                                   chatsModel.communities.activeCommunity.active
                                   )

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
        AppMain {}
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
                if (appSettings.quitOnClose) {
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
