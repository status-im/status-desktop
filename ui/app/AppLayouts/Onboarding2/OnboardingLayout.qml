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
import shared.stores 1.0 as SharedStores

import utils 1.0

// compat
import AppLayouts.Onboarding.stores 1.0 as OOBS

Page {
    id: root

    // FIXME refactor to a hasPin() (instead of getPin())
    // TODO backend: replace with a new OnboardingStore, with just the needed props/functions?
    required property OOBS.StartupStore startupStore

    // TODO backend: externalize the metrics handling too?
    required property SharedStores.MetricsStore metricsStore

    required property ProfileStores.PrivacyStore privacyStore

    property int splashScreenDurationMs: 30000
    property bool biometricsAvailable: Qt.platform.os === Constants.mac

    readonly property alias stack: stack
    readonly property alias primaryFlow: d.primaryFlow // OnboardingLayout.PrimaryFlow enum
    readonly property alias secondaryFlow: d.secondaryFlow // OnboardingLayout.SecondaryFlow enum

    signal finished(int primaryFlow, int secondaryFlow, var data)
    signal keycardFactoryResetRequested() // TODO integrate/switch to an external flow, needed?
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
        property int primaryFlow: OnboardingLayout.PrimaryFlow.Unknown
        property int secondaryFlow: OnboardingLayout.SecondaryFlow.Unknown
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
        // TODO collect seedphrase too?

        function resetState() {
            d.primaryFlow = OnboardingLayout.PrimaryFlow.Unknown
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.Unknown
            d.password = ""
            d.keycardPin = ""
            d.enableBiometrics = false
        }

        readonly property Settings settings: Settings {
            property bool keycardPromoShown // whether we've seen the keycard promo banner on KeycardIntroPage

            function reset() {
                keycardPromoShown = false
            }
        }

        function pushOrSkipBiometricsPage() {
            if (root.biometricsAvailable) {
                dbg.debugFlow("ENTERING BIOMETRICS PAGE")
                stack.push(enableBiometricsPage)
            } else {
                dbg.debugFlow("SKIPPING BIOMETRICS PAGE")
                d.finishFlow()
            }
        }

        function finishFlow() {
            dbg.debugFlow(`ONBOARDING FINISHED; ${d.primaryFlow} -> ${d.secondaryFlow}`)
            root.finished(d.primaryFlow, d.secondaryFlow, // TODO collect seedphrase?
                          {"password": d.password, "keycardPin": d.keycardPin, "enableBiometrics": d.enableBiometrics})
        }
    }

    enum PrimaryFlow {
        Unknown,
        CreateProfile,
        Login
    }

    enum SecondaryFlow {
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

    LoggingCategory {
        id: dbg
        name: "app.status.onboarding"

        function debugFlow(message) {
            const currentPageName = stack.currentItem ? stack.currentItem.pageClassName : "<empty stack>"
            console.info(dbg, "!!!", currentPageName, "->", message)
        }
    }

    // page stack
    StackView {
        id: stack
        objectName: "stack"
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
            dbg.debugFlow("AUX: PRIVACY POLICY")
            privacyPolicyPopup.createObject(root).open()
        }
        function onTermsOfUseRequested() {
            dbg.debugFlow("AUX: TERMS OF USE")
            termsOfUsePopup.createObject(root).open()
        }
        function onOpenLink(link: string) {
            dbg.debugFlow(`OPEN LINK: ${link}`)
            Global.openLink(link)
        }
        function onOpenLinkWithConfirmation(link: string, domain: string) {
            dbg.debugFlow(`OPEN LINK WITH CONFIRM: ${link}`)
            Global.openLinkWithConfirmation(link, domain)
        }

        // welcome page
        function onCreateProfileRequested() {
            dbg.debugFlow("PRIMARY: CREATE PROFILE")
            d.primaryFlow = OnboardingLayout.PrimaryFlow.CreateProfile
            stack.push(helpUsImproveStatusPage)
        }
        function onLoginRequested() {
            dbg.debugFlow("PRIMARY: LOG IN")
            d.primaryFlow = OnboardingLayout.PrimaryFlow.Login
            stack.push(helpUsImproveStatusPage)
        }

        // help us improve page
        function onShareUsageDataRequested(enabled: bool) {
            dbg.debugFlow(`SHARE USAGE DATA: ${enabled}`)
            metricsStore.toggleCentralizedMetrics(enabled)
            Global.addCentralizedMetricIfEnabled("usage_data_shared", {placement: Constants.metricsEnablePlacement.onboarding})
            localAppSettings.metricsPopupSeen = true

            if (d.primaryFlow === OnboardingLayout.PrimaryFlow.CreateProfile)
                stack.push(createProfilePage)
            else if (d.primaryFlow === OnboardingLayout.PrimaryFlow.Login)
                stack.push(loginPage)
        }

        // create profile page
        function onCreateProfileWithPasswordRequested() {
            dbg.debugFlow("SECONDARY: CREATE PROFILE WITH PASSWORD")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.CreateProfileWithPassword
            stack.push(createPasswordPage)
        }
        function onCreateProfileWithSeedphraseRequested() {
            dbg.debugFlow("SECONDARY: CREATE PROFILE WITH SEEDPHRASE")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.CreateProfileWithSeedphrase
            stack.push(seedphrasePage, { title: qsTr("Create profile using a recovery phrase")})
        }
        function onCreateProfileWithEmptyKeycardRequested() {
            dbg.debugFlow("SECONDARY: CREATE PROFILE WITH KEYCARD")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.CreateProfileWithKeycard
            stack.push(keycardIntroPage)
        }

        // login page
        function onLoginWithSeedphraseRequested() {
            dbg.debugFlow("SECONDARY: LOGIN WITH SEEDPHRASE")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.LoginWithSeedphrase
            stack.push(seedphrasePage, { title: qsTr("Log in with your Status recovery phrase")})
        }
        function onLoginWithSyncingRequested() {
            dbg.debugFlow("SECONDARY: LOGIN WITH SYNCING")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.LoginWithSyncing
            stack.push(loginBySyncPage)
        }
        function onLoginWithKeycardRequested() {
            dbg.debugFlow("SECONDARY: LOGIN WITH KEYCARD")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.LoginWithKeycard
            stack.push(keycardIntroPage)
        }

        // create password page
        function onSetPasswordRequested(password: string) {
            dbg.debugFlow("SET PASSWORD REQUESTED")
            d.password = password
            // TODO backend: set the password immediately?
            stack.clear()
            d.pushOrSkipBiometricsPage()
        }

        // seedphrase page
        function onSeedphraseValidated() {
            dbg.debugFlow("SEEDPHRASE VALIDATED")
            if (d.secondaryFlow === OnboardingLayout.SecondaryFlow.CreateProfileWithSeedphrase || d.secondaryFlow === OnboardingLayout.SecondaryFlow.LoginWithSeedphrase) {
                dbg.debugFlow("AFTER SEEDPHRASE -> PASSWORD PAGE")
                stack.push(createPasswordPage)
            } else if (d.secondaryFlow === OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase) {
                dbg.debugFlow("AFTER SEEDPHRASE -> KEYCARD PIN PAGE")
                if (root.startupStore.getPin() !== "")
                    stack.push(keycardEnterPinPage)
                else
                    stack.push(keycardCreatePinPage)
            }
        }

        // keycard pages
        function onReloadKeycardRequested() {
            dbg.debugFlow("RELOAD KEYCARD REQUESTED")
            root.keycardReloaded()
            stack.replace(keycardIntroPage)
        }
        function onKeycardFactoryResetRequested() {
            dbg.debugFlow("KEYCARD FACTORY RESET REQUESTED")
            // TODO start keycard factory reset in a popup here
            // cf. KeycardStore.runFactoryResetPopup()
            root.keycardFactoryResetRequested()
        }
        function onLoginWithThisKeycardRequested() {
            dbg.debugFlow("LOGIN WITH THIS KEYCARD REQUESTED")
            d.primaryFlow = OnboardingLayout.PrimaryFlow.Login
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.LoginWithKeycard
            if (root.startupStore.getPin() !== "")
                stack.push(keycardEnterPinPage)
            else
                stack.push(keycardCreatePinPage)
        }
        function onEmptyKeycardDetected() {
            dbg.debugFlow("EMPTY KEYCARD DETECTED")
            if (d.secondaryFlow === OnboardingLayout.SecondaryFlow.LoginWithKeycard)
                stack.replace(keycardEmptyPage) // NB: replacing the loginPage
            else
                stack.replace(createKeycardProfilePage) // NB: replacing the keycardIntroPage
        }
        function onNotEmptyKeycardDetected() {
            dbg.debugFlow("NOT EMPTY KEYCARD DETECTED")
            if (d.secondaryFlow === OnboardingLayout.SecondaryFlow.LoginWithKeycard)
                stack.replace(keycardEnterPinPage)
            else
                stack.replace(keycardNotEmptyPage)
        }

        function onCreateKeycardProfileWithNewSeedphrase() {
            dbg.debugFlow("CREATE KEYCARD PROFILE WITH NEW SEEDPHRASE")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardNewSeedphrase
            stack.push(backupSeedIntroPage)
        }
        function onCreateKeycardProfileWithExistingSeedphrase() {
            dbg.debugFlow("CREATE KEYCARD PROFILE WITH EXISTING SEEDPHRASE")
            d.secondaryFlow = OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase
            stack.push(seedphrasePage, { title: qsTr("Create profile on empty Keycard using a recovery phrase")})
        }

        function onKeycardPinCreated(pin) {
            dbg.debugFlow(`KEYCARD PIN CREATED: ${pin}`)
            d.keycardPin = pin
            // TODO backend: set the PIN immediately?

            if (d.secondaryFlow === OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardNewSeedphrase ||
                    d.secondaryFlow === OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase) {
                dbg.debugFlow("ENTERING KEYPAIR TRANSFER PAGE")
                stack.clear()
                // TODO backend: transfer the keypair
                stack.push(addKeypairPage)
            } else {
                Backpressure.debounce(root, 2000, function() {
                    stack.clear()
                    d.pushOrSkipBiometricsPage()
                })()
            }
        }

        function onKeycardPinEntered(pin) {
            dbg.debugFlow(`KEYCARD PIN ENTERED: ${pin}`)
            d.keycardPin = pin
            // TODO backend: set the PIN immediately?

            if (d.secondaryFlow === OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardNewSeedphrase ||
                    d.secondaryFlow === OnboardingLayout.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase) {
                dbg.debugFlow("ENTERING KEYPAIR TRANSFER PAGE")
                stack.clear()
                // TODO backend: transfer the keypair
                stack.push(addKeypairPage)
            } else {
                stack.clear()
                d.pushOrSkipBiometricsPage()
            }
        }

        // backup seedphrase pages
        function onBackupSeedphraseRequested() {
            dbg.debugFlow("BACKUP SEED REQUESTED")
            stack.push(backupSeedAcksPage)
        }

        function onBackupSeedphraseContinue() {
            dbg.debugFlow("BACKUP SEED CONTINUE")
            stack.push(backupSeedRevealPage)
        }

        function onBackupSeedphraseConfirmed() {
            dbg.debugFlow("BACKUP SEED CONFIRMED")
            root.privacyStore.mnemonicWasShown()
            stack.push(backupSeedVerifyPage)
        }

        function onBackupSeedphraseVerified() {
            dbg.debugFlow("BACKUP SEED VERIFIED")
            stack.push(backupSeedOutroPage)
        }

        function onBackupSeedphraseRemovalConfirmed() {
            dbg.debugFlow("BACKUP SEED REMOVAL CONFIRMED")
            root.privacyStore.removeMnemonic()

            if (root.startupStore.getPin())
                stack.replace(keycardEnterPinPage)
            else
                stack.replace(keycardCreatePinPage)
        }

        // login with sync pages
        function onSyncProceedWithConnectionString(connectionString) {
            dbg.debugFlow(`SYNC PROCEED WITH CONNECTION STRING: ${connectionString}`)
            root.startupStore.setConnectionString(connectionString)
            // TODO backend: start the sync
            stack.clear()
            stack.replace(syncProgressPage)
        }

        function onRestartSyncRequested() {
            dbg.debugFlow("RESTART SYNC REQUESTED")
            // TODO backend: restart the sync
            stack.clear()
            stack.replace(syncProgressPage)
        }

        function onLoginToAppRequested() {
            dbg.debugFlow("LOGIN TO APP REQUESTED")
            stack.clear()
            d.pushOrSkipBiometricsPage()
        }

        // keypair transfer page
        function onKeypairAddContinueRequested() {
            dbg.debugFlow("KEYPAIR TRANSFER COMPLETED")
            stack.clear()
            d.pushOrSkipBiometricsPage()
        }
        function onKeypairAddTryAgainRequested() {
            dbg.debugFlow("RESTART KEYPAIR TRANSFER REQUESTED")
            // TODO backend: restart the transfer
            stack.clear()
            stack.push(addKeypairPage)
        }
        function onCreateProfilePageRequested() {
            dbg.debugFlow("KEYPAIR TRANSFER -> CREATE PROFILE")
            stack.replace([welcomePage, createProfilePage])
        }

        // enable biometrics page
        function onEnableBiometricsRequested(enabled: bool) {
            dbg.debugFlow(`ENABLE BIOMETRICS: ${enabled}`)
            d.enableBiometrics = enabled
            d.finishFlow()
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
            StackView.onActivated: {
                // reset when we get back here
                d.primaryFlow = OnboardingLayout.PrimaryFlow.CreateProfile
                d.secondaryFlow = OnboardingLayout.SecondaryFlow.Unknown
            }
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
        id: seedphrasePage
        SeedphrasePage {
            isSeedPhraseValid: root.startupStore.validMnemonic
        }
    }

    Component {
        id: createKeycardProfilePage
        CreateKeycardProfilePage {
            StackView.onActivated: {
                d.primaryFlow = OnboardingLayout.PrimaryFlow.CreateProfile
                d.secondaryFlow = OnboardingLayout.SecondaryFlow.CreateProfileWithKeycard
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
            remainingAttempts: root.startupStore.startupModuleInst.remainingAttempts // TODO backend: integrate
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
            StackView.onActivated: {
                // reset when we get back here
                d.primaryFlow = OnboardingLayout.PrimaryFlow.Login
                d.secondaryFlow = OnboardingLayout.SecondaryFlow.Unknown
            }
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
            syncState: SyncProgressPage.SyncState.InProgress // TODO backend: integrate
            timeoutInterval: root.splashScreenDurationMs
        }
    }

    Component {
        id: addKeypairPage
        KeycardAddKeyPairPage {
            addKeyPairState: KeycardAddKeyPairPage.AddKeyPairState.InProgress // TODO backend: integrate
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
