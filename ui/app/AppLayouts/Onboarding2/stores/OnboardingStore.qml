import QtQml 2.15

import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Onboarding.enums 1.0

QtObject {
    id: root
    signal appLoaded()

    readonly property QtObject d: StatusQUtils.QObject {
        id: d
        readonly property var onboardingModuleInst: onboardingModule
    }

    readonly property var _conn: Connections {
        target: d.onboardingModuleInst
        onAppLoaded: root.appLoaded()
    }

    // keycard
    readonly property int keycardState: d.onboardingModuleInst.keycardState // cf. enum Onboarding.KeycardState
    readonly property int keycardRemainingPinAttempts: d.onboardingModuleInst.keycardRemainingPinAttempts

    function shouldStartWithOnboardingScreen() { // -> bool
        return d.onboardingModuleInst.shouldStartWithOnboardingScreen()
    }

    function finishOnboardingFlow(flow: int, data: Object) { // -> bool
        return d.onboardingModuleInst.finishOnboardingFlow(flow, JSON.stringify(data))
    }

    function setPin(pin: string) { // -> bool
        return d.onboardingModuleInst.setPin(pin)
    }

    readonly property int addKeyPairState: d.onboardingModuleInst.addKeyPairState // cf. enum Onboarding.AddKeyPairState
    function startKeypairTransfer() { // -> void
        d.onboardingModuleInst.startKeypairTransfer()
    }

    // password
    function getPasswordStrengthScore(password: string) { // -> int
        return d.onboardingModuleInst.getPasswordStrengthScore(password, "") // The second argument is username
    }

    // seedphrase/mnemonic
    function validMnemonic(mnemonic: string) { // -> bool
        return d.onboardingModuleInst.validMnemonic(mnemonic)
    }
    function getMnemonic() { // -> string
        return d.onboardingModuleInst.mnemonic()
    }
    function mnemonicWasShown() { // -> void
        d.onboardingModuleInst.mnemonicWasShown()
    }
    function removeMnemonic() { // -> void
        d.onboardingModuleInst.removeMnemonic()
    }

    // sync
    readonly property int syncState: d.onboardingModuleInst.syncState // cf. enum Onboarding.SyncState
    function validateLocalPairingConnectionString(connectionString: string) { // -> bool
        return d.onboardingModuleInst.validateLocalPairingConnectionString(connectionString)
    }
    function inputConnectionStringForBootstrapping(connectionString: string) { // -> void
        d.onboardingModuleInst.inputConnectionStringForBootstrapping(connectionString)
    }
}
