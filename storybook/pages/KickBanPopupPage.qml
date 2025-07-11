import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import AppLayouts.Communities.popups


SplitView {
    Logs { id: logs }

    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Item {
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

        KickBanPopup {
            id: dialog

            mode: modesButtonGroup.checkedButton.mode
            username: usernameTextField.text
            communityName: communityNameTextField.text

            closePolicy: Popup.NoAutoClose
            visible: true
            modal: false
            destroyOnClose: false
            anchors.centerIn: parent

            onAccepted: logs.logEvent("KickBanPopup::accepted")
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 250

        logsView.logText: logs.logText

        ColumnLayout {
            ButtonGroup {
                id: modesButtonGroup

                buttons: modesRow.children
            }

            RowLayout {
                id: modesRow

                RadioButton {
                    readonly property int mode: KickBanPopup.Mode.Kick

                    text: "Kick"
                    checked: true
                }

                RadioButton {
                    readonly property int mode: KickBanPopup.Mode.Ban

                    text: "Ban"
                }
            }

            MenuSeparator {
                Layout.fillWidth: true
            }

            RowLayout {
                Label {
                    text: "Username:"
                }

                TextField {
                    id: usernameTextField

                    text: "John"
                }
            }

            RowLayout {
                Label {
                    text: "Community:"
                }

                TextField {
                    id: communityNameTextField

                    text: "CryptoKitties"
                }
            }
        }
    }
}

// category: Popups
