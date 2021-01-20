import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

RoundButton {
    id: control

    property string type: "primary"
    property color iconColor: Style.current.secondaryText
    property color highlightedIconColor: Style.current.blue
    property color hoveredIconColor: Style.current.blue
    property color highlightedBackgroundColor: Style.current.secondaryBackground
    property real highlightedBackgroundOpacity: 1.0
    property color disabledColor: iconColor
    property int iconRotation: 0

    implicitHeight: 32
    implicitWidth: 32

    icon.height: 20
    icon.width: 20
    icon.color: {
        if (!enabled) {
            return control.disabledColor
        }

        if (hovered) {
            return control.hoveredIconColor
        }

        if (highlighted) {
            return control.highlightedIconColor
        }
        return control.iconColor
    }
    radius: Style.current.radius

    onIconChanged: {
        icon.source = icon.name ? "../../app/img/" + icon.name + ".svg" : ""
    }

    background: Rectangle {
        anchors.fill: parent
        opacity: control.highlightedBackgroundOpacity
        color: {
            if (type === "secondary") {
                return "transparent"
            }
            return hovered || highlighted ? control.highlightedBackgroundColor : "transparent"
        }
        radius: control.radius
    }

    contentItem: Item {
        anchors.fill: parent

        SVGImage {
            id: iconImg
            visible: false
            source: control.icon.source
            height: control.icon.height
            width: control.icon.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            rotation: control.iconRotation
        }
        ColorOverlay {
            visible: control.visible
            anchors.fill: iconImg
            source: iconImg
            color: control.icon.color
            antialiasing: true
            smooth: true
            rotation: control.iconRotation
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
