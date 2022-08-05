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

    width: 640
    height: 640
    margins: 8
    anchors.centerIn: parent
    closePolicy: d.resetInProgress? Popup.NoAutoClose : Popup.CloseOnEscape

    header.title: qsTr("Factory reset a Keycard")

    QtObject {
        id: d
        property bool factoryResetConfirmed: false
        property bool resetInProgress: d.factoryResetConfirmed && root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard

        onResetInProgressChanged: {
            hasCloseButton = !resetInProgress
        }
    }

    onClosed: {
        // for all states but the `factoryResetConfirmation` cancel the flow is primary action
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
        {
            root.sharedKeycardModule.currentState.doSecondaryAction()
            return
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
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard)
                {
                    return initComponent
                }

                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
                {
                    return confirmationComponent
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

                onConfirmationUpdated: {
                    d.factoryResetConfirmed = value
                }
            }
        }
    }

    leftButtons: [
        StatusBackButton {
            id: backButton
            visible: root.sharedKeycardModule.currentState.displayBackButton
            onClicked: {
                root.sharedKeycardModule.currentState.backAction()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: secondaryButton
            text: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
                    return qsTr("Cancel")
                return ""
            }
            visible: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
                    return true
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
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
                    return qsTr("Factory reset this Keycard")
                if (d.resetInProgress ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess)
                    return qsTr("Done")
                return qsTr("Cancel")
            }
            enabled: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation)
                    return d.factoryResetConfirmed
                if (d.resetInProgress)
                    return false
                return true
            }
            highlighted: focus

            onClicked: {
                root.sharedKeycardModule.currentState.doPrimaryAction()
            }
        }
    ]
}
