import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme

Item {
    id: root
    width: 800
    height: 100

    Column {
        anchors.fill: parent
        spacing: 30

        Grid {
            columns: 2
            rowSpacing: 20
            columnSpacing: 50

            Text {
                text: "Total steps:"
            }
            SpinBox {
                id: totalSteps
                editable: true
                height: 30
                from: 1
                value: 6
            }

            Text {
                text: "Completed steps:"
            }
            SpinBox {
                id: completedSteps
                editable: true
                height: 30
                from: 1
                to: totalSteps.value
                value: 1
            }
        }

        StatusStepper {
            id: stepper
            width: 400
            title: "Account %1 of %2".arg(completedSteps).arg(totalSteps)
            totalSteps: totalSteps.value
            completedSteps: completedSteps.value
        }
    }
}
