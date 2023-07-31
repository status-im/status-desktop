import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import Storybook 1.0

import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Rectangle {
        id: rect
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusBlockProgressBar {
            anchors.centerIn: parent
            width: 500
            height: 12
            steps: 64
            completedSteps: slider.value
            blockSet: 4
            error: failureCheckBox.checked
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
        Column {
            CheckBox {
                id: failureCheckBox
                text: "Failed"
                checked: false
            }
            Slider {
                id: slider
                value: 0
                from: 0
                to: 64
                stepSize: 1
                Text {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Confirmations = " + slider.value
                }
            }
            CheckBox {
                id: darkMode
                text: "Dark Mode"
                checked: false
                onCheckedChanged: rect.color = Theme.palette.getColor('graphite3')
            }
        }
    }
}

// category: Components
