import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

import "./states"

StatusModal {
    id: root

    property var sharedKeycardModule

    width: Constants.keycard.general.popupWidth
    height: {
        if (!root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
            if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                    return Constants.keycard.general.popupBiggerHeight
                }
            }
            if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                    return Constants.keycard.general.popupBiggerHeight
                }
            }
        }
        return Constants.keycard.general.popupHeight
    }
    margins: Style.current.halfPadding
    anchors.centerIn: parent
    closePolicy: d.disablePopupClose? Popup.NoAutoClose : Popup.CloseOnEscape

    header.title: {
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
            return qsTr("Set up a new Keycard with an existing account")
        }
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
            return qsTr("Factory reset a Keycard")
        }
        return ""
    }

    QtObject {
        id: d
        property bool primaryButtonEnabled: false
        property bool seedPhraseRevealed: false
        property bool disablePopupClose: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                                         (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess &&
                                         root.sharedKeycardModule.migratingProfileKeyPair())

        onDisablePopupCloseChanged: {
            hasCloseButton = !disablePopupClose
        }
    }

    onClosed: {
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase)
            {
                root.sharedKeycardModule.currentState.doSecondaryAction()
                return
            }
        }
        else if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
            if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                    root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
            {
                root.sharedKeycardModule.currentState.doSecondaryAction()
                return
            }
        }
        root.sharedKeycardModule.currentState.doPrimaryAction()
    }

    contentItem: Item {
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
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay)
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
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified)
                {
                    return keycardPinComponent
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

                return undefined
            }
        }

        Component {
            id: initComponent
            KeycardInit {
                sharedKeycardModule: root.sharedKeycardModule
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
            }
        }

        Component {
            id: keycardPinComponent
            KeycardPin {
                sharedKeycardModule: root.sharedKeycardModule
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
    }

    leftButtons: [
        StatusBackButton {
            id: backButton
            visible: root.sharedKeycardModule.currentState.displayBackButton
            height: primaryButton.height
            width: primaryButton.height
            onClicked: {
                root.sharedKeycardModule.currentState.backAction()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: secondaryButton
            text: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return qsTr("Cancel")
                    }
                }
                else if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
                        return qsTr("Cancel")
                }
                return ""
            }
            visible: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                else if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation) {
                        return true
                    }
                }
                return false
            }
            highlighted: focus

            onClicked: {
                root.sharedKeycardModule.currentState.doSecondaryAction()
            }
        },
        StatusButton {
            id: primaryButton
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
                        return qsTr("I don’t know the pin")
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
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached) {
                        return qsTr("Tmp-Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure) {
                        return qsTr("Done")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess &&
                            root.sharedKeycardModule.migratingProfileKeyPair()) {
                        return qsTr("Restart app & sign in using your new Keycard")
                    }
                    return qsTr("Cancel")
                }
                else if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the pin")
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
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached) {
                        return qsTr("Tmp-Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess) {
                        return qsTr("Done")
                    }
                    return qsTr("Cancel")
                }
                return ""
            }
            enabled: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair) {
                    if (d.disablePopupClose) {
                        return false
                    }
                }
                else if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                        return d.primaryButtonEnabled
                    }
                    if ((root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair &&
                            root.sharedKeycardModule.keyPairModel.count === 0) ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin) {
                        return false
                    }
                }
                else if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return d.primaryButtonEnabled
                    }
                }
                return true
            }
            icon.name: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                        if (root.sharedKeycardModule.migratingProfileKeyPair()) {
                            if (root.sharedKeycardModule.loggedInUserUsesBiometricLogin())
                                return "touch-id"
                            return "password"
                        }
                    }
                }
                return ""
            }
            highlighted: focus

            onClicked: {
                root.sharedKeycardModule.currentState.doPrimaryAction()
            }
        }
    ]
}
