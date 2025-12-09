import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 50

        spacing: 30

        Grid {
            columns: 2
            rowSpacing: 20
            columnSpacing: 50

            Text {
                text: "Total steps:"
            }
            SpinBox {
                id: ctrlTotalSteps
                editable: true
                height: 30
                from: 1
                value: 6
            }

            Text {
                text: "Completed steps:"
            }
            SpinBox {
                id: ctrlCompletedSteps
                editable: true
                height: 30
                from: 1
                to: ctrlTotalSteps.value
                value: 1
            }
        }

        StatusStepper {
            id: stepper

            Layout.fillWidth: true
            title: "Account %1 of %2".arg(completedSteps).arg(totalSteps)
            totalSteps: ctrlTotalSteps.value
            completedSteps: ctrlCompletedSteps.value

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "lightgray"
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

// category: Components
// status: good
