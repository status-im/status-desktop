import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.status 1.0
import shared.stores 1.0

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ColumnLayout {
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            StatusInput {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Layout.margins: 16
                placeholderText: placeHolderInput.text
                enabled: enabledCheckBox.checked
                input.edit.readOnly: readOnlyCheckBox.checked
                input.clearable: clearableCheckBox.checked
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
         SplitView.minimumWidth: 300
         SplitView.preferredWidth: 300

         ColumnLayout {
             TextInput {
                 id: placeHolderInput
                 text: "Placeholder"
             }
             CheckBox {
                 id: enabledCheckBox
                 text: "enabled"
                 checked: true
             }
             CheckBox {
                 id: readOnlyCheckBox
                 text: "read only"
             }
             CheckBox {
                 id: clearableCheckBox
                 text: "clearable"
             }
         }
    }
}

// category: Components
