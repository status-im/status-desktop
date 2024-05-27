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

        SlippageSelector {
            id: slippageSelector
            anchors.centerIn: parent
        }
    }

    LogsAndControlsPanel {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "Value: %1".arg(slippageSelector.value)
            }
            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "Valid: %1".arg(slippageSelector.valid ? "true" : "false")
            }

            ColumnLayout {
                Repeater {
                    model: [0.1, 0.5, 0.24, 0.8, 120.84]

                    Button {
                        text: "set " + modelData
                        onClicked: slippageSelector.value = modelData
                    }
                }
            }

            Button {
                text: "Reset defaults"
                onClicked: slippageSelector.reset()
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Controls

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3409-257346&t=ENK93cK7GyTqEV8S-0
// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3410-262441&t=ENK93cK7GyTqEV8S-0
