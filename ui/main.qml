import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQml

import utils
import shared
import shared.panels
import shared.popups
import shared.stores

import mainui
import AppLayouts.stores as AppStores

import AppLayouts.Onboarding.enums
import AppLayouts.Onboarding2 as Onboarding2
import AppLayouts.Onboarding2.stores
import AppLayouts.Onboarding2.pages

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Backpressure

StatusWindow {
    id: applicationWindow

    property bool appIsReady: false

    readonly property AppStores.FeatureFlagsStore featureFlagsStore: AppStores.FeatureFlagsStore {
        readonly property var featureFlags: typeof featureFlagsRootContextProperty !== undefined ? featureFlagsRootContextProperty : null

        connectorEnabled: featureFlags ? featureFlags.connectorEnabled : false
        dappsEnabled: featureFlags ? featureFlags.dappsEnabled : false
        swapEnabled: featureFlags ? featureFlags.swapEnabled : false
        sendViaPersonalChatEnabled: featureFlags ? featureFlags.sendViaPersonalChatEnabled : false
        paymentRequestEnabled: featureFlags ? featureFlags.paymentRequestEnabled : false
        simpleSendEnabled: featureFlags ? featureFlags.simpleSendEnabled : false
        keycardEnabled: featureFlags ? featureFlags.keycardEnabled : false
        marketEnabled: featureFlags ? featureFlags.marketEnabled : false
        homePageEnabled: featureFlags ? featureFlags.homePageEnabled : false
    }

    property MetricsStore metricsStore: MetricsStore {}
    property UtilsStore utilsStore: UtilsStore {}

    objectName: "mainWindow"
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

    function updatePaddings() {
        if (applicationWindow.width < Theme.portraitBreakpoint.width) {
            const coefficient = applicationWindow.width / Theme.portraitBreakpoint.width;
            Theme.updatePaddings(Theme.defaultPadding * coefficient);
        } else {
            Theme.updatePaddings(Theme.defaultPadding);
        }
    }

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
            applicationWindow.width = Math.max(geometry.width, Theme.portraitBreakpoint.width)
            applicationWindow.height = Math.max(geometry.height, Theme.portraitBreakpoint.height)
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
    onWidthChanged: {
        updatePaddings()
        Qt.callLater(storeAppState)
    }
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
                                                                         "relatedModule": mainModule
                                                                     })
                    if (d.mockedKeycardControllerWindow) {
                        d.mockedKeycardControllerWindow.show()
                        d.mockedKeycardControllerWindow.requestActivate()
                    }
                }
            }
        }
    }

    // Only set minimum width/height for desktop apps
    Binding {
        target: applicationWindow
        property: "minimumWidth"
        when: !Constants.isMobile
        value: Theme.portraitBreakpoint.width
    }
    Binding {
        target: applicationWindow
        property: "minimumHeight"
        when: !Constants.isMobile
        value: Theme.portraitBreakpoint.height
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
            Qt.exit(0)
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

    function moveToAppMain() {
        mainModule.fakeLoadingScreenFinished()

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

        Theme.changeTheme(localAppSettings.theme)
        Theme.changeFontSize(localAccountSensitiveSettings.fontSize)

        d.runMockedKeycardControllerWindow()

        startupOnboardingLoader.active = false
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
                } else if (loader.sourceComponent == app) {
                    if (localAccountSensitiveSettings.quitOnClose) {
                        Qt.quit();
                    } else {
                        close.accepted = false
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
            if (Qt.application.state === d.previousApplicationState
                && Qt.application.state === Qt.ApplicationActive) {
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

    Component.onCompleted: {
        console.info(">>> %1 %2 started, using Qt version %3".arg(Qt.application.name).arg(Qt.application.version).arg(SystemUtils.qtRuntimeVersion()))

        Theme.changeTheme(Theme.Style.System);

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
            featureFlagsStore: applicationWindow.featureFlagsStore

            visible: !startupOnboardingLoader.active
            isCentralizedMetricsEnabled: metricsStore.isCentralizedMetricsEnabled

            keychain: appKeychain
        }
    }

    Component {
        id: splashScreenV2
        DidYouKnowSplashScreen {
            objectName: "splashScreenV2"
            readonly property bool backAvailableHint: false
            readonly property string pageClassName: "Splash"
            property bool runningProgressAnimation
            messagesEnabled: true
            NumberAnimation on progress {
                from: 0.0
                to: 1
                duration: !!localAppSettings && localAppSettings.fakeLoadingScreenEnabled ? 30000 : 3000
                running: runningProgressAnimation
            }
        }
    }

    Loader {
        id: startupOnboardingLoader
        anchors.fill: parent
        sourceComponent: onboardingV2
    }

    Keychain {
        service: "StatusDesktop"

        id: appKeychain

        // These signal handlers keep the compatibility with the old keychain approach,
        // which is used by `keycard_popup` (any auth inside the app) and the old onboarding.
        // NOTE: this hack won't work if changes are made with another Keychain instance.
        onCredentialSaved: (account) => {
                               localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.store
                           }
        onCredentialDeleted: (account) => {
                                 localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.never
                             }
    }

    Component {
        id: onboardingV2

        Onboarding2.OnboardingLayout {
            id: onboardingLayout
            objectName: "startupOnboardingLayout"

            anchors.fill: parent

            isKeycardEnabled: featureFlagsStore.keycardEnabled
            networkChecksEnabled: true

            onboardingStore: OnboardingStore {
                id: onboardingStore

                onAppLoaded: {
                    applicationWindow.appIsReady = true
                    applicationWindow.storeAppState()
                    moveToAppMain()
                }
                onAccountLoginError: function (error, wrongPassword) {
                    onboardingLayout.unwindToLoginScreen() // error handled internally
                }
                onSaveBiometricsRequested: (account, credential) => {
                    appKeychain.saveCredential(account, credential)
                }
                onDeleteBiometricsRequested: (account) => {
                    appKeychain.deleteCredential(account)
                }
            }

            keychain: appKeychain

            onFinished: (flow, data) => {
                const error = onboardingStore.finishOnboardingFlow(flow, data)

                if (error !== "") {
                    // We should never be here since everything should be validated already
                    console.error("!!! ONBOARDING FINISHED WITH ERROR:", error)
                    return
                }

                // We use a custom handler for LoginWithLostKeycardSeedphrase flow.
                // At the moment of implementation, this was the simplest move to make it work in the given code.
                // Ideally, ConvertKeycardAccountPage should be created inside the OnboardingLayout and not here,
                // but this would require more changes and eventually give more inconsistencies.
                if (flow === Onboarding.OnboardingFlow.LoginWithLostKeycardSeedphrase) {
                    stack.push(convertingKeycardAccountPage)
                } else {
                    stack.push(splashScreenV2, {runningProgressAnimation: true})
                }
            }

            onLoginRequested: function (keyUid, method, data) {
                stack.push(splashScreenV2, { runningProgressAnimation: true }, StackView.Immediate) // we unwind on error
                onboardingStore.loginRequested(keyUid, method, data)
            }

            onShareUsageDataRequested: {
                applicationWindow.metricsStore.toggleCentralizedMetrics(enabled)
                if (enabled) {
                    Global.addCentralizedMetricIfEnabled("usage_data_shared", {placement: Constants.metricsEnablePlacement.onboarding})
                }
            }
            onCurrentPageNameChanged: {
                if (currentPageName !== "") {
                    Global.addCentralizedMetricIfEnabled("navigation", {viewId: currentPageName})
                }
            }

            Component {
                id: convertingKeycardAccountPage

                ConvertKeycardAccountPage {
                    convertKeycardAccountState: onboardingStore.convertKeycardAccountState
                    onRestartRequested: {
                        SystemUtils.restartApplication()
                    }
                    onBackToLoginRequested: {
                        onboardingLayout.unwindToLoginScreen()
                    }
                }
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
