import QtQml 2.15

import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Onboarding.enums 1.0

QtObject {
    id: root

    signal appLoaded(string keyUid)

    readonly property QtObject d: StatusQUtils.QObject {
        id: d
        readonly property var onboardingModuleInst: onboardingModule

        Component.onCompleted: {
            d.onboardingModuleInst.appLoaded.connect(root.appLoaded)
            d.onboardingModuleInst.accountLoginError.connect(root.accountLoginError)
        }
    }

    readonly property var loginAccountsModel: d.onboardingModuleInst.loginAccountsModel

    // keycard
    readonly property int keycardState: d.onboardingModuleInst.keycardState // cf. enum Onboarding.KeycardState
    readonly property int pinSettingState: d.onboardingModuleInst.pinSettingState // cf. enum Onboarding.ProgressState
    readonly property int authorizationState: d.onboardingModuleInst.authorizationState // cf. enum Onboarding.AuthorizationState
    readonly property int restoreKeysExportState: d.onboardingModuleInst.restoreKeysExportState // cf. enum Onboarding.AuthorizationState
    readonly property int keycardRemainingPinAttempts: d.onboardingModuleInst.keycardRemainingPinAttempts
    readonly property int keycardRemainingPukAttempts: d.onboardingModuleInst.keycardRemainingPukAttempts

    function finishOnboardingFlow(flow: int, data: Object) { // -> bool
        return d.onboardingModuleInst.finishOnboardingFlow(flow, JSON.stringify(data))
    }

    function loginRequested(keyUid: string, method: int, data: Object) { // -> void
        d.onboardingModuleInst.loginRequested(keyUid, method, JSON.stringify(data))
    }

    function setPin(pin: string) {
        d.onboardingModuleInst.setPin(pin)
    }

    function setPuk(puk: string) { // -> bool
        return d.onboardingModuleInst.setPuk(puk)
    }

    function authorize(pin: string) {
        d.onboardingModuleInst.authorize(pin)
    }

    readonly property int addKeyPairState: d.onboardingModuleInst.addKeyPairState // cf. enum Onboarding.ProgressState
    function loadMnemonic(mnemonic: string) { // -> void
        d.onboardingModuleInst.loadMnemonic(mnemonic)
    }
    function exportRecoverKeys() { // -> void
        d.onboardingModuleInst.exportRecoverKeys()
    }

    function startKeycardFactoryReset() {
        d.onboardingModuleInst.startKeycardFactoryReset()
    }

    // password
    signal accountLoginError(string error, bool wrongPassword)

    function getPasswordStrengthScore(password: string) { // -> int
        return d.onboardingModuleInst.getPasswordStrengthScore(password, "") // The second argument is username
    }

    // seedphrase/mnemonic
    function validMnemonic(mnemonic: string) { // -> bool
        return d.onboardingModuleInst.validMnemonic(mnemonic)
    }
    function isMnemonicDuplicate(mnemonic: string) { // -> bool
        return d.onboardingModuleInst.isMnemonicDuplicate(mnemonic)
    }
    function generateMnemonic() { // -> string as per BIP-39 (space-separated list of words)
        return d.onboardingModuleInst.generateMnemonic()
    }

    // sync
    readonly property int syncState: d.onboardingModuleInst.syncState // cf. enum Onboarding.ProgressState
    function validateLocalPairingConnectionString(connectionString: string) { // -> bool
        return d.onboardingModuleInst.validateLocalPairingConnectionString(connectionString)
    }
    function inputConnectionStringForBootstrapping(connectionString: string) { // -> void
        d.onboardingModuleInst.inputConnectionStringForBootstrapping(connectionString)
    }
}
