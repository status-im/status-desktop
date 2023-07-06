import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusModal {
    id: root

    property var sharedKeycardModule
    property var emojiPopup

    width: Constants.keycard.general.popupWidth
    closePolicy: d.disableActionPopupButtons || d.disableCloseButton? Popup.NoAutoClose : Popup.CloseOnEscape | Popup.CloseOnPressOutside
    hasCloseButton: !d.disableActionPopupButtons && !d.disableCloseButton

    headerSettings.title: {
        switch (root.sharedKeycardModule.currentState.flowType) {
        case Constants.keycardSharedFlow.setupNewKeycard:
            return qsTr("Set up a new Keycard with an existing account")
        case Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase:
            return qsTr("Create a new Keycard account with a new seed phrase")
        case Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase:
            return qsTr("Import or restore a Keycard via a seed phrase")
        case Constants.keycardSharedFlow.importFromKeycard:
            return qsTr("Migrate account from Keycard to Status")
        case Constants.keycardSharedFlow.factoryReset:
            return qsTr("Factory reset a Keycard")
        case Constants.keycardSharedFlow.authentication:
            return qsTr("Authenticate")
        case Constants.keycardSharedFlow.unlockKeycard:
            return qsTr("Unlock Keycard")
        case Constants.keycardSharedFlow.displayKeycardContent:
            return qsTr("Check what’s on a Keycard")
        case Constants.keycardSharedFlow.renameKeycard:
            return qsTr("Rename Keycard")
        case Constants.keycardSharedFlow.changeKeycardPin:
            return qsTr("Change pin")
        case Constants.keycardSharedFlow.changeKeycardPuk:
            return qsTr("Create a 12-digit personal unblocking key (PUK)")
        case Constants.keycardSharedFlow.changePairingCode:
            return qsTr("Create a new pairing code")
        case Constants.keycardSharedFlow.createCopyOfAKeycard:
            return qsTr("Create a backup copy of this Keycard")
        }

        return ""
    }

    KeycardPopupDetails {
        id: d
        sharedKeycardModule: root.sharedKeycardModule
        onCancelBtnClicked: {
            root.close();
        }
    }

    onClosed: {
        root.sharedKeycardModule.currentState.doCancelAction();
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth
        horizontalPadding: 0

        KeycardPopupContent {
            id: content
            width: scrollView.availableWidth
            implicitHeight: {
                // for all flows
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                    if (!root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                        return Constants.keycard.general.popupBiggerHeight
                    }
                }

                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard &&
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.manageKeycardAccounts &&
                        root.sharedKeycardModule.keyPairHelper.accounts.count > 1) {
                    return Constants.keycard.general.popupBiggerHeight
                }

                return Constants.keycard.general.popupHeight
            }

            sharedKeycardModule: root.sharedKeycardModule
            emojiPopup: root.emojiPopup
            onPrimaryButtonEnabledChanged: d.primaryButtonEnabled = primaryButtonEnabled
        }
    }

    leftButtons: d.leftButtons
    rightButtons: d.rightButtons
}
