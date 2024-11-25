import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Backpressure 0.1
import StatusQ.Popups 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores

import shared.panels 1.0
import shared.stores 1.0 as SharedStores
import utils 1.0

// compat
import AppLayouts.Onboarding.stores 1.0 as OOBS

Page {
    id: root

    property OOBS.StartupStore startupStore: OOBS.StartupStore {} // TODO replace with a new OnboardingStore, with just the needed props/functions?
    required property SharedStores.MetricsStore metricsStore // TODO externalize the centralized metrics handling too?
    required property ProfileStores.PrivacyStore privacyStore

    property int splashScreenDurationMs: 30000
    property bool biometricsAvailable: Qt.platform.os === Constants.mac

    readonly property alias stack: stack
    readonly property alias primaryPath: d.primaryPath
    readonly property alias secondaryPath: d.secondaryPath

    signal finished(int primaryPath, int secondaryPath, var data)
    signal keycardFactoryResetRequested() // TODO integrate/switch to an external flow
    signal keycardReloaded()

    function restartFlow() {
        stack.clear()
        stack.push(welcomePage)
        d.resetState()
        d.settings.reset()
    }

    QtObject {
        id: d
        // logic
        property int primaryPath: OnboardingLayout.PrimaryPath.Unknown
        property int secondaryPath: OnboardingLayout.SecondaryPath.Unknown
        readonly property string currentKeycardState: root.startupStore.currentStartupState.stateType
        readonly property var seedWords: root.privacyStore.getMnemonic().split(" ")
        readonly property int numWordsToVerify: 4

        // UI
        readonly property int opacityDuration: 50
        readonly property int swipeDuration: 400

        // state collected
        property string password
        property string keycardPin
        property bool enableBiometrics
        property string syncConnectionString

        function resetState() {
            d.primaryPath = OnboardingLayout.PrimaryPath.Unknown
            d.secondaryPath = OnboardingLayout.SecondaryPath.Unknown
            d.password = ""
            d.keycardPin = ""
            d.enableBiometrics = false
            d.syncConnectionString = ""
        }

        readonly property Settings settings: Settings {
            property bool keycardPromoShown // whether we've seen the keycard promo banner on KeycardIntroPage

            function reset() {
                keycardPromoShown = false
            }
        }

        function pushOrSkipBiometricsPage(subtitle: string) {
            if (root.biometricsAvailable)
                stack.push(enableBiometricsPage, {subtitle})
            else
                mainHandler.onEnableBiometricsRequested(false)
        }
    }

    enum PrimaryPath {
        Unknown,
        CreateProfile,
        Login
    }

    enum SecondaryPath {
        Unknown,

        CreateProfileWithPassword,
        CreateProfileWithSeedphrase,
        CreateProfileWithKeycard,
        CreateProfileWithKeycardNewSeedphrase,
        CreateProfileWithKeycardExistingSeedphrase,

        LoginWithSeedphrase,
        LoginWithSyncing,
        LoginWithKeycard
    }

    // page stack
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: welcomePage

        pushEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: d.opacityDuration; easing.type: Easing.InQuint }
                NumberAnimation { property: "x"; from: (stack.mirrored ? -0.3 : 0.3) * stack.width; to: 0; duration: d.swipeDuration; easing.type: Easing.OutCubic }
            }
        }
        pushExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: d.opacityDuration; easing.type: Easing.OutQuint }
        }
        popEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: d.opacityDuration; easing.type: Easing.InQuint }
                NumberAnimation { property: "x"; from: (stack.mirrored ? -0.3 : 0.3) * -stack.width; to: 0; duration: d.swipeDuration; easing.type: Easing.OutCubic }
            }
        }
        popExit: pushExit
        replaceEnter: pushEnter
        replaceExit: pushExit
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        enabled: stack.depth > 1 && !stack.busy
        cursorShape: undefined // fall thru
        onClicked: stack.pop()
    }

    StatusBackButton {
        width: 44
        height: 44
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        opacity: stack.depth > 1 && !stack.busy ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
        onClicked: stack.pop()
    }

    // main signal handler
    Connections {
        id: mainHandler
        target: stack.currentItem
        ignoreUnknownSignals: true

        // common popups
        function onPrivacyPolicyRequested() {
            console.warn("!!! AUX: PRIVACY POLICY")
            privacyPolicyPopup.createObject(root).open()
        }
        function onTermsOfUseRequested() {
            console.warn("!!! AUX: TERMS OF USE")
            termsOfUsePopup.createObject(root).open()
        }
        function onOpenLink(link: string) {
            Global.openLink(link)
        }
        function onOpenLinkWithConfirmation(link: string, domain: string) {
            Global.openLinkWithConfirmation(link, domain)
        }

        // welcome page
        function onCreateProfileRequested() {
            console.warn("!!! PRIMARY: CREATE PROFILE")
            d.primaryPath = OnboardingLayout.PrimaryPath.CreateProfile
            stack.push(helpUsImproveStatusPage)
        }
        function onLoginRequested() {
            console.warn("!!! PRIMARY: LOG IN")
            d.primaryPath = OnboardingLayout.PrimaryPath.Login
            stack.push(helpUsImproveStatusPage)
        }

        // help us improve page
        function onShareUsageDataRequested(enabled: bool) {
            console.warn("!!! SHARE USAGE DATA:", enabled)
            metricsStore.toggleCentralizedMetrics(enabled)
            Global.addCentralizedMetricIfEnabled("usage_data_shared", {placement: Constants.metricsEnablePlacement.onboarding})
            localAppSettings.metricsPopupSeen = true

            if (d.primaryPath === OnboardingLayout.PrimaryPath.CreateProfile)
                stack.push(createProfilePage)
            else if (d.primaryPath === OnboardingLayout.PrimaryPath.Login)
                stack.push(loginPage)
        }

        // create profile page
        function onCreateProfileWithPasswordRequested() {
            console.warn("!!! SECONDARY: CREATE PROFILE WITH PASSWORD")
            d.secondaryPath = OnboardingLayout.SecondaryPath.CreateProfileWithPassword
            stack.push(createPasswordPage)
        }
        function onCreateProfileWithSeedphraseRequested() {
            console.warn("!!! SECONDARY: CREATE PROFILE WITH SEEDPHRASE")
            d.secondaryPath = OnboardingLayout.SecondaryPath.CreateProfileWithSeedphrase
            stack.push(seedphrasePage, { title: qsTr("Create profile using a recovery phrase"), subtitle: qsTr("Enter your 12, 18 or 24 word recovery phrase")})
        }
        function onCreateProfileWithEmptyKeycardRequested() {
            console.warn("!!! SECONDARY: CREATE PROFILE WITH KEYCARD")
            d.secondaryPath = OnboardingLayout.SecondaryPath.CreateProfileWithKeycard
            stack.push(keycardIntroPage)
        }

        // login page
        function onLoginWithSeedphraseRequested() {
            console.warn("!!! SECONDARY: LOGIN WITH SEEDPHRASE")
            d.secondaryPath = OnboardingLayout.SecondaryPath.LoginWithSeedphrase
            stack.push(seedphrasePage, { title: qsTr("Log in with your Status recovery phrase"), subtitle: qsTr("Enter your 12, 18 or 24 word recovery phrase")})
        }
        function onLoginWithSyncingRequested() {
            console.warn("!!! SECONDARY: LOGIN WITH SYNCING")
            d.secondaryPath = OnboardingLayout.SecondaryPath.LoginWithSyncing
            stack.push(loginBySyncPage)
        }
        function onLoginWithKeycardRequested() {
            console.warn("!!! SECONDARY: LOGIN WITH KEYCARD")
            d.secondaryPath = OnboardingLayout.SecondaryPath.LoginWithKeycard
            stack.push(keycardIntroPage)
        }

        // create password page
        function onSetPasswordRequested(password: string) {
            console.warn("!!! SET PASSWORD REQUESTED")
            d.password = password
            // TODO set the password immediately?
            stack.clear()
            d.pushOrSkipBiometricsPage(qsTr("Use biometrics to fill in your password?"))
        }

        // seedphrase page
        function onSeedphraseValidated() {
            console.warn("!!! SEEDPHRASE VALIDATED")
            if (d.secondaryPath === OnboardingLayout.SecondaryPath.CreateProfileWithSeedphrase || d.secondaryPath === OnboardingLayout.SecondaryPath.LoginWithSeedphrase) {
                console.warn("!!! AFTER SEEDPHRASE -> PASSWORD PAGE")
                stack.push(createPasswordPage)
            } else if (d.secondaryPath === OnboardingLayout.SecondaryPath.CreateProfileWithKeycardExistingSeedphrase) {
                console.warn("!!! AFTER SEEDPHRASE -> KEYCARD PIN PAGE")
                if (root.startupStore.getPin() !== "")
                    stack.push(keycardEnterPinPage)
                else
                    stack.push(keycardCreatePinPage)
            }
        }

        // keycard pages
        function onReloadKeycardRequested() {
            console.warn("!!! RELOAD KEYCARD REQUESTED")
            root.keycardReloaded()
            stack.replace(keycardIntroPage)
        }
        function onKeycardFactoryResetRequested() {
            console.warn("!!! KEYCARD FACTORY RESET REQUESTED")
            // TODO start keycard factory reset in a popup here
            root.keycardFactoryResetRequested()
        }
        function onLoginWithThisKeycardRequested() {
            console.warn("!!! LOGIN WITH THIS KEYCARD REQUESTED")
            d.primaryPath = OnboardingLayout.PrimaryPath.Login
            d.secondaryPath = OnboardingLayout.SecondaryPath.LoginWithKeycard
            if (root.startupStore.getPin() !== "")
                stack.push(keycardEnterPinPage)
            else
                stack.push(keycardCreatePinPage)
        }
        function onEmptyKeycardDetected() {
            console.warn("!!! EMPTY KEYCARD DETECTED")
            if (d.secondaryPath === OnboardingLayout.SecondaryPath.LoginWithKeycard)
                stack.replace(keycardEmptyPage) // NB: replacing the loginPage
            else
                stack.replace(createKeycardProfilePage) // NB: replacing the keycardIntroPage
        }
        function onNotEmptyKeycardDetected() {
            console.warn("!!! NOT EMPTY KEYCARD DETECTED")
            if (d.secondaryPath === OnboardingLayout.SecondaryPath.LoginWithKeycard)
                stack.push(keycardEnterPinPage)
            else
                stack.push(keycardNotEmptyPage)
        }

        function onCreateKeycardProfileWithNewSeedphrase() {
            console.warn("!!! CREATE KEYCARD PROFILE WITH NEW SEEDPHRASE")
            d.secondaryPath = OnboardingLayout.SecondaryPath.CreateProfileWithKeycardNewSeedphrase

            if (root.startupStore.getPin())
                stack.push(keycardEnterPinPage)
            else
                stack.push(keycardCreatePinPage)
        }
        function onCreateKeycardProfileWithExistingSeedphrase() {
            console.warn("!!! CREATE KEYCARD PROFILE WITH EXISTING SEEDPHRASE")
            d.secondaryPath = OnboardingLayout.SecondaryPath.CreateProfileWithKeycardExistingSeedphrase
            stack.push(seedphrasePage, { title: qsTr("Create profile on empty Keycard using a recovery phrase"), subtitle: qsTr("Enter your 12, 18 or 24 word recovery phrase")})
        }

        function onKeycardPinCreated(pin) {
            console.warn("!!! KEYCARD PIN CREATED:", pin)
            d.keycardPin = pin
            // TODO set the PIN immediately?
            Backpressure.debounce(root, 2000, function() {
                stack.clear()
                d.pushOrSkipBiometricsPage(qsTr("Would you like to enable biometrics to fill in your password? You will use biometrics for signing in to Status and for signing transactions."))
            })()
        }

        function onKeycardPinEntered(pin) {
            console.warn("!!! KEYCARD PIN ENTERED:", pin)
            d.keycardPin = pin
            // TODO set the PIN immediately?
            stack.clear()
            d.pushOrSkipBiometricsPage(qsTr("Would you like to enable biometrics to fill in your password? You will use biometrics for signing in to Status and for signing transactions."))
        }

        // backup seedphrase pages
        function onBackupSeedphraseRequested() {
            console.warn("!!! BACKUP SEED REQUESTED")
            stack.push(backupSeedAcksPage)
        }

        function onBackupSeedphraseContinue() {
            console.warn("!!! BACKUP SEED CONTINUE")
            stack.push(backupSeedRevealPage)
        }

        function onBackupSeedphraseConfirmed() {
            console.warn("!!! BACKUP SEED CONFIRMED")
            root.privacyStore.mnemonicWasShown()
            stack.push(backupSeedVerifyPage)
        }

        function onBackupSeedphraseVerified() {
            console.warn("!!! BACKUP SEED VERIFIED")
            stack.push(backupSeedOutroPage)
        }

        function onBackupSeedphraseRemovalConfirmed() {
            console.warn("!!! BACKUP SEED REMOVAL CONFIRMED")
            root.privacyStore.removeMnemonic()
            stack.replace(splashScreen, { runningProgressAnimation: true })
        }

        // login with sync pages
        function onSyncProceedWithConnectionString(connectionString) {
            console.warn("!!! SYNC PROCEED WITH CONNECTION STRING:", connectionString)
            d.syncConnectionString = connectionString
            root.startupStore.setConnectionString(connectionString)
            // TODO backend: start the sync
            Backpressure.debounce(root, 1000, function() {
                stack.clear()
                stack.replace(syncProgressPage)
            })()
        }

        function onRestartSyncRequested() {
            console.warn("!!! RESTART SYNC REQUESTED")
            // TODO backend: start the sync
            stack.clear()
            stack.replace(syncProgressPage)
        }

        function onLoginToAppRequested() {
            console.warn("!!! LOGIN TO APP REQUESTED")
            stack.replace(splashScreen, { runningProgressAnimation: true })
        }

        // enable biometrics page
        function onEnableBiometricsRequested(enabled: bool) {
            console.warn("!!! ENABLE BIOMETRICS:", enabled)
            d.enableBiometrics = enabled
            if (d.secondaryPath === OnboardingLayout.SecondaryPath.CreateProfileWithKeycardNewSeedphrase)
                stack.push(backupSeedIntroPage)
            else
                stack.replace(splashScreen, { runningProgressAnimation: true })
        }
    }

    // pages
    Component {
        id: welcomePage
        WelcomePage {
            StackView.onActivated: d.resetState()
        }
    }

    Component {
        id: helpUsImproveStatusPage
        HelpUsImproveStatusPage {}
    }

    Component {
        id: createProfilePage
        CreateProfilePage {
            StackView.onActivated: d.secondaryPath = OnboardingLayout.SecondaryPath.Unknown // reset when we get back here
        }
    }

    Component {
        id: createPasswordPage
        CreatePasswordPage {
            passwordStrengthScoreFunction: root.startupStore.getPasswordStrengthScore
        }
    }

    Component {
        id: enableBiometricsPage
        EnableBiometricsPage {}
    }

    Component {
        id: splashScreen
        DidYouKnowSplashScreen {
            readonly property string pageClassName: "Splash"
            property bool runningProgressAnimation
            NumberAnimation on progress {
                from: 0.0
                to: 1
                duration: root.splashScreenDurationMs
                running: runningProgressAnimation
                onStopped: root.finished(d.primaryPath, d.secondaryPath,
                                         {"password": d.password, "keycardPin": d.keycardPin, "enableBiometrics": d.enableBiometrics, "syncConnectionString": d.syncConnectionString})
            }
        }
    }

    Component {
        id: seedphrasePage
        SeedphrasePage {
            isSeedPhraseValid: root.startupStore.validMnemonic
        }
    }

    Component {
        id: createKeycardProfilePage
        CreateKeycardProfilePage {
            StackView.onActivated: {
                d.primaryPath = OnboardingLayout.PrimaryPath.CreateProfile
                d.secondaryPath = OnboardingLayout.SecondaryPath.CreateProfileWithKeycard
            }
        }
    }

    Component {
        id: keycardIntroPage
        KeycardIntroPage {
            keycardState: d.currentKeycardState
            displayPromoBanner: !d.settings.keycardPromoShown
            StackView.onActivated: {
                // NB just to make sure we don't miss the signal when we (re)load the page in the final state already
                if (keycardState === Constants.startupState.keycardEmpty)
                    emptyKeycardDetected()
                else if (keycardState === Constants.startupState.keycardNotEmpty)
                    notEmptyKeycardDetected()
            }
        }
    }

    Component {
        id: keycardEmptyPage
        KeycardEmptyPage {}
    }

    Component {
        id: keycardNotEmptyPage
        KeycardNotEmptyPage {}
    }

    Component {
        id: keycardCreatePinPage
        KeycardCreatePinPage {}
    }

    Component {
        id: keycardEnterPinPage
        KeycardEnterPinPage {
            existingPin: root.startupStore.getPin()
            remainingAttempts: root.startupStore.startupModuleInst.remainingAttempts
        }
    }

    Component {
        id: backupSeedIntroPage
        BackupSeedphraseIntro {}
    }

    Component {
        id: backupSeedAcksPage
        BackupSeedphraseAcks {}
    }

    Component {
        id: backupSeedRevealPage
        BackupSeedphraseReveal {
            seedWords: d.seedWords
        }
    }

    Component {
        id: backupSeedVerifyPage
        BackupSeedphraseVerify {
            seedWordsToVerify: {
                let result = []
                const randomIndexes = SQUtils.Utils.nSamples(d.numWordsToVerify, d.seedWords.length)
                return randomIndexes.map(i => ({ seedWordNumber: i+1, seedWord: d.seedWords[i] }))
            }
        }
    }

    Component {
        id: backupSeedOutroPage
        BackupSeedphraseOutro {}
    }

    Component {
        id: loginPage
        LoginPage {
            StackView.onActivated: d.secondaryPath = OnboardingLayout.SecondaryPath.Unknown // reset when we get back here
        }
    }

    Component {
        id: loginBySyncPage
        LoginBySyncingPage {
            validateConnectionString: root.startupStore.validateLocalPairingConnectionString
        }
    }

    Component {
        id: syncProgressPage
        SyncProgressPage {
            syncState: SyncProgressPage.SyncState.InProgress // TODO integrate backend
            timeoutInterval: root.splashScreenDurationMs
        }
    }

    // common popups
    Component {
        id: privacyPolicyPopup
        StatusSimpleTextPopup {
            title: qsTr("Status Software Privacy Policy")
            content {
                textFormat: Text.MarkdownText
                text: SQUtils.StringUtils.readTextFile(Qt.resolvedUrl("../../../imports/assets/docs/privacy.mdwn"))
            }
            destroyOnClose: true
        }
    }

    Component {
        id: termsOfUsePopup
        StatusSimpleTextPopup {
            title: qsTr("Status Software Terms of Use")
            content {
                textFormat: Text.MarkdownText
                text: SQUtils.StringUtils.readTextFile(Qt.resolvedUrl("../../../imports/assets/docs/terms-of-use.mdwn"))
            }
            destroyOnClose: true
        }
    }
}
