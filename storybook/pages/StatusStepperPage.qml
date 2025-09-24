import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme

Item {
    id: root

    Column {
        anchors.centerIn: parent
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
            width: 400
            title: "Account %1 of %2".arg(completedSteps).arg(totalSteps)
            totalSteps: ctrlTotalSteps.value
            completedSteps: ctrlCompletedSteps.value
        }
    }
}

// category: Components
// status: good
