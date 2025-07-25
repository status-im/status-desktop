import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme

import Storybook
import Models

import utils
import shared.status
import shared.stores

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
                label: "main label"
                secondaryLabel: "secondary label"
                labelIcon: "info"
                labelIconColor: Theme.palette.baseColor1
                labelIconClickable: true
                leftPadding: 10
                bottomLabelMessageRightCmp.text: "Current: 8.2 GWEI"
                bottomLabelMessageLeftCmp.text: "0.0031 ETH"
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
