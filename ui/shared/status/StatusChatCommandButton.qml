import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Button {
    id: control
    property int iconRotation: 0
    implicitWidth: 168
    implicitHeight: 95
    icon.width: 12
    icon.height: 12

    onIconChanged: {
        icon.source = icon.name ? "../../app/img/" + icon.name + ".svg" : ""
    }

    contentItem: Item {
        anchors.fill: parent
        Rectangle {
            radius: 50
            width: 40
            height: 40
            color: control.icon.color
            anchors.top: parent.top
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding

            SVGImage {
                id: iconImage
                source: control.icon.source
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: control.icon.width
                height: control.icon.height
                fillMode: Image.PreserveAspectFit
                rotation: control.iconRotation
                antialiasing: true
            }

            ColorOverlay {
                anchors.fill: iconImage
                source: iconImage
                color: Style.current.white
                rotation: control.iconRotation
                antialiasing: true
            }
        }
        StyledText {
            text: control.text
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: 13
        }
    }
    background: Rectangle {
        radius: 16
        color: Utils.setColorAlpha(icon.color, 0.2)
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
