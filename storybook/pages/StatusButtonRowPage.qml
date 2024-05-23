import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import utils 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Horizontal

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor4
        }

        StatusButtonRow {
            id: buttonRow
            symbolValue: ctrlCustomSymbol.text
            anchors.centerIn: parent
            //currentValue: 1.42
        }
    }

    LogsAndControlsPanel {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Custom symbol:" }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlCustomSymbol
                    text: " %"
                }
            }
            Button {
                text: "Reset to default"
                onClicked: buttonRow.reset()
            }
            Label {
                Layout.fillWidth: true
                text: "Model: [%1]".arg(buttonRow.model)
            }
            Label {
                Layout.fillWidth: true
                text: "Default value: %1".arg(buttonRow.defaultValue)
            }
            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "Current value: %1".arg(buttonRow.currentValue)
            }
            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "Valid: %1".arg(buttonRow.valid ? "true" : "false")
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Controls

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3409-257346&t=ENK93cK7GyTqEV8S-0
// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3410-262441&t=ENK93cK7GyTqEV8S-0
