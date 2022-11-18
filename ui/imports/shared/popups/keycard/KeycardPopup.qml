import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusModal {
    id: root

    property var sharedKeycardModule

    width: Constants.keycard.general.popupWidth
    anchors.centerIn: parent
    closePolicy: d.disablePopupClose? Popup.NoAutoClose : Popup.CloseOnEscape

    header.title: {
        switch (root.sharedKeycardModule.currentState.flowType) {
        case Constants.keycardSharedFlow.setupNewKeycard:
            return qsTr("Set up a new Keycard with an existing account")
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

        onDisablePopupCloseChanged: {
            hasCloseButton = !disablePopupClose
        }
    }

    onClosed: {
        root.sharedKeycardModule.currentState.doCancelAction()
    }

    contentItem: StatusScrollView {
        id: scrollView
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        width: parent.width
        height: {
            let availableSpace = Global.applicationWindow.height - (root.margins * 2 + root.topPadding + root.bottomPadding)
            return Math.min(content.height, availableSpace)
        }

        KeycardPopupContent {
            id: content
            width: scrollView.availableWidth
            height: {
                // for all flows
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                    if (!root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                        return Constants.keycard.general.popupBiggerHeight
                    }
                }

                return Constants.keycard.general.popupHeight
            }

            sharedKeycardModule: root.sharedKeycardModule
            onPrimaryButtonEnabledChanged: d.primaryButtonEnabled = primaryButtonEnabled
        }
    }

    leftButtons: d.leftButtons
    rightButtons: d.rightButtons
}
