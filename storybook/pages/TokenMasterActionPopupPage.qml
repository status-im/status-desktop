import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0


SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    ListModel {
        id: accountsModel

        ListElement {
            name: "Test account"
            emoji: "😋"
            address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            color: "red"
        }

        ListElement {
            name: "Another account - generated"
            emoji: "🚗"
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"
            color: "blue"
        }
    }

    Item {
        id: content

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: dialog.open()
        }

        TokenMasterActionPopup {
            id: dialog

            parent: content
            visible: true
            closePolicy: Popup.NoAutoClose
            anchors.centerIn: parent
            modal: false

            actionType: actionTypesRadioButtonGroup.checkedButton.actionType

            accountsModel: accountsModel
            communityName: "Doodles"
            userName: "simon"
            networkName: "Optimism"

            isFeeLoading: feeLoadingCheckBox.checked
            feeText: "0.0015 ETH ($75.43)"
            feeErrorText: feeErrorCheckBox.checked ? "Some fee error" : ""

            onRemotelyDestructClicked: logs.logEvent("onRemotelyDestructClicked")
            onBanClicked: logs.logEvent("onBanClicked")
            onKickClicked: logs.logEvent("onKickClicked")
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        ColumnLayout {
            RowLayout {
                CheckBox {
                    id: feeLoadingCheckBox

                    text: "Loading fee"
                }

                CheckBox {
                    id: feeErrorCheckBox

                    text: "Fee error"
                }
            }

            ButtonGroup {
                id: actionTypesRadioButtonGroup

                buttons: actionTypesRow.children
            }

            RowLayout {
                id: actionTypesRow

                RadioButton {
                    id: remotelyDestructRadioButton

                    readonly property int actionType:
                        TokenMasterActionPopup.ActionType.RemotelyDestruct

                    text: "Remotely destruct"
                    checked: true
                }

                RadioButton {
                    id: kickRadioButton

                    readonly property int actionType:
                        TokenMasterActionPopup.ActionType.Kick

                    text: "Kick"
                }

                RadioButton {
                    id: banRadioButton

                    readonly property int actionType:
                        TokenMasterActionPopup.ActionType.Ban

                    text: "Ban"
                }
            }
        }
    }

    Settings {
        property alias remotelyDestructRadioButtonChecked: remotelyDestructRadioButton.checked
        property alias kickRadioButtonChecked: kickRadioButton.checked
        property alias banRadioButtonChecked: banRadioButton.checked
    }
}

// category: Popups
