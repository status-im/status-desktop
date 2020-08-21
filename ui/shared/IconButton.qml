import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../imports"

RoundButton {
    property int iconWidth: 14
    property int iconHeight: 14
    property alias iconImg: imgIcon
    property bool clickable: true
    property string iconName: "plusSign"
    property color color: Style.current.blue

    icon.width: iconWidth
    icon.height: iconHeight

    id: btnAddContainer
    width: 36
    height: 36
    radius: width / 2

    background: Rectangle {
      color: parent.color
      radius: parent.radius
    }

    Image {
        id: imgIcon
        fillMode: Image.PreserveAspectFit
        source: "../app/img/" + parent.iconName + ".svg"
        width: btnAddContainer.iconWidth
        height: btnAddContainer.iconHeight
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

    onClicked: {
        if (btnAddContainer.clickable) {
            imgIcon.state = "rotated"
        }
    }

    MouseArea {
        id: mouseArea
        visible: btnAddContainer.clickable
        anchors.fill: parent
        onPressed:  mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }
}

