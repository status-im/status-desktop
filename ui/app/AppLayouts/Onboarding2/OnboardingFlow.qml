import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

OnboardingStackView {
    id: root

    required property var loginAccountsModel

    required property int keycardState
    required property string keycardUID
    required property int pinSettingState
    required property int authorizationState
    required property int restoreKeysExportState
    required property int addKeyPairState
    required property int syncState
    required property int remainingPinAttempts
    required property int remainingPukAttempts

    required property bool biometricsAvailable
    required property bool displayKeycardPromoBanner
    required property bool networkChecksEnabled

    property bool isKeycardEnabled: true
    property int keycardPinInfoPageDelay: 2000

    // functions
    required property var generateMnemonic
    required property var isBiometricsLogin // (string account) => bool
    required property var passwordStrengthScoreFunction
    required property var isSeedPhraseValid
    required property var isSeedPhraseDuplicate
    required property var validateConnectionString
    required property var tryToSetPukFunction

    readonly property LoginScreen loginScreen: d.loginScreen

    signal biometricsRequested(string profileId)
    signal dismissBiometricsRequested
    signal loginRequested(string keyUid, int method, var data)
    signal setPinRequested(string pin)
    signal enableBiometricsRequested(bool enable)
    signal shareUsageDataRequested(bool enabled)
    signal syncProceedWithConnectionString(string connectionString)
    signal seedphraseSubmitted(string seedphrase)
    signal keyUidSubmitted(string keyUid)
    signal setPasswordRequested(string password)
    signal exportKeysRequested
    signal loadMnemonicRequested
    signal authorizationRequested(string pin)
    signal performKeycardFactoryResetRequested

    signal linkActivated(string link)

    signal finished(int flow)

    function restart() {
        replace(null, initialComponent)
    }

    function setBiometricResponse(secret: string, error = "") {
        if (!loginScreen)
            return

        loginScreen.setBiometricResponse(secret, error)
    }

    QtObject {
        id: d

        property int flow
        property LoginScreen loginScreen: null

        function pushOrSkipBiometricsPage() {
            if (root.biometricsAvailable) {
                root.replace(null, enableBiometricsPage)
            } else {
                root.finished(d.flow)
            }
        }

        function openPrivacyPolicyPopup() {
            privacyPolicyPopup.createObject(root).open()
        }

        function openTermsOfUsePopup() {
            termsOfUsePopup.createObject(root).open()
        }

        function handleKeycardProgressFailedState(state) {
            if (state === Onboarding.ProgressState.Failed)
                handleKeycardFailedState()
        }

        function handleKeycardAuthorizationErrorState(state) {
            if (state === Onboarding.AuthorizationState.Error)
                handleKeycardFailedState()
        }

        function handleKeycardFailedState() {
            root.replace(root.get(1), errorPage)
        }
    }

    Connections {
        enabled: root.depth > 1 && !(root.currentItem instanceof KeycardErrorPage)

        function onPinSettingStateChanged() {
            d.handleKeycardProgressFailedState(pinSettingState)
        }

        function onAuthorizationStateChanged() {
            d.handleKeycardAuthorizationErrorState(authorizationState)
        }

        function onRestoreKeysExportStateChanged() {
            d.handleKeycardProgressFailedState(restoreKeysExportState)
        }

        function onAddKeyPairStateChanged() {
            d.handleKeycardProgressFailedState(addKeyPairState)
        }
    }

    initialItem: initialComponent

    Component {
        id: initialComponent

        Loader {
            sourceComponent: loginAccountsModel.ModelCount.empty ? welcomePage
                                                                 : loginScreenComponent
        }
    }

    Component {
        id: errorPage

        KeycardErrorPage {
            readonly property bool backAvailableHint: false

            onTryAgainRequested: root.pop()
            onFactoryResetRequested: root.push(keycardFactoryResetFlow)
        }
    }

    function startWithProxy(component) {
        const page = root.push(helpUsImproveStatusPage)

        page.shareUsageDataRequested.connect(enabled => {
            root.push(component)
        })
    }

    Component {
        id: welcomePage

        WelcomePage {
            onCreateProfileRequested: startWithProxy(createProfilePage)
            onLoginRequested: startWithProxy(loginPage)

            onPrivacyPolicyRequested: d.openPrivacyPolicyPopup()
            onTermsOfUseRequested: d.openTermsOfUsePopup()
        }
    }

    Component {
        id: loginScreenComponent

        LoginScreen {
            id: loginScreen

            keycardState: root.keycardState
            keycardUID: root.keycardUID
            keycardRemainingPinAttempts: root.remainingPinAttempts
            keycardRemainingPukAttempts: root.remainingPukAttempts

            loginAccountsModel: root.loginAccountsModel
            isKeycardEnabled: root.isKeycardEnabled
            isBiometricsLogin: root.biometricsAvailable &&
                               root.isBiometricsLogin(loginScreen.selectedProfileKeyId)

            onBiometricsRequested: (profileId) => {
                if (visible)
                    root.biometricsRequested(profileId)
            }
            onDismissBiometricsRequested: root.dismissBiometricsRequested()
            onLoginRequested: (keyUid, method, data) => root.loginRequested(keyUid, method, data)
            onOnboardingCreateProfileFlowRequested: startWithProxy(createProfilePage)
            onOnboardingLoginFlowRequested: startWithProxy(loginPage)
            onLostKeycardFlowRequested: {
                root.keyUidSubmitted(loginScreen.selectedProfileKeyId)
                root.push(keycardLostPage)
            }

            onUnblockWithSeedphraseRequested: root.push(unblockWithSeedphraseFlow)
            onUnblockWithPukRequested: root.push(unblockWithPukFlow)

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
            onShareUsageDataRequested: (enabled) => root.shareUsageDataRequested(enabled)
        }
    }

    Component {
        id: createProfilePage

        CreateProfilePage {
            isKeycardEnabled: root.isKeycardEnabled

            onCreateProfileWithPasswordRequested: root.push(createNewProfileFlow)
            onCreateProfileWithSeedphraseRequested: {
                d.flow = Onboarding.OnboardingFlow.CreateProfileWithSeedphrase
                root.push(useRecoveryPhraseFlow,
                          { type: UseRecoveryPhraseFlow.Type.NewProfile })
            }
            onCreateProfileWithEmptyKeycardRequested: root.push(keycardCreateProfileFlow)
        }
    }

    Component {
        id: loginPage

        NewAccountLoginPage {
            networkChecksEnabled: root.networkChecksEnabled
            isKeycardEnabled: root.isKeycardEnabled

            onLoginWithSyncingRequested: root.push(logInBySyncingFlow)
            onLoginWithKeycardRequested: root.push(loginWithKeycardFlow)

            onLoginWithSeedphraseRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithSeedphrase
                root.push(useRecoveryPhraseFlow,
                          { type: UseRecoveryPhraseFlow.Type.Login })
            }
        }
    }

    Component {
        id: keycardLostPage

        KeycardLostPage {
            onCreateReplacementKeycardRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithRestoredKeycard
                root.push(keycardCreateReplacementFlow)
            }

            onUseProfileWithoutKeycardRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithLostKeycardSeedphrase
                root.push(useRecoveryPhraseFlow,
                          { type: UseRecoveryPhraseFlow.Type.KeycardRecovery })
            }
        }
    }

    Component {
        id: createNewProfileFlow

        CreateNewProfileFlow {
            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

            onFinished: (password) => {
                root.setPasswordRequested(password)
                d.flow = Onboarding.OnboardingFlow.CreateProfileWithPassword
                d.pushOrSkipBiometricsPage()
            }
        }
    }

    Component {
        id: useRecoveryPhraseFlow

        UseRecoveryPhraseFlow {
            isSeedPhraseValid: root.isSeedPhraseValid
            isSeedPhraseDuplicate: root.isSeedPhraseDuplicate
            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

            onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)
            onSetPasswordRequested: (password) => root.setPasswordRequested(password)
            onFinished: d.pushOrSkipBiometricsPage()
        }
    }

    Component {
        id: keycardCreateProfileFlow

        KeycardCreateProfileFlow {
            keycardState: root.keycardState
            pinSettingState: root.pinSettingState
            authorizationState: root.authorizationState
            addKeyPairState: root.addKeyPairState
            generateMnemonic: root.generateMnemonic
            displayKeycardPromoBanner: root.displayKeycardPromoBanner
            isSeedPhraseValid: root.isSeedPhraseValid

            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onKeycardFactoryResetRequested: root.push(keycardFactoryResetFlow)
            onLoadMnemonicRequested: root.loadMnemonicRequested()
            onSetPinRequested: (pin) => root.setPinRequested(pin)
            onLoginWithKeycardRequested: root.push(loginWithKeycardFlow)
            onAuthorizationRequested: root.authorizationRequested("") // Pin was saved locally already
            onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

            onFinished: (withNewSeedphrase) => {
                d.flow = withNewSeedphrase
                            ? Onboarding.OnboardingFlow.CreateProfileWithKeycardNewSeedphrase
                            : Onboarding.OnboardingFlow.CreateProfileWithKeycardExistingSeedphrase

                d.pushOrSkipBiometricsPage()
            }
        }
    }

    Component {
        id: logInBySyncingFlow

        LoginBySyncingFlow {
            validateConnectionString: root.validateConnectionString
            syncState: root.syncState

            onSyncProceedWithConnectionString:
                (connectionString) => root.syncProceedWithConnectionString(connectionString)

            onLoginWithSeedphraseRequested: {
                d.flow = Onboarding.OnboardingFlow.LoginWithSeedphrase

                root.push(useRecoveryPhraseFlow,
                          { type: UseRecoveryPhraseFlow.Type.Login })
            }

            onFinished: {
                d.flow = Onboarding.OnboardingFlow.LoginWithSyncing
                d.pushOrSkipBiometricsPage()
            }
        }
    }

    Component {
        id: loginWithKeycardFlow

        LoginWithKeycardFlow {
            keycardState: root.keycardState
            authorizationState: root.authorizationState
            restoreKeysExportState: root.restoreKeysExportState
            remainingPinAttempts: root.remainingPinAttempts
            remainingPukAttempts: root.remainingPukAttempts
            displayKeycardPromoBanner: root.displayKeycardPromoBanner
            onAuthorizationRequested: root.authorizationRequested(pin)

            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onCreateProfileWithEmptyKeycardRequested: root.push(keycardCreateProfileFlow)
            onExportKeysRequested: root.exportKeysRequested()
            onKeycardFactoryResetRequested: root.push(keycardFactoryResetFlow)
            onUnblockWithSeedphraseRequested: root.push(unblockWithSeedphraseFlow)
            onUnblockWithPukRequested: root.push(unblockWithPukFlow)

            onFinished: {
                d.flow = Onboarding.OnboardingFlow.LoginWithKeycard
                d.pushOrSkipBiometricsPage()
            }
        }
    }

    Component {
        id: unblockWithSeedphraseFlow

        UnblockWithSeedphraseFlow {
            property string pin

            isSeedPhraseValid: root.isSeedPhraseValid
            pinSettingState: root.pinSettingState
            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

            onSetPinRequested: (pin) => {
                unblockWithSeedphraseFlow.pin = pin
                root.setPinRequested(pin)
            }

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
    }

    Component {
        id: unblockWithPukFlow

        UnblockWithPukFlow {
            property string pin

            keycardState: root.keycardState
            pinSettingState: root.pinSettingState
            tryToSetPukFunction: root.tryToSetPukFunction
            remainingAttempts: root.remainingPukAttempts
            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onSetPinRequested: (pin) => {
                unblockWithPukFlow.pin = pin
                root.setPinRequested(pin)
            }
            onKeycardFactoryResetRequested: root.push(keycardFactoryResetFlow)

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
    }

    Component {
        id: keycardCreateReplacementFlow

        KeycardCreateReplacementFlow {
            keycardState: root.keycardState
            pinSettingState: root.pinSettingState
            authorizationState: root.authorizationState
            addKeyPairState: root.addKeyPairState

            displayKeycardPromoBanner: root.displayKeycardPromoBanner
            isSeedPhraseValid: root.isSeedPhraseValid

            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onKeycardFactoryResetRequested: root.push(keycardFactoryResetFlow,
                                                      { fromLoginScreen: true })
            onSetPinRequested: (pin) => root.setPinRequested(pin)
            onLoginWithKeycardRequested: root.push(loginWithKeycardFlow)
            onAuthorizationRequested: root.authorizationRequested("") // Pin was saved locally already
            onLoadMnemonicRequested: root.loadMnemonicRequested()

            onCreateProfileWithoutKeycardRequested: {
                const page = root.find(item => item instanceof HelpUsImproveStatusPage)
                root.replace(page, createProfilePage, StackView.PopTransition)
            }

            onSeedphraseSubmitted: (seedphrase) => root.seedphraseSubmitted(seedphrase)

            onFinished: d.pushOrSkipBiometricsPage()
        }
    }

    Component {
        id: keycardFactoryResetFlow

        KeycardFactoryResetFlow {
            keycardState: root.keycardState

            onPerformKeycardFactoryResetRequested: root.performKeycardFactoryResetRequested()
            onFinished: root.pop(null)
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
