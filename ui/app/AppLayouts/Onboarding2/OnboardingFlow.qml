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
    required property int addKeyPairState
    required property int syncState
    required property var seedWords
    required property int remainingAttempts

    required property bool biometricsAvailable
    required property bool displayKeycardPromoBanner
    required property bool networkChecksEnabled

    property int keycardPinInfoPageDelay: 2000

    // functions
    required property var passwordStrengthScoreFunction
    required property var isSeedPhraseValid
    required property var validateConnectionString
    required property var tryToSetPinFunction

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
                useRecoveryPhraseFlow.init()
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
                useRecoveryPhraseFlow.init()
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

        onFinished: (fromBackupSeedphrase) => {
            d.flow = fromBackupSeedphrase
                        ? Onboarding.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase
                        : Onboarding.SecondaryFlow.CreateProfileWithKeycardNewSeedphrase

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
            useRecoveryPhraseFlow.init()
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
        remainingAttempts: root.remainingAttempts
        displayKeycardPromoBanner: root.displayKeycardPromoBanner
        tryToSetPinFunction: root.tryToSetPinFunction
        isSeedPhraseValid: root.isSeedPhraseValid

        keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

        onKeycardPinEntered: (pin) => root.keycardPinEntered(pin)
        onKeycardPinCreated: (pin) => root.keycardPinCreated(pin)
        onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)
        onReloadKeycardRequested: root.reloadKeycardRequested()
        onCreateProfileWithEmptyKeycardRequested: keycardCreateProfileFlow.init()
        onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()

        onFinished: {
            d.flow = Onboarding.SecondaryFlow.LoginWithKeycard
            d.pushOrSkipBiometricsPage()
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
