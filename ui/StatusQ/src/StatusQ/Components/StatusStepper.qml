import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

/*!
   \qmltype StatusStepper
   \inherits Item
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief Displays total number of steps which need to be passed, marking each completed step
          based on `completedSteps` property

   Example:

   \qml
    StatusStepper {
        width: 400
        title: "Account %1 of %2".arg(completedSteps).arg(totalSteps)
        totalSteps: 6
        completedSteps: 1
    }
   \endqml

   \image status_stepper.png

   For a list of components available see StatusQ.
*/

Item {
    id: root

    property alias title: title.text
    property int titleFontSize: Theme.tertiaryTextFontSize
    property color titleColor: Theme.palette.baseColor1
    property int totalSteps: 1
    property int completedSteps: 1
    property color completedStepColor: Theme.palette.primaryColor1
    property color uncompletedStepColor: Theme.palette.baseColor2
    property int leftPadding: 24
    property int rightPadding: 24

    implicitHeight: 52

    QtObject {
        id: d

        readonly property int stepHeight: 4
        readonly property int stepRadius: 4
        readonly property int spaceBetweenSteps: 2
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: root.leftPadding
        anchors.rightMargin: root.rightPadding
        spacing: 8

        StatusBaseText {
            id: title
            width: parent.width
            horizontalAlignment: Qt.AlignHCenter
            color: root.titleColor
            font.pixelSize: root.titleFontSize
        }

        Row {
            width: parent.width
            spacing: d.spaceBetweenSteps

            Repeater {
                id: repeater
                model: root.totalSteps

                delegate: Rectangle {
                    readonly property int stepIndex: index
                    width: (parent.width - (root.totalSteps - 1) * d.spaceBetweenSteps) / root.totalSteps
                    height: d.stepHeight
                    radius: d.stepRadius
                    color: stepIndex < root.completedSteps? root.completedStepColor : root.uncompletedStepColor
                }
            }
        }
    }
}
