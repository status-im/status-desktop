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
            switch (root.sharedKeycardModule.currentState.stateType) {
            case Constants.keycardSharedState.pluginReader:
            case Constants.keycardSharedState.insertKeycard:
            case Constants.keycardSharedState.keycardInserted:
            case Constants.keycardSharedState.readingKeycard:
            case Constants.keycardSharedState.keyPairMigrateSuccess:
            case Constants.keycardSharedState.keyPairMigrateFailure:
            case Constants.keycardSharedState.migratingKeyPair:
            case Constants.keycardSharedState.keycardRenameSuccess:
            case Constants.keycardSharedState.keycardRenameFailure:
            case Constants.keycardSharedState.renamingKeycard:
            case Constants.keycardSharedState.changingKeycardPin:
            case Constants.keycardSharedState.changingKeycardPuk:
            case Constants.keycardSharedState.changingKeycardPukSuccess:
            case Constants.keycardSharedState.changingKeycardPukFailure:
            case Constants.keycardSharedState.changingKeycardPairingCode:
            case Constants.keycardSharedState.changingKeycardPairingCodeSuccess:
            case Constants.keycardSharedState.changingKeycardPairingCodeFailure:
            case Constants.keycardSharedState.factoryResetSuccess:
            case Constants.keycardSharedState.keycardEmptyMetadata:
            case Constants.keycardSharedState.keycardEmpty:
            case Constants.keycardSharedState.keycardNotEmpty:
            case Constants.keycardSharedState.keycardAlreadyUnlocked:
            case Constants.keycardSharedState.notKeycard:
            case Constants.keycardSharedState.unlockKeycardOptions:
            case Constants.keycardSharedState.unlockKeycardSuccess:
            case Constants.keycardSharedState.wrongKeycard:
            case Constants.keycardSharedState.biometricsReadyToSign:
            case Constants.keycardSharedState.maxPinRetriesReached:
            case Constants.keycardSharedState.maxPukRetriesReached:
            case Constants.keycardSharedState.maxPairingSlotsReached:
            case Constants.keycardSharedState.recognizedKeycard:
            case Constants.keycardSharedState.keycardMetadataDisplay:
            case Constants.keycardSharedState.biometricsPasswordFailed:
            case Constants.keycardSharedState.biometricsPinFailed:
            case Constants.keycardSharedState.biometricsPinInvalid:
                return initComponent

            case Constants.keycardSharedState.factoryResetConfirmation:
            case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                return confirmationComponent

            case Constants.keycardSharedState.selectExistingKeyPair:
                return selectKeyPairComponent

            case Constants.keycardSharedState.createPin:
            case Constants.keycardSharedState.repeatPin:
            case Constants.keycardSharedState.enterPin:
            case Constants.keycardSharedState.wrongPin:
            case Constants.keycardSharedState.wrongKeychainPin:
            case Constants.keycardSharedState.changingKeycardPinSuccess:
            case Constants.keycardSharedState.changingKeycardPinFailure:
            case Constants.keycardSharedState.pinSet:
            case Constants.keycardSharedState.pinVerified:
                return keycardPinComponent

            case Constants.keycardSharedState.createPuk:
            case Constants.keycardSharedState.repeatPuk:
            case Constants.keycardSharedState.enterPuk:
            case Constants.keycardSharedState.wrongPuk:
                return keycardPukComponent

            case Constants.keycardSharedState.enterSeedPhrase:
            case Constants.keycardSharedState.wrongSeedPhrase:
                return enterSeedPhraseComponent

            case Constants.keycardSharedState.seedPhraseDisplay:
                return seedPhraseComponent

            case Constants.keycardSharedState.seedPhraseEnterWords:
                return enterSeedPhraseWordsComponent

            case Constants.keycardSharedState.enterPassword:
            case Constants.keycardSharedState.enterBiometricsPassword:
            case Constants.keycardSharedState.wrongBiometricsPassword:
            case Constants.keycardSharedState.wrongPassword:
                return passwordComponent

            case Constants.keycardSharedState.enterKeycardName:
                return enterNameComponent

            case Constants.keycardSharedState.createPairingCode:
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
