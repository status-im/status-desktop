import QtQuick 2.14

import utils 1.0

import "./states"

Item {
    id: root

    property var sharedKeycardModule
    readonly property alias primaryButtonEnabled: d.primaryButtonEnabled

    objectName: "KeycardSharedPopupContent"

    QtObject {
        id: d
        property bool primaryButtonEnabled: false
        property bool seedPhraseRevealed: false
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameFailure ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukFailure ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeFailure ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardAlreadyUnlocked ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardOptions ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid)
            {
                return initComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata)
            {
                return confirmationComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair)
            {
                return selectKeyPairComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinFailure ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified)
            {
                return keycardPinComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPuk ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPuk ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPuk ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk)
            {
                return keycardPukComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase)
            {
                return enterSeedPhraseComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay)
            {
                return seedPhraseComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords)
            {
                return enterSeedPhraseWordsComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword) {
                return passwordComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterKeycardName) {
                return enterNameComponent
            }
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPairingCode) {
                return enterPairingCodeComponent
            }

            return undefined
        }
    }

    Component {
        id: initComponent
        KeycardInit {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }
        }
    }

    Component {
        id: confirmationComponent
        KeycardConfirmation {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onConfirmationUpdated: {
                d.primaryButtonEnabled = value
            }
        }
    }

    Component {
        id: selectKeyPairComponent
        SelectKeyPair {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onKeyPairSelected: {
                d.primaryButtonEnabled = true
            }
        }
    }

    Component {
        id: keycardPinComponent
        KeycardPin {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onPinUpdated: {
                d.primaryButtonEnabled = pin.length === Constants.keycard.general.keycardPinLength
            }
        }
    }

    Component {
        id: keycardPukComponent
        KeycardPuk {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onPukUpdated: {
                d.primaryButtonEnabled = puk.length === Constants.keycard.general.keycardPukLength
            }
        }
    }

    Component {
        id: enterSeedPhraseComponent
        EnterSeedPhrase {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onValidation: {
                d.primaryButtonEnabled = result
            }
        }
    }

    Component {
        id: seedPhraseComponent
        SeedPhrase {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                hideSeed = !d.seedPhraseRevealed
                d.primaryButtonEnabled = Qt.binding(function(){ return d.seedPhraseRevealed })
            }

            onSeedPhraseRevealed: {
                d.seedPhraseRevealed = true
            }
        }
    }

    Component {
        id: enterSeedPhraseWordsComponent
        EnterSeedPhraseWords {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onValidation: {
                d.primaryButtonEnabled = result
            }
        }
    }

    Component {
        id: passwordComponent
        EnterPassword {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onPasswordValid: {
                d.primaryButtonEnabled = valid
            }
        }
    }

    Component {
        id: enterNameComponent
        EnterName {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onValidation: {
                d.primaryButtonEnabled = result
            }
        }
    }

    Component {
        id: enterPairingCodeComponent
        EnterPairingCode {
            sharedKeycardModule: root.sharedKeycardModule

            Component.onCompleted: {
                d.primaryButtonEnabled = false
            }

            onValidation: {
                d.primaryButtonEnabled = result
            }
        }
    }
}
