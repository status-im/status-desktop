import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import Qt.labs.settings 1.1
import QtQuick.Window 2.15
import QtQml 2.15
import QtQuick.Controls.Universal 2.15

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0

import mainui 1.0
import AppLayouts.Onboarding 1.0
import AppLayouts.Onboarding2 1.0 as Onboarding2
import AppLayouts.Onboarding2.stores 1.0

import StatusQ 0.1
import StatusQ.Core.Theme 0.1

StatusWindow {
    id: applicationWindow

    property bool appIsReady: false

    readonly property var featureFlags: typeof featureFlagsRootContextProperty !== undefined ? featureFlagsRootContextProperty : null
    property MetricsStore metricsStore: MetricsStore {}
    property UtilsStore utilsStore: UtilsStore {}

    Universal.theme: Universal.System

    objectName: "mainWindow"
    minimumWidth: 1200
    minimumHeight: 680
    color: Theme.palette.background
    title: {
        // Set application settings
        Qt.application.name = "Status Desktop"
        Qt.application.displayName = qsTr("Status Desktop")
        Qt.application.organization = "Status"
        Qt.application.domain = "status.im"
        Qt.application.version = aboutModule.getCurrentVersion()
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

        if (geometry === undefined ||
            // If the monitor setup of the user changed, it's possible that the old geometry now falls out of the monitor range
            // In this case, we reset to the basic geometry
            geometry.x > Screen.desktopAvailableWidth ||
            geometry.y > Screen.desktopAvailableHeight ||
            geometry.width > Screen.desktopAvailableWidth ||
            geometry.height > Screen.desktopAvailableHeight ||
            geometry.x < 0 || geometry.y < 0)
        {
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
            applicationWindow.width = Math.max(geometry.width, applicationWindow.minimumWidth)
            applicationWindow.height = Math.max(geometry.height, applicationWindow.minimumHeight)
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

    QtObject {
        id: d
        property int previousApplicationState: -1

        property var mockedKeycardControllerWindow
        function runMockedKeycardControllerWindow() {
            if (localAppSettings.displayMockedKeycardWindow()) {
                if (!!d.mockedKeycardControllerWindow) {
                    d.mockedKeycardControllerWindow.close()
                }

                console.info("running mocked keycard lib controller window")
                var c = Qt.createComponent("qrc:/imports/shared/panels/MockedKeycardLibControllerWindow.qml");
                if (c.status === Component.Ready) {
                    d.mockedKeycardControllerWindow = c.createObject(applicationWindow, {
                                                                         "relatedModule": startupOnbaordingLoader.item.visible?
                                                                                              startupModule :
                                                                                              mainModule
                                                                     })
                    if (d.mockedKeycardControllerWindow) {
                        d.mockedKeycardControllerWindow.show()
                        d.mockedKeycardControllerWindow.requestActivate()
                    }
                }
            }
        }
    }

    Action {
        shortcut: StandardKey.FullScreen
        onTriggered: applicationWindow.toggleFullScreen()
    }

    Action {
        shortcut: "Ctrl+M"
        onTriggered: applicationWindow.toggleMinimize()
    }

    Action {
        shortcut: StandardKey.Close
        onTriggered: {
            applicationWindow.visible = false;
        }
    }

    Action {
        shortcut: StandardKey.Quit
        onTriggered: {
            Qt.quit()
        }
    }

    //TODO remove direct backend access
    Connections {
        id: windowsOsNotificationsConnection
        enabled: Qt.platform.os === Constants.windows
        target: Qt.platform.os === Constants.windows && typeof mainModule !== "undefined" ? mainModule : null
        function onDisplayWindowsOsNotification(title, message) {
            systemTray.showMessage(title, message)
        }
    }

    //TODO remove direct backend access
    Connections {
        target: startupModule

        function onStartUpUIRaised() {
            applicationWindow.appIsReady = true;
            applicationWindow.storeAppState();

            d.runMockedKeycardControllerWindow()
        }

        function onAppStateChanged(state) {
            if(state === Constants.appState.startup) {
                // we're here only in case of error when we're returning from the app loading state
                loader.sourceComponent = undefined
                appLoadingAnimation.active = false
                startupOnbaordingLoader.item.visible = true
            }
            else if(state === Constants.appState.appLoading) {
                loader.sourceComponent = undefined
                appLoadingAnimation.active = false
                appLoadingAnimation.active = true
                startupOnbaordingLoader.item.visible = false
            }
            else if(state === Constants.appState.main) {
                // We set main module to the Global singleton once user is logged in and we move to the main app.
                appLoadingAnimation.active = localAppSettings && localAppSettings.fakeLoadingScreenEnabled
                appLoadingAnimation.runningProgressAnimation = localAppSettings && localAppSettings.fakeLoadingScreenEnabled
                if (!appLoadingAnimation.runningProgressAnimation) {
                    mainModule.fakeLoadingScreenFinished()
                }
                Global.appIsReady = true

                loader.sourceComponent = app

                if(localAccountSensitiveSettings.recentEmojis === "") {
                    localAccountSensitiveSettings.recentEmojis = [];
                }
                if (localAccountSensitiveSettings.hiddenCommunityWelcomeBanners === "") {
                    localAccountSensitiveSettings.hiddenCommunityWelcomeBanners = [];
                }
                if (localAccountSensitiveSettings.hiddenCommunityBackUpBanners === "") {
                    localAccountSensitiveSettings.hiddenCommunityBackUpBanners = [];
                }
                startupOnbaordingLoader.item.unload()
                startupOnbaordingLoader.item.visible = false

                Theme.changeTheme(localAppSettings.theme, systemPalette.isCurrentSystemThemeDark())
                Theme.changeFontSize(localAccountSensitiveSettings.fontSize)

                d.runMockedKeycardControllerWindow()
            } else if(state === Constants.appState.appEncryptionProcess) {
                loader.sourceComponent = undefined
                appLoadingAnimation.active = true
                appLoadingAnimation.item.splashScreenText = qsTr("Database re-encryption in progress. Please do NOT close the app.\nThis may take up to 30 minutes. Sorry for the inconvenience.\n\n This process is a one time thing and is necessary for the proper functioning of the application.")
                startupOnbaordingLoader.item.visible = false
            }
        }
    }

    //! Workaround for custom QQuickWindow
    Connections {
        target: applicationWindow
        function onClosing(close) {
            if (Qt.platform.os === Constants.mac) {
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

    // On MacOS, explicitely restore the window on activating
    Connections {
        target: Qt.application
        enabled: Qt.platform.os === Constants.mac
        function onStateChanged() {
            if (Qt.application.state == d.previousApplicationState
                && Qt.application.state == Qt.ApplicationActive) {
                makeStatusAppActive()
            }
            d.previousApplicationState = Qt.application.state
        }
    }

    //TODO remove direct backend access
    Connections {
        target: singleInstance

        function onSecondInstanceDetected() {
            console.log("User attempted to run the second instance of the application")
            // activating this instance to give user visual feedback
            makeStatusAppActive()
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
        Theme.changeTheme(startupOnbaordingLoader.item.visible ? Universal.System : localAppSettings.theme,
                          systemPalette.isCurrentSystemThemeDark())
    }

    Component.onCompleted: {
        Theme.changeTheme(Universal.System, systemPalette.isCurrentSystemThemeDark());

        restoreAppState();

        Global.openMetricsEnablePopupRequested.connect(openMetricsEnablePopup)
        Global.addCentralizedMetricIfEnabled.connect(metricsStore.addCentralizedMetricIfEnabled)
    }

    signal navigateTo(string path)

    function makeStatusAppActive() {
        applicationWindow.restoreWindowState()
        applicationWindow.visible = true
        applicationWindow.raise()
        applicationWindow.requestActivate()
    }

    function openMetricsEnablePopup(placement, cb = null) {
        metricsPopupLoader.active = true
        metricsPopupLoader.item.visible = true
        metricsPopupLoader.item.placement = placement
        if (cb)
            cb(metricsPopupLoader.item)
        if(!localAppSettings.metricsPopupSeen) {
            localAppSettings.metricsPopupSeen = true
        }
    }

    StatusTrayIcon {
        id: systemTray
        objectName: "systemTray"
        isProduction: production
        showRedDot: typeof mainModule !== "undefined" ? mainModule.notificationAvailable : false
        onActivateApp: {
            applicationWindow.makeStatusAppActive()
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        asynchronous: true
        opacity: active ? 1.0 : 0.0
        visible: (opacity > 0.0001)
        Behavior on opacity { NumberAnimation { duration: 120 }}
    }

    Component {
        id: app
        AppMain {
            utilsStore: applicationWindow.utilsStore

            sysPalette: systemPalette
            visible: !appLoadingAnimation.active
            isCentralizedMetricsEnabled: metricsStore.isCentralizedMetricsEnabled
        }
    }

    Loader {
        id: appLoadingAnimation
        objectName: "loadingAnimationLoader"
        property bool runningProgressAnimation: false
        anchors.fill: parent
        active: false
        sourceComponent: DidYouKnowSplashScreen {
            objectName: "splashScreen"
            NumberAnimation on progress { from: 0.0; to: 1; duration: 30000; running: runningProgressAnimation }
            onProgressChanged: {
                if (progress === 1) {
                    appLoadingAnimation.active = false
                    mainModule.fakeLoadingScreenFinished()
                }
            }
        }
        onActiveChanged: {
            if (!active) {
                // animation is finished, app main will be shown
                // open metrics popup only if it has not been seen
                if(!localAppSettings.metricsPopupSeen) {
                    openMetricsEnablePopup(Constants.metricsEnablePlacement.startApp, null)
                }
            }
        }
    }

    Component {
        id: splashScreenV2
        DidYouKnowSplashScreen {
            readonly property string pageClassName: "Splash"
            property bool runningProgressAnimation
            NumberAnimation on progress {
                from: 0.0
                to: 1
                duration: onboarding.splashScreenDurationMs
                running: runningProgressAnimation
                onStopped: {
                    console.warn("!!! SPLASH SCREEN DONE")
                    console.warn("!!! RESTARTING FLOW")
                    onboarding.restartFlow()
                }
            }
        }
    }

    Loader {
        id: startupOnbaordingLoader
        anchors.fill: parent
        sourceComponent: featureFlags && featureFlags.onboardingV2Enabled ? onboardingV2 : onboardingV1
    }

    Component {
        id: onboardingV1

        OnboardingLayout {
            objectName: "startupOnboardingLayout"
            anchors.fill: parent

            utilsStore: applicationWindow.utilsStore
        }
    }

    Component {
        id: onboardingV2

        Onboarding2.OnboardingLayout {
            objectName: "startupOnboardingLayout"
            anchors.fill: parent

            networkChecksEnabled: true
            splashScreenDurationMs: 3000
            biometricsAvailable: Qt.platform.os === Constants.mac

            onboardingStore: OnboardingStore {
                function setPin(pin: string) { // -> bool
                    console.log("OnboardingStore.setPin", ["pin"])
                    return true
                }

                function startKeypairTransfer() { // -> void
                    console.log("OnboardingStore.startKeypairTransfer")
                }

                // password
                function getPasswordStrengthScore(password: string) { // -> int
                    console.log("OnboardingStore.getPasswordStrengthScore", ["password"])
                    return Math.min(password.length-1, 4)
                }

                // seedphrase/mnemonic
                function validMnemonic(mnemonic: string) { // -> bool
                    console.log("OnboardingStore.validMnemonic", ["mnemonic"])
                    return true
                }
                function getMnemonic() { // -> string
                    console.log("OnboardingStore.getMnemonic()")
                    return ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"].join(" ")
                }
                function mnemonicWasShown() { // -> void
                    console.log("OnboardingStore.mnemonicWasShown()")
                }
                function removeMnemonic() { // -> void
                    console.log("OnboardingStore.removeMnemonic()")
                }

                function validateLocalPairingConnectionString(connectionString: string) { // -> bool
                    console.log("OnboardingStore.validateLocalPairingConnectionString", ["connectionString"])
                    return !Number.isNaN(parseInt(connectionString))
                }
                function inputConnectionStringForBootstrapping(connectionString: string) { // -> void
                    console.log("OnboardingStore.inputConnectionStringForBootstrapping", ["connectionString"])
                }
            }

            metricsStore: MetricsStore {
                readonly property var d: QtObject {
                    id: d
                    property bool isCentralizedMetricsEnabled
                }

                function toggleCentralizedMetrics(enabled) {
                    d.isCentralizedMetricsEnabled = enabled
                }

                function addCentralizedMetricIfEnabled(eventName, eventValue = null) {
                    console.log("MetricsStore.addCentralizedMetricIfEnabled", ["eventName", "eventValue"])
                }

                readonly property bool isCentralizedMetricsEnabled : d.isCentralizedMetricsEnabled
            }

            onFinished: (flow, data) => {
                console.warn("!!! ONBOARDING FINISHED; flow:", flow, "; data:", JSON.stringify(data))

                console.warn("!!! SIMULATION: SHOWING SPLASH")
                stack.clear()
                stack.push(splashScreenV2, { runningProgressAnimation: true })
            }
            onKeycardFactoryResetRequested: {
                console.warn("!!! FACTORY RESET; RESTARTING FLOW")
            }
            onKeycardReloaded: {
                console.warn("!!! RELOAD KEYCARD")
            }
        }
    }

    Loader {
        id: metricsPopupLoader
        active: false
        sourceComponent: MetricsEnablePopup {
            visible: true
            onClosed: metricsPopupLoader.active = false
            onSetMetricsEnabledRequested: {
                applicationWindow.metricsStore.toggleCentralizedMetrics(enabled)
                if (enabled) {
                    Global.addCentralizedMetricIfEnabled("usage_data_shared", {placement: metricsPopupLoader.item.placement})
                }
            }
        }
    }

    MacTrafficLights { // FIXME should be a direct part of StatusAppNavBar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 13

        visible: Qt.platform.os === Constants.mac && applicationWindow.visibility !== Window.FullScreen

        onClose: {
            if (loader.sourceComponent != app) {
                Qt.quit()
                return
            }

            if (localAccountSensitiveSettings.quitOnClose) {
                Qt.quit();
                return
            }

            applicationWindow.visible = false;
        }

        onMinimised: {
            applicationWindow.toggleMinimize()
        }

        onMaximized: {
            applicationWindow.toggleFullScreen()
        }
    }
}
