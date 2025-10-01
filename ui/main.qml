import QtQuick
import QtQuick.Controls

import utils
import shared.panels
import shared.popups
import shared.stores

import mainui
import AppLayouts.stores as AppStores
import AppLayouts.Profile.stores

import AppLayouts.Onboarding
import AppLayouts.Onboarding.enums
import AppLayouts.Onboarding.stores
import AppLayouts.Onboarding.pages

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Platform

StatusWindow {
    id: applicationWindow

    property bool appIsReady: false

    readonly property AppStores.FeatureFlagsStore featureFlagsStore: AppStores.FeatureFlagsStore {
        readonly property var featureFlags: typeof featureFlagsRootContextProperty !== undefined ? featureFlagsRootContextProperty : null

        connectorEnabled: featureFlags ? featureFlags.connectorEnabled : false
        dappsEnabled: featureFlags ? featureFlags.dappsEnabled : false
        browserEnabled: featureFlags ? featureFlags.browserEnabled : false
        swapEnabled: featureFlags ? featureFlags.swapEnabled : false
        sendViaPersonalChatEnabled: featureFlags ? featureFlags.sendViaPersonalChatEnabled : false
        paymentRequestEnabled: featureFlags ? featureFlags.paymentRequestEnabled : false
        simpleSendEnabled: featureFlags ? featureFlags.simpleSendEnabled : false
        keycardEnabled: featureFlags ? featureFlags.keycardEnabled : false
        marketEnabled: featureFlags ? featureFlags.marketEnabled : false
        homePageEnabled: featureFlags ? featureFlags.homePageEnabled : false
        localBackupEnabled: featureFlags ? featureFlags.localBackupEnabled : false
        privacyModeFeatureEnabled: featureFlags ? featureFlags.privacyModeFeatureEnabled : false
    }

    readonly property MetricsStore metricsStore: MetricsStore {}
    readonly property UtilsStore utilsStore: UtilsStore {}
    readonly property LanguageStore languageStore: LanguageStore {}

    objectName: "mainWindow"
    color: Theme.palette.background
    title: {
        // Set application settings
        Qt.application.name = "Status Desktop"
        Qt.application.displayName = d.macOSWindowed ? "" : qsTr("Status Desktop")
        Qt.application.organization = "Status"
        Qt.application.domain = "status.im"
        Qt.application.version = aboutModule.getCurrentVersion()
        return Qt.application.displayName
    }
    visible: true

    flags: Qt.platform.os === SQUtils.Utils.windows ? Qt.Window // extending the content in title is buggy on Windows
              : Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint

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

        readonly property bool macOSWindowed: Qt.platform.os === SQUtils.Utils.mac &&
                                              applicationWindow.visibility !== Window.FullScreen

        function restoreWindowState() {
            switch(lastNonMinVisibility) {
            case Window.Windowed:
                applicationWindow.showNormal()
                break
            case Window.Maximized:
                applicationWindow.showMaximized()
                break
            case Window.FullScreen:
                applicationWindow.showFullScreen()
                break
            }
        }

        property int lastNonMinVisibility
    }

    Binding {
        target: Qt.application
        property: "displayName"
        value: d.macOSWindowed
               ? ""
               : qsTr("Status Desktop")
    }

    // Only set minimum width/height for desktop apps
    Binding {
        target: applicationWindow
        property: "minimumWidth"
        when: !SQUtils.Utils.isMobile
        value: Theme.portraitBreakpoint.width
    }
    Binding {
        target: applicationWindow
        property: "minimumHeight"
        when: !SQUtils.Utils.isMobile
        value: Theme.portraitBreakpoint.height
    }

    Action {
        shortcut: StandardKey.FullScreen
        onTriggered: {
            if (applicationWindow.visibility === Window.FullScreen) {
                applicationWindow.showNormal();
            } else {
                applicationWindow.showFullScreen();
            }
        }
    }

    Action {
        shortcut: "Ctrl+M"
        onTriggered: applicationWindow.showMinimized()
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
        enabled: Qt.platform.os === SQUtils.Utils.windows
        target: Qt.platform.os === SQUtils.Utils.windows && typeof mainModule !== "undefined" ? mainModule : null
        function onDisplayWindowsOsNotification(title, message) {
            systemTray.showMessage(title, message)
        }
    }

    function moveToAppMain() {
        Global.appIsReady = true

        loader.sourceComponent = app

        d.runMockedKeycardControllerWindow()
    }

    /* When the app is closed via CMD+Q or via tray icon, it should be closed (not minimized)
       no matter if minimize on close setting is enabled. In pure qml it's not possible to
       distinguish those close variants. Moreover CMD+Q is not handled via Shortcut nor Action.
       However on QEvent level close events generated by CMD+Q or via try icon are marked as spontaneous
       (clicking close icon on menu bar is not marked as spontaneous). It allows to distinguish those
       situations and handle as desired.
    */
    Connections {
        target: SystemUtils
        enabled: SQUtils.Utils.mac

        function onQuit(spontaneous) {
            if (spontaneous)
                Qt.exit(0)
        }
    }

    Connections {
        target: applicationWindow
        function onVisibilityChanged(visibility) {
            if (applicationWindow.visibility !== Window.Minimized
                        && applicationWindow.visibility !== Window.Hidden) {
                d.lastNonMinVisibility = applicationWindow.visibility
            }
        }
        function onClosing(close) {
            // In case of android, we need to handle moveTaskToBackground explicitly
            if (SQUtils.Utils.isAndroid) {
                close.accepted = false
                SystemUtils.androidMinimizeToBackground()
            // In case not logged in or loading, quit app
            } else if (loader.sourceComponent != app) {
                close.accepted = true
            }
            // In case user has set to close should quit app
            else if (localAccountSensitiveSettings.quitOnClose) {
                close.accepted = true
            }
            else {
                // The app is already minimized. The user really wants to quit the app
                // The user really wants to quit the app
                if (applicationWindow.visibility === Window.Minimized) {
                    close.accepted = true
                    return
                }

                close.accepted = false
                /* In case of mac in fullscreen mode, hiding the window leads to black screen.
                Hence we exit Fullscreen on system close and then the user can perform an actual
                hide of the app */
                if(applicationWindow.visibility === Window.FullScreen &&
                        Qt.platform.os === SQUtils.Utils.mac) {
                    applicationWindow.showNormal()
                    return
                }
                applicationWindow.showMinimized()
            }
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

    //TODO: Remove once qt 6.9.2 is available
    //https://bugreports.qt.io/browse/QTBUG-135808
    function applySafeAreaDirtyHack() {
        if (Qt.platform.os === SQUtils.Utils.android) {
            //First fix the safe area margins
            applicationWindow.visibility = Window.FullScreen
            Qt.callLater(() => {
                applicationWindow.visibility = Window.Maximized
            })

            //Then create a dummy header with the system accent color
            //Otherwise the system toolbar is invisible
            macOSSafeAreaLoader.sourceComponent = androidHeaderComponent
            macOSSafeAreaLoader.active = true
        }
    }

    Component.onCompleted: {
        console.info(">>> %1 %2 started, using Qt version %3".arg(Qt.application.name).arg(Qt.application.version).arg(SystemUtils.qtRuntimeVersion()))

        if (languageStore.currentLanguage === "" && // if we haven't configured the language yet...
                languageStore.availableLanguages.includes(Qt.uiLanguage)) { // ...and we have a translation for it
            // set the language to the user's OS default
            languageStore.changeLanguage(Qt.uiLanguage, true /*shouldRetranslate*/)
        } else {
            // set the configured language
            languageStore.changeLanguage(languageStore.currentLanguage, true /*shouldRetranslate*/)
        }

        Theme.changeTheme(Theme.Style.System)

        applySafeAreaDirtyHack()
        restoreAppState()

        Global.openMetricsEnablePopupRequested.connect(openMetricsEnablePopup)
        Global.addCentralizedMetricIfEnabled.connect(metricsStore.addCentralizedMetricIfEnabled)

        // Without this the paddings are not updated correctly when launched in portrait mode
        updatePaddings()
    }

    signal navigateTo(string path)

    function makeStatusAppActive() {
        d.restoreWindowState()
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
        anchors.topMargin: Qt.platform.os === SQUtils.Utils.mac ? 0 : parent.SafeArea.margins.top 
        anchors.bottomMargin: parent.SafeArea.margins.bottom
        anchors.leftMargin: parent.SafeArea.margins.left
        anchors.rightMargin: parent.SafeArea.margins.right
        asynchronous: true
        opacity: active ? 1.0 : 0.0
        visible: (opacity > 0.0001)
        Behavior on opacity { NumberAnimation { duration: 120 }}
        /* only unload splash screen once appmain is loaded else we see
        an empty screen for a sec until it is loaded */
        onLoaded: startupOnboardingLoader.active = false
    }

    Component {
        id: app
        AppMain {
            utilsStore: applicationWindow.utilsStore
            featureFlagsStore: applicationWindow.featureFlagsStore
            languageStore: applicationWindow.languageStore

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
            property bool runningProgressAnimation
            messagesEnabled: true
            infiniteLoading: runningProgressAnimation
        }
    }

    Loader {
        id: startupOnboardingLoader

        anchors.fill: parent
        anchors.topMargin: Qt.platform.os === SQUtils.Utils.mac ? 0 : parent.SafeArea.margins.top
        anchors.leftMargin: parent.SafeArea.margins.left
        anchors.rightMargin: parent.SafeArea.margins.right

        sourceComponent: onboardingV2
    }

    Keychain {
        service: "StatusDesktop"

        id: appKeychain

        // These signal handlers keep the compatibility with the old keychain approach,
        // which is used by `keycard_popup` (any auth inside the app) and the old onboarding.
        // NOTE: this hack won't work if changes are made with another Keychain instance.
        onCredentialSaved: (account) => localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.store
        onCredentialDeleted: (account) => localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.never
    }

    Component {
        id: onboardingV2

        OnboardingLayout {
            id: onboardingLayout
            objectName: "startupOnboardingLayout"

            bottomPadding: applicationWindow.SafeArea.margins.bottom

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

            currentLanguage: languageStore.currentLanguage
            availableLanguages: languageStore.availableLanguages
            onChangeLanguageRequested: (newLanguageCode) => languageStore.changeLanguage(newLanguageCode, true /*shouldRetranslate*/)

            keychain: appKeychain

            privacyModeFeatureEnabled: applicationWindow.featureFlagsStore.privacyModeFeatureEnabled

            onFinished: function(flow, data) {
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

            onShareUsageDataRequested: function(enabled) {
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

    Loader {
        id: macOSSafeAreaLoader
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        height: active ? parent.SafeArea.margins.top : 0
        active: Qt.platform.os === SQUtils.Utils.mac && applicationWindow.visibility !== Window.FullScreen
        sourceComponent: macHeaderComponent
    }
    //TODO: Remove once qt 6.9.2 is available
    //To verify before removing:
    //Toolbar icons are visible on both mobile and tablet
    //SafeArea is applied correctly
    Component {
        id: androidHeaderComponent
        Rectangle {
            SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
            color: sysPalette.accent
        }
    }

    Component {
        id: macHeaderComponent
        MouseArea {
            id: headerMouseArea
            enabled: d.macOSWindowed
            propagateComposedEvents: true
            onPressed: {
                applicationWindow.startSystemMove()
                mouse.accepted = false
            }
        }
    }
}
