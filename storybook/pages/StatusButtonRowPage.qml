import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils

import Storybook

SplitView {
    orientation: Qt.Horizontal

    Logs { id: logs }

    QtObject {
        id: d
        readonly property var values: [0.1, 0.5, 0.7, 1] // predefined values
    }

    ListModel {
        id: valuesModel
    }

    Component.onCompleted: {
        valuesModel.append(d.values.map(i => ({ text: "%L1".arg(i), value: i })))
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusButtonRow {
            id: buttonRow
            anchors.centerIn: parent
            model: valuesModel
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
                text: "Raw model: %1".arg(d.values)
            }

            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "Value: %1".arg(buttonRow.value)
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Controls

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3409-257346&t=ENK93cK7GyTqEV8S-0
// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3410-262441&t=ENK93cK7GyTqEV8S-0
