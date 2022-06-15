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

StatusModal {
    id: root

//    enum SyncInputMethod {
//        TextInput,
//        ScanQrCode
//    }

//    property int syncInputMethod: SyncNewDevicePopup.TextInput


    width: implicitWidth
    padding: 16

    header.title: qsTr("Sync a New Device")

    QtObject {
        id: d

        property int attemptsCount: 0
        property bool syncing: false

//        signal syncingStarted
        signal syncingFailed
        signal syncingFinished

    }

    DSM.StateMachine {
        id: stateMachine

        running: root.visible
        initialState: syncCodeInputState

//        DSM.SignalTransition {
//            targetState: syncingState
//            signal: d.syncingStarted
//        }

        DSM.State {
            id: syncCodeInputState

            DSM.SignalTransition {
                targetState: finalState
                signal: previousButton.clicked
            }

            DSM.SignalTransition {
                targetState: syncingState
                signal: nextButton.clicked
            }
        }

        DSM.State {
            id: syncingState

            onEntered: {
                tempTimer.start();
            }

            DSM.SignalTransition {
                targetState: syncCodeInputState
                signal: previousButton.clicked
            }

            DSM.SignalTransition {
                targetState: syncFailedState
                signal: d.syncingFailed
            }
        }

        DSM.State {
            id: syncFailedState

            property int failsCount: 0

            DSM.SignalTransition {
                targetState: syncCodeInputState
                signal: previousButton.clicked
            }

            DSM.SignalTransition {
                targetState: syncingState
                signal: nextButton.clicked
            }

            onEntered: failsCount++
        }

//        DSM.State {
//            id: deviceFoundState
//        }

        DSM.State {
            id: deviceSyncedState

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

    Timer {
        id: tempTimer
        interval: 1000
        onTriggered: {
            d.syncingFailed();
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
                if (deviceSyncedState.active)
                    return qsTr("Done");
                qsTr("Sync")
            }
            enabled: codeInput.text !== ""
        }
    ]

    contentItem: ColumnLayout {
        spacing: 40

        StatusInput {
            id: codeInput
            Layout.alignment: Qt.AlignHCenter
            label: qsTr("Paste sync code")
            input.placeholderText: qsTr("eg. %1").arg("0x2Ef19")
            input.font: Theme.palette.monoFont.name
            input.placeholderFont: input.font
            input.rightComponent: StatusButton {
                size: StatusBaseButton.Size.Tiny
                enabled: codeInput.input.edit.canPaste
                onClicked: codeInput.input.edit.paste()
                text: qsTr("Paste")
            }
        }

        StatusSyncingInstructions {
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 40
            implicitWidth: loadingLayout.implicitWidth
            implicitHeight: loadingLayout.implicitHeight

            ColumnLayout {
                id: loadingLayout

                anchors.fill: parent
                visible: syncFailedState.active
                width: parent.width

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    visible: syncFailedState.failsCount < 2

                    StatusBaseText {
                        text: qsTr("Hmm, that didn't work")
                        font.pixelSize: 17
                        color: Theme.palette.dangerColor1
                    }
                    StatusEmoji {
                        emojiId: Emoji.iconId("🤔")
                    }
                }

                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    visible: syncFailedState.failsCount >= 2
                    text: qsTr("That still didn’t work")
                    font.pixelSize: 17
                    color: Theme.palette.dangerColor1
                }

                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: syncFailedState.failsCount < 2 ? qsTr("Please try pasting the sync code again.")
                                                         : qsTr("Double check to make sure the code isn’t expired.")
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                }
            }

            StatusLoadingIndicator {
                anchors.centerIn: parent
                visible: syncingState.active
            }
        }
    }
}
