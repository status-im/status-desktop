import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property int keycardState
    required property int pinSettingState
    required property int authorizationState
    required property int restoreKeysExportState
    required property int addKeyPairState
    required property int syncState
    required property var getSeedWords
    required property int remainingPinAttempts
    required property int remainingPukAttempts

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

    signal keycardPinCreated(string pin)
    signal enableBiometricsRequested(bool enable)
    signal shareUsageDataRequested(bool enabled)
    signal syncProceedWithConnectionString(string connectionString)
    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal reloadKeycardRequested
    signal keycardFactoryResetRequested
    signal exportKeysRequested
    signal loadMnemonicRequested
    signal authorizationRequested(string pin)

    signal linkActivated(string link)

    signal finished(int flow)

    function init() {
        root.stackView.push(welcomePage)
    }

    function startCreateProfileFlow() {
        root.stackView.push(createProfilePage)
    }

    function startLoginFlow() {
        root.stackView.push(loginPage)
    }

    function startLostKeycardFlow() {
        root.stackView.push(keycardLostPage)
    }

    QtObject {
        id: d

        property int flow

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
        pinSettingState: root.pinSettingState
        authorizationState: root.authorizationState
        addKeyPairState: root.addKeyPairState
        getSeedWords: root.getSeedWords
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onReloadKeycardRequested: root.reloadKeycardRequested()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        onLoadMnemonicRequested: root.loadMnemonicRequested()
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onLoginWithKeycardRequested: loginWithKeycardFlow.init()
        // onKeypairAddTryAgainRequested: root.keyPairTransferRequested() // FIXME?
        onAuthorizationRequested: root.authorizationRequested("") // Pin was saved locally already

        onCreateProfileWithoutKeycardRequested: {
            const page = stackView.find(
                           item => item instanceof HelpUsImproveStatusPage)

            stackView.replace(page, createProfilePage, StackView.PopTransition)
        }

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
        authorizationState: root.authorizationState
        restoreKeysExportState: root.restoreKeysExportState
        remainingPinAttempts: root.remainingPinAttempts
        remainingPukAttempts: root.remainingPukAttempts
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        onAuthorizationRequested: root.authorizationRequested(pin)
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)
        onReloadKeycardRequested: root.reloadKeycardRequested()
        onCreateProfileWithEmptyKeycardRequested: keycardCreateProfileFlow.init()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        onExportKeysRequested: root.exportKeysRequested()
        onUnblockWithPukRequested: unblockWithPukFlow.init()

        onFinished: {
            d.flow = Onboarding.SecondaryFlow.LoginWithKeycard
            d.pushOrSkipBiometricsPage()
        }
    }

    UnblockWithPukFlow {
        id: unblockWithPukFlow

        stackView: root.stackView
        keycardState: root.keycardState
        tryToSetPukFunction: root.tryToSetPukFunction
        remainingAttempts: root.remainingPukAttempts

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onReloadKeycardRequested: root.reloadKeycardRequested()
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()

        onFinished: {
            d.flow = Onboarding.SecondaryFlow.LoginWithKeycard
            d.pushOrSkipBiometricsPage()
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

        onReloadKeycardRequested: root.reloadKeycardRequested()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onLoginWithKeycardRequested: loginWithKeycardFlow.init()
        onAuthorizationRequested: root.authorizationRequested("") // Pin was saved locally already
        // onKeypairAddTryAgainRequested: root.keyPairTransferRequested() // FIXME?

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
