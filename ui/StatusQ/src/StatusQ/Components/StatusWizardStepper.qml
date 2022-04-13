import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusWizardStepper
   \inherits Item
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief Displays a step sequence provided by the stepsModel. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-item.html}{Item}.

   The \c StatusWizardStepper steps and their descriptions as provided by the stepsModel.
   For example:

   \qml
    StatusWizardStepper {
        id: wizardStepper
        stepsModel: ListModel {
            ListElement {description:"Send Request"; loadingTime: 0; stepCompleted: false}
            ListElement {description:"Receive Response"; loadingTime: 0; stepCompleted: false}
            ListElement {description:"Confirm Identity"; loadingTime: 0; stepCompleted: false}
        }
    }
   \endqml

   \image status_wizard_stepper.png

   For a list of components available see StatusQ.
*/

Item {
    property int maxDuration: 2000

    id: wizardWrapper
    width: parent.width
    height: 56
    /*!
       \qmlproperty ListModel StatusWizardStepper::stepsModel
        This property represents all steps and their descriptions as provided by the user.
    */
    property ListModel stepsModel: ListModel { }

    ListView {
        id: repeat
        width: childrenRect.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        orientation: ListView.Horizontal
        model: stepsModel
        delegate: Item {
            id: wrapperItem
            width: (index === 0) ? descriptionLabel.contentWidth : (wizardWrapper.width / repeat.count)
            height: 56
            onXChanged: {
                //as x changes while delegates are created, direct assignment doesn't work
                x = (index === (repeat.count-1)) ? (width+32) : (label.width/2) + 8
            }
            StatusProgressBar {
                id: barBorder
                width: visible ? (parent.width - (label.width/2 + 24)) : 0
                height: visible ? 8 : 0
                visible: (index > 0)
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -12
                from: 0
                to: wizardWrapper.maxDuration
                value: loadingTime
                backgroundColor: "transparent"
                backgroundBorderColor: Theme.palette.primaryColor1
                fillColor: Theme.palette.primaryColor1
            }
            Item {
                id: label
                width: descriptionLabel.contentWidth
                height: 56
                anchors.left: (index > 0) ? barBorder.right : parent.left
                anchors.leftMargin: (index > 0) ? -((width/2) - 24) : 0
                Rectangle {
                    width: 32
                    height: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: width/2
                    color: stepCompleted ? Theme.palette.primaryColor1 : "transparent"
                    border.color: (stepCompleted && (barBorder.visible ? (barBorder.value === barBorder.to) : true))
                                  ? "transparent" : Theme.palette.primaryColor1
                    border.width: 2
                    StatusBaseText {
                        anchors.centerIn: parent
                        text: index+1
                        font.pixelSize: 17
                        color: (stepCompleted && (barBorder.visible ? (barBorder.value === barBorder.to) : true))
                               ? Theme.palette.indirectColor1 : Theme.palette.primaryColor1
                    }
                }
                StatusBaseText {
                    id: descriptionLabel
                    anchors.bottom: parent.bottom
                    text: description
                    color: Theme.palette.directColor1
                    font.pixelSize: 13
                }
            }
        }
    }
}
