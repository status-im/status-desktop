import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14
import QtQml.StateMachine 1.14 as DSM

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.controls 1.0
import shared.views 1.0

import "setupsyncing" as Views
import "../stores"

StatusDialog {
    id: root

    required property string rawConnectionString

    property DevicesStore devicesStore
    property ProfileStore profileStore

    width: 480
    padding: 16
    modal: true

    title: qsTr("Sync a New Device")

    QtObject {
        id: d

        signal generatingConnectionStringFailed
        signal connectionStringGenerated

        signal localPairingStarted
        signal localPairingFailed
        signal localPairingFinished
        property string localPairingErrorMessage

        property string connectionString
        property string errorMessage

        function generateConnectionString() {

            d.connectionString = ""
            d.errorMessage = ""

            try {
                const json = JSON.parse(root.rawConnectionString)
                d.errorMessage = json.error
            } catch (e) {
                d.connectionString = root.rawConnectionString
            }

            if (d.errorMessage !== "") {
                d.generatingConnectionStringFailed()
                return
            }

            displaySyncCodeView.secondsTimeout = 5 * 60 // This timeout should be moved to status-go.
            displaySyncCodeView.start()
        }
    }

    Connections {
        target: root.devicesStore
        function onLocalPairingStateChanged() {
            switch (root.devicesStore.localPairingState) {
            case Constants.LocalPairingState.Transferring:
                d.localPairingStarted()
                break
            case Constants.LocalPairingState.Error:
                d.localPairingFailed()
                break
            case Constants.LocalPairingState.Finished:
                d.localPairingFinished()
                break
            }
        }
    }

    DSM.StateMachine {
        id: stateMachine

        running: root.visible
        initialState: displaySyncCodeState

        DSM.State {
            id: displaySyncCodeState

            onEntered: {
                d.generateConnectionString()
            }

            DSM.SignalTransition {
                targetState: errorState
                signal: d.generatingConnectionStringFailed
            }

            DSM.SignalTransition {
                targetState: localPairingBaseState
                signal: d.localPairingStarted
            }

            DSM.SignalTransition {
                targetState: finalState
                signal: nextButton.clicked
            }

            // Next 2 transitions are here temporarily.
            // TODO: Remove when server notifies with ProcessSuccess/ProcessError event.

            DSM.SignalTransition {
                targetState: localPairingFailedState
                signal: d.localPairingFailed
            }

            DSM.SignalTransition {
                targetState: localPairingSuccessState
                signal: d.localPairingFinished
            }
        }

        DSM.State {
            id: localPairingBaseState

            initialState: localPairingInProgressState

            DSM.State {
                id: localPairingInProgressState

                DSM.SignalTransition {
                    targetState: localPairingFailedState
                    signal: d.localPairingFailed
                }

                DSM.SignalTransition {
                    targetState: localPairingSuccessState
                    signal: d.localPairingFinished
                }
            }

            DSM.State {
                id: localPairingFailedState

                DSM.SignalTransition {
                    targetState: finalState
                    signal: nextButton.clicked
                }
            }

            DSM.State {
                id: localPairingSuccessState

                DSM.SignalTransition {
                    targetState: finalState
                    signal: nextButton.clicked
                }
            }
        }

        DSM.State {
            id: errorState

            DSM.SignalTransition {
                targetState: finalState
                signal: nextButton.clicked
            }
        }

        DSM.FinalState {
            id: finalState
            onEntered: {
                root.close()
            }
        }
    }

    contentItem: Item {

        implicitWidth: Math.max(displaySyncCodeView.implicitWidth,
                                localPairingView.implicitWidth,
                                errorView.implicitWidth)

        implicitHeight: Math.max(displaySyncCodeView.implicitHeight,
                                 localPairingView.implicitHeight,
                                 errorView.implicitHeight)

        Views.DisplaySyncCode {
            id: displaySyncCodeView
            anchors.fill: parent
            visible: displaySyncCodeState.active
            connectionString: d.connectionString
            secondsTimeout: 5 * 60
            onRequestConnectionString: {
                d.generateConnectionString()
            }
        }

        DeviceSyncingView {
            id: localPairingView
            anchors.fill: parent
            visible: localPairingBaseState.active
            devicesModel: root.devicesStore.devicesModel
            userDisplayName: root.profileStore.displayName
            userPublicKey: root.profileStore.pubkey
            userImage: root.profileStore.icon

            localPairingState: root.devicesStore.localPairingState
            localPairingError: root.devicesStore.localPairingError

            installationId: root.devicesStore.localPairingInstallationId
            installationName: root.devicesStore.localPairingInstallationName
            installationDeviceType: root.devicesStore.localPairingInstallationDeviceType
        }

        Views.ErrorMessage {
            id: errorView
            anchors.fill: parent
            visible: errorState.active
            primaryText: qsTr("Failed to generate sync code")
            secondaryText: d.errorMessage
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                id: nextButton
                visible: !!text
                enabled: !localPairingInProgressState.active
                text: {
                    if (displaySyncCodeState.active
                        || localPairingInProgressState.active
                        || localPairingSuccessState.active)
                        return qsTr("Done");
                    if (localPairingFailedState.active
                        || errorState.active)
                        return qsTr("Close");
                    return ""
                }
            }
        }
    }
}
