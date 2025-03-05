import QtQuick 2.15
import QtQuick.Controls 2.15

import Qt.labs.settings 1.0

import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

import Storybook 1.0

Item {
    id: root

    Logs {
        id: logs
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical

        ConvertKeycardAccountPage {
            id: progressPage

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            convertKeycardAccountState: ctrlState.currentValue
            onRestartRequested: {
                logs.logEvent("restartRequested")
            }
            onBackToLoginRequested: {
                logs.logEvent("backToLoginRequested")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    ComboBox {
        id: ctrlState
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 300
        textRole: "name"
        valueRole: "value"
        model: Onboarding.getModelFromEnum("ProgressState")
    }

    Settings {
        property alias convertKeycardAccountPageState: ctrlState.currentIndex
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=221-23716&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=224-20891&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=221-23788&node-type=frame&m=dev
