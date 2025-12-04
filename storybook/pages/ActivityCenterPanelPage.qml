import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.panels

import Storybook

import utils

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            ActivityCenterPanel {
                anchors.centerIn: parent
                width: slider.value
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
            Label {
                text: "Panel dynamic width:"
            }
            Slider {
                id: slider

                value: 200
                from: 200
                to: 500
            }
        }
    }
}

// category: Panels
// status: good
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1868-52013&m=dev
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1902-48455&m=dev
