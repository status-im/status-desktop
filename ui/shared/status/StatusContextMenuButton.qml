import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.14
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

RoundButton {
    id: control
    implicitWidth: 32
    implicitHeight: 32
    contentItem: Item {
        anchors.fill: parent

        SVGImage {
            id: iconImg
            source: "/../../app/img/dots-icon.svg"
            width: 18
            height: 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        ColorOverlay {
            id: iconColorOverlay
            anchors.fill: iconImg
            source: iconImg
            color: Style.current.contextMenuButtonForegroundColor
            antialiasing: true
        }
    }
    background: Rectangle {
        radius: Style.current.radius
        color: hovered ? Style.current.contextMenuButtonBackgroundHoverColor : Style.current.transparent
    }

    MouseArea {
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
