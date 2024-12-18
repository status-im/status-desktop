import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            width: switchControl.width
            height: switchControl.height
            anchors.centerIn: parent
            color: "transparent"
            border.width: 1
            border.color: "pink"

            StatusSwitch {
                id: switchControl
                anchors.centerIn: parent
                text: ctrlWithText.checked ? "Check me out" : ""
                leftSide: !ctrlInverted.checked
                checked: true
                enabled: ctrlEnabled.checked
                onClicked: logs.logEvent("clicked()")
                onToggled: logs.logEvent("toggled()")
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 200
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Layout.fillWidth: true

            Switch {
                id: ctrlEnabled
                text: "Enabled"
                checked: true
            }
            Switch {
                id: ctrlInverted
                text: "Inverted"
            }
            Switch {
                id: ctrlWithText
                text: "With text"
                checked: true
            }
        }
    }
}

// category: Controls
// status: good
