import QtQuick 2.14

import StatusQ.Controls 0.1

import utils 1.0

QtObject {
    id: root

    property var sharedKeycardModule

    property bool primaryButtonEnabled: false
    readonly property bool disablePopupClose: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode ||
                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                                              (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess &&
                                               root.sharedKeycardModule.migratingProfileKeyPair())

    property list<Item> leftButtons: [
        StatusBackButton {
            id: backButton
            visible: root.sharedKeycardModule.currentState.displayBackButton
            height: Constants.keycard.general.footerButtonsHeight
            width: height
            onClicked: {
                root.sharedKeycardModule.currentState.backAction()
            }
        }
    ]

    property list<StatusBaseButton> rightButtons: [
        StatusButton {
            id: tertiaryButton
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return qsTr("Cancel")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation) {
                        return qsTr("Cancel")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin)
                        return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.unlockKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardOptions ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase)
                        return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.displayKeycardContent) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached)
                        return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached)
                        return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached)
                        return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPuk) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached)
                        return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changePairingCode) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPairingCode ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached)
                        return qsTr("Cancel")
                }

                return ""
            }
            visible: text !== ""
            enabled: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode) {
                    if (root.disablePopupClose) {
                        return false
                    }
                }
                return true
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doTertiaryAction()
            }
        },

        StatusButton {
            id: secondaryButton
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (userProfile.usingBiometricLogin) {
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword)
                            return qsTr("Use biometrics instead")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed)
                            return qsTr("Use password instead")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin)
                            return qsTr("Use biometrics")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty)
                            return qsTr("Use PIN")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid)
                            return qsTr("Update PIN")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.unlockKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardOptions)
                        return qsTr("Unlock using PUK")
                }

                return ""
            }
            visible: text !== ""
            enabled: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode) {
                    if (root.disablePopupClose) {
                        return false
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (userProfile.usingBiometricLogin &&
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty))
                        return false
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.unlockKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardOptions)
                        return root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.offerPukForUnlock
                }
                return true
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doSecondaryAction()
            }
        },

        StatusButton {
            id: primaryButton
            objectName: "PrimaryButton"
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet) {
                        return qsTr("Input seed phrase")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords) {
                        return qsTr("Yes, migrate key pair to this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                        return qsTr("Yes, migrate key pair to Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase) {
                        return qsTr("Try entering seed phrase again")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty) {
                        return qsTr("Check what is stored on this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return qsTr("Factory reset this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        if (root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.useUnlockLabelForLockedState)
                            return qsTr("Unlock Keycard")
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure) {
                        return qsTr("Done")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess) {
                        if (root.sharedKeycardModule.migratingProfileKeyPair())
                            return qsTr("Restart app & sign in using your new Keycard")
                        return qsTr("Done")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return qsTr("Factory reset this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess) {
                        return qsTr("Done")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin) {
                        return qsTr("Authenticate")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty) {
                        return qsTr("Done")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword) {
                        return qsTr("Update password & authenticate")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
                        return qsTr("Update PIN & authenticate")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid) {
                        return qsTr("Try biometrics again")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.unlockKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardAlreadyUnlocked ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardSuccess)
                        return qsTr("Done")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardOptions)
                        return qsTr("Unlock using seed phrase")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk)
                        return qsTr("Next")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase) {
                        return qsTr("Try entering seed phrase again")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached) {
                        return qsTr("Unlock Keycard")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.displayKeycardContent) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return qsTr("Done")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard)
                        return qsTr("Done")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterKeycardName) {
                        return qsTr("Rename this Keycard")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinFailure)
                        return qsTr("Done")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPuk) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukFailure)
                        return qsTr("Done")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changePairingCode) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeFailure)
                        return qsTr("Done")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached) {
                        return qsTr("Unlock Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPairingCode) {
                        return qsTr("Set paring code")
                    }
                }

                return ""
            }
            visible: text !== ""
            enabled: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode) {
                    if (root.disablePopupClose) {
                        return false
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                        return root.primaryButtonEnabled
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin) {
                        return false
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return root.primaryButtonEnabled
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin) {
                        return root.primaryButtonEnabled
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.unlockKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPuk ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk)
                        return root.primaryButtonEnabled
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin)
                        return false
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterKeycardName)
                        return root.primaryButtonEnabled
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changePairingCode) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPairingCode)
                        return root.primaryButtonEnabled
                }
                return true
            }
            icon.name: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.migratingProfileKeyPair() &&
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase)) {
                        if (userProfile.usingBiometricLogin)
                            return "touch-id"
                        if (userProfile.isKeycardUser)
                            return "keycard"
                        return "password"
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (userProfile.usingBiometricLogin) {
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                            return "touch-id"
                    }
                }
                return ""
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doPrimaryAction()
            }
        }
    ]
}
