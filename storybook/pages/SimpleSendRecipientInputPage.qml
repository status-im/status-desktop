import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import Storybook 1.0

SplitView {
    id: root

    SplitView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        orientation: Qt.Vertical

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            SendRecipientInput {
                width: 500
                anchors.centerIn: parent

                height: visible ? implicitHeight: 0

                interactive: interactiveCheckbox.checked
                checkMarkVisible: checkmarkCheckbox.checked
                // Loading indicator only shows for non-empty fields
                loading: loadingCheckbox.checked
                input.edit.textFormat: Text.AutoText
                error: errorCheckbox.checked ? "Some error text" : ""

                onClearClicked: logs.logEvent("Clear clicked")
                onValidateInputRequested: logs.logEvent("Validate input requested")
                Keys.onPressed: (event) => logs.logEvent("Key pressed: " + event.key)
            }
        }

        Logs {
            id: logs
        }

        LogsView {
            clip: true

            SplitView.preferredHeight: 150
            SplitView.fillWidth: true

            logText: logs.logText
        }
    }

    Pane {
        SplitView.preferredWidth: 300

        ColumnLayout {
            CheckBox {
                id: interactiveCheckbox
                text: "Interactive"
                checked: true
            }

            CheckBox {
                id: errorCheckbox
                text: "Error"
            }

            CheckBox {
                id: loadingCheckbox
                text: "Loading"
            }

            CheckBox {
                id: checkmarkCheckbox
                text: "Checkmark"
            }
        }
    }
}

// category: Controls
