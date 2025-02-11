import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property var loginAccountsModel

    required property int keycardState
    required property int pinSettingState
    required property int authorizationState
    required property int restoreKeysExportState
    required property int addKeyPairState
    required property int syncState
    required property var generateMnemonic
    required property int remainingPinAttempts
    required property int remainingPukAttempts

    required property bool isBiometricsLogin // FIXME should come from the loginAccountsModel for each profile separately?

    required property bool biometricsAvailable
    required property bool displayKeycardPromoBanner
    required property bool networkChecksEnabled

    property int keycardPinInfoPageDelay: 2000

    // functions
    required property var passwordStrengthScoreFunction
    required property var isSeedPhraseValid
    required property var validateConnectionString
    required property var tryToSetPukFunction

    signal biometricsRequested(string profileId)
    signal dismissBiometricsRequested
    signal loginRequested(string keyUid, int method, var data)
    signal keycardPinCreated(string pin)
    signal enableBiometricsRequested(bool enable)
    signal shareUsageDataRequested(bool enabled)
    signal syncProceedWithConnectionString(string connectionString)
    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal exportKeysRequested
    signal loadMnemonicRequested
    signal authorizationRequested(string pin)

    signal performKeycardFactoryResetRequested

    signal linkActivated(string link)

    signal finished(int flow)

    function init() {
        root.stackView.push(entryPage)
    }

    function setBiometricResponse(secret: string, error = "",
                                  detailedError = "",
                                  wrongFingerprint = false) {
        if (!loginScreen)
            return

        loginScreen.setBiometricResponse(secret, error, detailedError,
                                         wrongFingerprint)
    }

    readonly property LoginScreen loginScreen: d.loginScreen

    QtObject {
        id: d

        property int flow
        property LoginScreen loginScreen: null

        property bool seenUsageDataPrompt

        function pushOrSkipBiometricsPage() {
            if (root.biometricsAvailable) {
                root.stackView.replace(null, enableBiometricsPage)
            } else {
                root.finished(d.flow)
            }
        }

        function openPrivacyPolicyPopup() {
            privacyPolicyPopup.createObject(root.stackView).open()
        }

        function openTermsOfUsePopup() {
            termsOfUsePopup.createObject(root.stackView).open()
        }
    }

    Component {
        id: entryPage

        Loader {
            sourceComponent: loginAccountsModel.ModelCount.empty ? welcomePage
                                                                 : loginScreenComponent
        }
    }

    Component {
        id: welcomePage

        WelcomePage {
            function pushWithProxy(component) {
                if (d.seenUsageDataPrompt) { // don't ask for "Share usage data" a second time (e.g. after a factory reset)
                    root.stackView.push(component)
                } else {
                    const page = root.stackView.push(helpUsImproveStatusPage)

                    page.shareUsageDataRequested.connect(enabled => {
                        root.shareUsageDataRequested(enabled)
                        root.stackView.push(component)
                        d.seenUsageDataPrompt = true
                    })
                }
            }

            onCreateProfileRequested: pushWithProxy(createProfilePage)
            onLoginRequested: pushWithProxy(loginPage)

            onPrivacyPolicyRequested: d.openPrivacyPolicyPopup()
            onTermsOfUseRequested: d.openTermsOfUsePopup()
        }
    }

    Component {
        id: loginScreenComponent

        LoginScreen {
            id: loginScreen

            keycardState: root.keycardState
            keycardRemainingPinAttempts: root.remainingPinAttempts
            keycardRemainingPukAttempts: root.remainingPukAttempts

            loginAccountsModel: root.loginAccountsModel
            biometricsAvailable: root.biometricsAvailable
            isBiometricsLogin: root.isBiometricsLogin

            onBiometricsRequested: (profileId) => root.biometricsRequested(profileId)
            onDismissBiometricsRequested: root.dismissBiometricsRequested()
            onLoginRequested: (keyUid, method, data) => root.loginRequested(keyUid, method, data)
            onOnboardingCreateProfileFlowRequested: root.stackView.push(createProfilePage)
            onOnboardingLoginFlowRequested: root.stackView.push(loginPage)
            onLostKeycard: root.stackView.push(keycardLostPage)
            onUnblockWithSeedphraseRequested: unblockWithSeedphraseFlow.init()
            onUnblockWithPukRequested: unblockWithPukFlow.init()

            onVisibleChanged: {
                if (!visible)
                    root.dismissBiometricsRequested()
            }

            Component.onDestruction: root.dismissBiometricsRequested()

            Binding {
                target: d
                restoreMode: Binding.RestoreValue
                property: "loginScreen"
                value: loginScreen
            }
        }
    }

    Component {
        id: helpUsImproveStatusPage

        HelpUsImproveStatusPage {
            onPrivacyPolicyRequested: d.openPrivacyPolicyPopup()
        }
    }

    Component {
        id: createProfilePage

        CreateProfilePage {
            onCreateProfileWithPasswordRequested: createNewProfileFlow.init()
            onCreateProfileWithSeedphraseRequested: {
                d.flow = Onboarding.OnboardingFlow.CreateProfileWithSeedphrase
                useRecoveryPhraseFlow.init(UseRecoveryPhraseFlow.Type.NewProfile)
            }
            onCreateProfileWithEmptyKeycardRequested: keycardCreateProfileFlow.init()
        }
    }

    Component {
        id: loginPage

        NewAccountLoginPage {
            networkChecksEnabled: root.networkChecksEnabled

            onLoginWithSyncingRequested: logInBySyncingFlow.init()
            onLoginWithKeycardRequested: loginWithKeycardFlow.init()

            onLoginWithSeedphraseRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithSeedphrase
                useRecoveryPhraseFlow.init(UseRecoveryPhraseFlow.Type.Login)
            }
        }
    }

    Component {
        id: keycardLostPage

        KeycardLostPage {
            onCreateReplacementKeycardRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithRestoredKeycard
                keycardCreateReplacementFlow.init()
            }

            onUseProfileWithoutKeycardRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithLostKeycardSeedphrase
                useRecoveryPhraseFlow.init(UseRecoveryPhraseFlow.Type.KeycardRecovery)
            }
        }
    }

    CreateNewProfileFlow {
        id: createNewProfileFlow

        stackView: root.stackView
        passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

        onFinished: (password) => {
            root.setPasswordRequested(password)
            d.flow = Onboarding.OnboardingFlow.CreateProfileWithPassword
            d.pushOrSkipBiometricsPage()
        }
    }

    UseRecoveryPhraseFlow {
        id: useRecoveryPhraseFlow

        stackView: root.stackView
        isSeedPhraseValid: root.isSeedPhraseValid
        passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)
        onSetPasswordRequested: (password) => root.setPasswordRequested(password)
        onFinished: d.pushOrSkipBiometricsPage()
    }

    KeycardCreateProfileFlow {
        id: keycardCreateProfileFlow

        stackView: root.stackView
        keycardState: root.keycardState
        pinSettingState: root.pinSettingState
        authorizationState: root.authorizationState
        addKeyPairState: root.addKeyPairState
        generateMnemonic: root.generateMnemonic
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onKeycardFactoryResetRequested: keycardFactoryResetFlow.init()
        onLoadMnemonicRequested: root.loadMnemonicRequested()
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onLoginWithKeycardRequested: loginWithKeycardFlow.init()
        onAuthorizationRequested: root.authorizationRequested("") // Pin was saved locally already
        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

        onFinished: (withNewSeedphrase) => {
            d.flow = withNewSeedphrase
                        ? Onboarding.OnboardingFlow.CreateProfileWithKeycardNewSeedphrase
                        : Onboarding.OnboardingFlow.CreateProfileWithKeycardExistingSeedphrase

            d.pushOrSkipBiometricsPage()
        }
    }

    LoginBySyncingFlow {
        id: logInBySyncingFlow

        stackView: root.stackView
        validateConnectionString: root.validateConnectionString
        syncState: root.syncState

        onSyncProceedWithConnectionString: (connectionString) =>
                                           root.syncProceedWithConnectionString(connectionString)

        onLoginWithSeedphraseRequested: {
            d.flow = Onboarding.OnboardingFlow.LoginWithSeedphrase
            useRecoveryPhraseFlow.init(UseRecoveryPhraseFlow.Type.Login)
        }

        onFinished: {
            d.flow = Onboarding.OnboardingFlow.LoginWithSyncing
            d.pushOrSkipBiometricsPage()
        }
    }

    LoginWithKeycardFlow {
        id: loginWithKeycardFlow

        stackView: root.stackView
        keycardState: root.keycardState
        authorizationState: root.authorizationState
        restoreKeysExportState: root.restoreKeysExportState
        remainingPinAttempts: root.remainingPinAttempts
        remainingPukAttempts: root.remainingPukAttempts
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        onAuthorizationRequested: root.authorizationRequested(pin)

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onCreateProfileWithEmptyKeycardRequested: keycardCreateProfileFlow.init()
        onExportKeysRequested: root.exportKeysRequested()
        onKeycardFactoryResetRequested: keycardFactoryResetFlow.init()
        onUnblockWithSeedphraseRequested: unblockWithSeedphraseFlow.init()
        onUnblockWithPukRequested: unblockWithPukFlow.init()

        onFinished: {
            d.flow = Onboarding.OnboardingFlow.LoginWithKeycard
            d.pushOrSkipBiometricsPage()
        }
    }

    UnblockWithSeedphraseFlow {
        id: unblockWithSeedphraseFlow

        stackView: root.stackView

        isSeedPhraseValid: root.isSeedPhraseValid
        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)
        onKeycardPinCreated: (pin) => {
            root.keycardPinCreated(pin)

            if (root.loginScreen) {
                root.loginRequested(root.loginScreen.selectedProfileKeyId,
                                    Onboarding.LoginMethod.Keycard, { pin })
            } else {
                d.flow = Onboarding.SecondaryFlow.LoginWithKeycard
                d.pushOrSkipBiometricsPage()
            }
        }
    }

    UnblockWithPukFlow {
        id: unblockWithPukFlow

        property string pin

        stackView: root.stackView
        keycardState: root.keycardState
        tryToSetPukFunction: root.tryToSetPukFunction
        remainingAttempts: root.remainingPukAttempts

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onKeycardPinCreated: (pin) => {
            unblockWithPukFlow.pin = pin
            root.keycardPinCreated(pin)
        }
        onKeycardFactoryResetRequested: keycardFactoryResetFlow.init()

        onFinished: (success) => {
            if (!success)
               return
            if (root.loginScreen) {
                root.loginRequested(root.loginScreen.selectedProfileKeyId,
                                    Onboarding.LoginMethod.Keycard, { pin })
            } else {
                d.flow = Onboarding.OnboardingFlow.LoginWithKeycard
                d.pushOrSkipBiometricsPage()
            }
        }
    }

    KeycardCreateReplacementFlow {
        id: keycardCreateReplacementFlow

        stackView: root.stackView

        keycardState: root.keycardState
        pinSettingState: root.pinSettingState
        authorizationState: root.authorizationState
        addKeyPairState: root.addKeyPairState

        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onKeycardFactoryResetRequested: keycardFactoryResetFlow.init(true)
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onLoginWithKeycardRequested: loginWithKeycardFlow.init()
        onAuthorizationRequested: root.authorizationRequested("") // Pin was saved locally already
        onLoadMnemonicRequested: root.loadMnemonicRequested()

        onCreateProfileWithoutKeycardRequested: {
            const page = stackView.find(
                           item => item instanceof HelpUsImproveStatusPage)

            stackView.replace(page, createProfilePage, StackView.PopTransition)
        }

        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

        onFinished: d.pushOrSkipBiometricsPage()
    }

    KeycardFactoryResetFlow {
        id: keycardFactoryResetFlow
        stackView: root.stackView
        keycardState: root.keycardState
        onPerformKeycardFactoryResetRequested: root.performKeycardFactoryResetRequested()
        onFinished: {
            stackView.clear()
            root.init()
        }
    }

    Component {
        id: enableBiometricsPage

        EnableBiometricsPage {
            onEnableBiometricsRequested: (enable) => {
                root.enableBiometricsRequested(enable)
                root.finished(d.flow)
            }
        }
    }

    // popups
    Component {
        id: privacyPolicyPopup

        StatusSimpleTextPopup {
            title: qsTr("Status Software Privacy Policy")
            content {
                textFormat: Text.MarkdownText
            }
            okButtonText: qsTr("Done")
            destroyOnClose: true
            onOpened: content.text = SQUtils.StringUtils.readTextFile(Qt.resolvedUrl("../../../imports/assets/docs/privacy.mdwn"))
            onLinkActivated: (link) => root.linkActivated(link)
        }
    }

    Component {
        id: termsOfUsePopup

        StatusSimpleTextPopup {
            title: qsTr("Status Software Terms of Use")
            content {
                textFormat: Text.MarkdownText
            }
            okButtonText: qsTr("Done")
            destroyOnClose: true
            onOpened: content.text = SQUtils.StringUtils.readTextFile(Qt.resolvedUrl("../../../imports/assets/docs/terms-of-use.mdwn"))
            onLinkActivated: (link) => root.linkActivated(link)
        }
    }
}
