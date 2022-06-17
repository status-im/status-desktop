import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.StateMachine 1.14 as DSM

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0

import "setupsyncing" as Views

StatusModal {
    id: root

    enum Mode {
        GenerateSyncCode,
        EnterSyncCode,
        ScanSyncCode
    }

    property int mode: SetupSyncingPopup.GenerateSyncCode

    width: implicitWidth
    padding: 16

    header.title: qsTr("Sync a New Device")

    QtObject {
        id: d


        signal otherDeviceConnected // from our SyncCode

        property int pairingFailsCount: 0
        signal pairingFailed
        signal pairingSuccess

        property bool syncing: false
        signal syncingFailed
        signal syncingSuccess

        function startPairing(syncCode) {
            // TODO: Replace with real pairing
            tempPairingTimer.start();
        }

        function startSyncing() {
            // TODO: Replace with real syncing
            tempSyncingTimer.start()
        }

    }

    Timer {
        id: tempPairingTimer
        interval: 500
        onTriggered: {
            if (++d.pairingFailsCount < 3) {
                d.pairingFailed()
                return;
            }

            d.pairingFailsCount = 0;
            d.pairingSuccess();
        }
    }

    Timer {
        id: tempSyncingTimer
        property int counter: 0
        interval: 500
        onTriggered: {
            counter = ++counter % 3;
            if (counter == 0)
                d.syncingSuccess()
            else
                d.syncingFailed()
        }
    }

    DSM.StateMachine {
        id: stateMachine

        running: root.visible
        initialState: {
            switch (root.mode) {
            case SetupSyncingPopup.GenerateSyncCode: return authenticationState;
            case SetupSyncingPopup.EnterSyncCode:
            case SetupSyncingPopup.ScanSyncCode: return pairingBaseState;
            default:
                return authenticationState;
            }
        }

//        DSM.SignalTransition {
//            targetState: syncingState
//            signal: d.syncingStarted
//        }

        DSM.State {
            id: authenticationState

            DSM.SignalTransition {
                targetState: displaySyncCodeState
                signal: nextButton.clicked
            }
        }

        DSM.State {
            id: displaySyncCodeState

            DSM.SignalTransition {
                targetState: authenticationState
                signal: previousButton.clicked
            }

            DSM.SignalTransition {
                targetState: finalState
                signal: nextButton.clicked
            }

            DSM.SignalTransition {
                targetState: syncingState
                signal: d.otherDeviceConnected
            }
        }

        DSM.State {
            id: pairingBaseState

            initialState: enterSyncCodeState

            DSM.State {
                id: enterSyncCodeState

                onEntered: {
                    d.pairingFailsCount = 0;
                }

                DSM.SignalTransition {
                    targetState: pairingInProgressState
                    signal: nextButton.clicked
                    guard: enterSyncCodeView.syncCodeValid
                }
            }

            DSM.State {
                id: pairingInProgressState // Pairing == searching for device with given SyncCode

                onEntered: {
                    d.startPairing(enterSyncCodeView.syncCode)
                }

                DSM.SignalTransition {
                    targetState: pairingFailedState
                    signal: d.pairingFailed
                }

                DSM.SignalTransition {
                    targetState: syncingState
                    signal: d.pairingSuccess
                }
            }

            DSM.State {
                id: pairingFailedState

                DSM.SignalTransition {
                    targetState: pairingInProgressState
                    signal: nextButton.clicked
                }

                DSM.SignalTransition {
                    targetState: enterSyncCodeState
                    signal: enterSyncCodeView.syncCodeChanged
                }
            }
        }

        DSM.State {
            id: syncingState

            onEntered: {
                d.startSyncing()
            }

            DSM.SignalTransition {
                targetState: syncingFailedState
                signal: d.syncingFailed
            }

            DSM.SignalTransition {
                targetState: syncingSuccessState
                signal: d.syncingSuccess
            }
        }

        DSM.State {
            id: syncingFailedState

            DSM.SignalTransition {
                targetState: syncingState
                signal: nextButton.clicked // Retry
            }

            DSM.SignalTransition {
                targetState: syncingState
                signal: nextButton.clicked // Retry
            }

        }

        DSM.State {
            id: syncingSuccessState

            DSM.SignalTransition {
                targetState: finalState
                signal: nextButton.clicked
            }
        }

        DSM.FinalState {
            id: finalState
            onEntered: root.close()
        }
    }

    leftButtons: [
        StatusRoundButton {
            id: previousButton
            visible: !stateMachine.initialState.active
            icon.name: "arrow-left"
        }

    ]

    rightButtons: [
        StatusButton {
            id: nextButton
            text: {
                if (authenticationState.active)
                    return qsTr("Generate Sync Code");
                if (displaySyncCodeState.active)
                    // TODO: This button is wierd.
                    //      I feel like I should press it to continue, while I just need to wait.
                    //      And the button will close the popup and stop the workflow
                    return qsTr("Close");
                if (syncingSuccessState.active)
                    return qsTr("Done");
                return qsTr("Sync");
            }
            enabled: {
                if (pairingBaseState.active)
                    return enterSyncCodeView.syncCodeValid && !enterSyncCodeView.pairingInProgress;
                return true;
            }
        }
    ]

    contentItem: Item {

        implicitWidth: Math.max(authenticationView.implicitWidth,
                                enterSyncCodeView.implicitWidth,
                                displaySyncCodeView.implicitWidth,
                                scanSyncCodeView.implicitWidth,
                                syncingView.implicitWidth)

        implicitHeight: Math.max(authenticationView.implicitHeight,
                                enterSyncCodeView.implicitHeight,
                                displaySyncCodeView.implicitHeight,
                                scanSyncCodeView.implicitHeight,
                                syncingView.implicitHeight)

        Views.Authentication {
            id: authenticationView
            anchors.fill: parent
            visible: authenticationState.active
        }

        Views.DisplaySyncCode {
            id: displaySyncCodeView
            anchors.fill: parent
            visible: displaySyncCodeState.active
        }

        Views.EnterSyncCode {
            id: enterSyncCodeView
            anchors.fill: parent
            visible: pairingBaseState.active && root.mode === SetupSyncingPopup.EnterSyncCode
            pairingInProgress: pairingInProgressState.active
            pairingFailed: pairingFailedState.active
            pairingFailsCount: d.pairingFailsCount
        }

        Views.ScanSyncCode {
            id: scanSyncCodeView
            anchors.fill: parent
            visible: pairingBaseState.active && root.mode === SetupSyncingPopup.ScanSyncCode
        }

        Views.Syncing {
            id: syncingView
            anchors.fill: parent
            visible: syncingState.active || syncingFailedState.active || syncingSuccessState.active
        }
    }
}
