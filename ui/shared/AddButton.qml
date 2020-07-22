import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../imports"

Rectangle {
    signal clicked
    property int iconWidth: 14
    property int iconHeight: 14
    property alias icon: imgIcon
    property bool clickable: true

    id: btnAddContainer
    width: 36
    height: 36
    color: Style.current.blue
    radius: width / 2
    

    Image {
        id: imgIcon
        fillMode: Image.PreserveAspectFit
        source: "../app/img/plusSign.svg"
        width: iconWidth
        height: iconHeight
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        state: "default"
        rotation: 0
        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: imgIcon
                    rotation: 0
                }
            },
            State {
                name: "rotated"
                PropertyChanges {
                    target: imgIcon
                    rotation: 45
                }
            }
        ]

        transitions: [
            Transition {
                from: "default"
                to: "rotated"
                RotationAnimation {
                    duration: 150
                    direction: RotationAnimation.Clockwise
                    easing.type: Easing.InCubic
                }
            },
            Transition {
                from: "rotated"
                to: "default"
                RotationAnimation {
                    duration: 150
                    direction: RotationAnimation.Counterclockwise
                    easing.type: Easing.OutCubic
                }
            }
        ]
    }

    MouseArea {
        id: mouseArea
        visible: btnAddContainer.clickable
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            imgIcon.state = "rotated"
            btnAddContainer.clicked()
        }
    }
}
