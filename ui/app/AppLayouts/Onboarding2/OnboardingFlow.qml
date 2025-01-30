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
    required property int addKeyPairState
    required property int syncState
    required property var seedWords
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
    required property var tryToSetPinFunction
    required property var tryToSetPukFunction

    signal biometricsRequested
    signal loginRequested(string keyUid, int method, var data)
    signal keycardPinCreated(string pin)
    signal keycardPinEntered(string pin)
    signal enableBiometricsRequested(bool enable)
    signal shareUsageDataRequested(bool enabled)
    signal syncProceedWithConnectionString(string connectionString)
    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal reloadKeycardRequested
    signal keycardFactoryResetRequested
    signal keyPairTransferRequested

    signal mnemonicWasShown()
    signal mnemonicRemovalRequested()

    signal linkActivated(string link)

    signal finished(int flow)

    function init() {
        root.stackView.push(entryPage)
    }

    readonly property LoginScreen loginScreen: d.loginScreen

    QtObject {
        id: d

        property int flow
        property LoginScreen loginScreen: null

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
                const page = root.stackView.push(helpUsImproveStatusPage)

                page.shareUsageDataRequested.connect(enabled => {
                    root.shareUsageDataRequested(enabled)
                    root.stackView.push(component)
                })
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
            tryToSetPinFunction: root.tryToSetPinFunction

            keycardRemainingPinAttempts: root.remainingPinAttempts
            keycardRemainingPukAttempts: root.remainingPukAttempts

            loginAccountsModel: root.loginAccountsModel
            biometricsAvailable: root.biometricsAvailable
            isBiometricsLogin: root.isBiometricsLogin
            onBiometricsRequested: root.biometricsRequested()
            onLoginRequested: (keyUid, method, data) => root.loginRequested(keyUid, method, data)

            onOnboardingCreateProfileFlowRequested: root.stackView.push(createProfilePage)
            onOnboardingLoginFlowRequested: root.stackView.push(loginPage)
            onLostKeycard: root.stackView.push(keycardLostPage)
            onUnblockWithSeedphraseRequested: unblockWithSeedphraseFlow.init()
            onUnblockWithPukRequested: unblockWithPukFlow.init()
            onKeycardFactoryResetRequested: console.warn("!!! FIXME OnboardingLayout::onKeycardFactoryResetRequested")

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
                d.flow = Onboarding.SecondaryFlow.CreateProfileWithSeedphrase
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
                d.flow = Onboarding.SecondaryFlow.LoginWithSeedphrase
                useRecoveryPhraseFlow.init(UseRecoveryPhraseFlow.Type.Login)
            }
        }
    }

    Component {
        id: keycardLostPage

        KeycardLostPage {
            onCreateReplacementKeycardRequested: {
                d.flow = Onboarding.SecondaryFlow.LoginWithRestoredKeycard
                keycardCreateReplacementFlow.init()
            }

            onUseProfileWithoutKeycardRequested: {
                d.flow = Onboarding.SecondaryFlow.LoginWithLostKeycardSeedphrase
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
            d.flow = Onboarding.SecondaryFlow.CreateProfileWithPassword
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
        addKeyPairState: root.addKeyPairState
        seedWords: root.seedWords
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onReloadKeycardRequested: root.reloadKeycardRequested()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        onKeyPairTransferRequested: root.keyPairTransferRequested()
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onLoginWithKeycardRequested: loginWithKeycardFlow.init()
        onKeypairAddTryAgainRequested: root.keyPairTransferRequested() // FIXME?

        onCreateProfileWithoutKeycardRequested: {
            const page = stackView.find(
                           item => item instanceof HelpUsImproveStatusPage)

            stackView.replace(page, createProfilePage, StackView.PopTransition)
        }

        onMnemonicWasShown: root.mnemonicWasShown()
        onMnemonicRemovalRequested: root.mnemonicRemovalRequested()

        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

        onFinished: (withNewSeedphrase) => {
            d.flow = withNewSeedphrase
                        ? Onboarding.SecondaryFlow.CreateProfileWithKeycardNewSeedphrase
                        : Onboarding.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase

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
            d.flow = Onboarding.SecondaryFlow.LoginWithSeedphrase
            useRecoveryPhraseFlow.init(UseRecoveryPhraseFlow.Type.Login)
        }

        onFinished: {
            d.flow = Onboarding.SecondaryFlow.LoginWithSyncing
            d.pushOrSkipBiometricsPage()
        }
    }

    LoginWithKeycardFlow {
        id: loginWithKeycardFlow

        stackView: root.stackView
        keycardState: root.keycardState
        remainingPinAttempts: root.remainingPinAttempts
        remainingPukAttempts: root.remainingPukAttempts
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        tryToSetPinFunction: root.tryToSetPinFunction
        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onKeycardPinEntered: (pin) => root.keycardPinEntered(pin)
        onReloadKeycardRequested: root.reloadKeycardRequested()
        onCreateProfileWithEmptyKeycardRequested: keycardCreateProfileFlow.init()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        onUnblockWithSeedphraseRequested: unblockWithSeedphraseFlow.init()
        onUnblockWithPukRequested: unblockWithPukFlow.init()

        onFinished: {
            d.flow = Onboarding.SecondaryFlow.LoginWithKeycard
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

        onReloadKeycardRequested: root.reloadKeycardRequested()
        onKeycardPinCreated: (pin) => {
            unblockWithPukFlow.pin = pin
            root.keycardPinCreated(pin)
        }
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()

        onFinished: {
            if (root.loginScreen) {
                root.loginRequested(root.loginScreen.selectedProfileKeyId,
                                    Onboarding.LoginMethod.Keycard, { pin })
            } else {
                d.flow = Onboarding.SecondaryFlow.LoginWithKeycard
                d.pushOrSkipBiometricsPage()
            }
        }
    }

    KeycardCreateReplacementFlow {
        id: keycardCreateReplacementFlow

        stackView: root.stackView

        keycardState: root.keycardState
        addKeyPairState: root.addKeyPairState

        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onReloadKeycardRequested: root.reloadKeycardRequested()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        onKeyPairTransferRequested: root.keyPairTransferRequested()
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onLoginWithKeycardRequested: loginWithKeycardFlow.init()
        onKeypairAddTryAgainRequested: root.keyPairTransferRequested() // FIXME?

        onCreateProfileWithoutKeycardRequested: {
            const page = stackView.find(
                           item => item instanceof HelpUsImproveStatusPage)

            stackView.replace(page, createProfilePage, StackView.PopTransition)
        }

        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

        onFinished: d.pushOrSkipBiometricsPage()
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
