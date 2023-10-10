import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0


SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        TestRunnerControls {
            mode: radioButtonsGroup.checkedButton.mode

            numberOfFailedTests: 42

            anchors.centerIn: parent

            onRunClicked: logs.logEvent("Run clicked")
            onAbortClicked: logs.logEvent("Abort clicked")
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        SplitView.fillWidth: true

        logsView.logText: logs.logText

        ButtonGroup {
            id: radioButtonsGroup

            buttons: radioButtonsRow.children
        }

        RowLayout {
            id: radioButtonsRow

            RadioButton {
                readonly property int mode: TestRunnerControls.Mode.Base

                text: "Base"
            }

            RadioButton {
                readonly property int mode: TestRunnerControls.Mode.InProgress

                text: "In progress"

                checked: true
            }

            RadioButton {
                readonly property int mode: TestRunnerControls.Mode.Failed

                text: "Failed"
            }

            RadioButton {
                readonly property int mode: TestRunnerControls.Mode.Success

                text: "Success"
            }

            RadioButton {
                readonly property int mode: TestRunnerControls.Mode.Aborted

                text: "Aborted"
            }

            RadioButton {
                readonly property int mode: TestRunnerControls.Mode.Crashed

                text: "Crashed"
            }
        }
    }
}

// category: Controls
