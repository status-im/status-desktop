import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"
import "../../shared/status"

TabButton {
    id: control
    width: 40
    height: 40
    property color iconColor: Style.current.secondaryText
    property color disabledColor: iconColor
    property int iconRotation: 0

    icon.height: 24
    icon.width: 24
    icon.color: {
        if (!enabled) {
            return control.disabledColor
        }
        return (hovered || checked) ? Style.current.blue : control.iconColor
    }

    onIconChanged: {
        icon.source = icon.name ? "../../app/img/" + icon.name + ".svg" : ""
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
            anchors.fill: iconImg
            source: iconImg
            color: control.icon.color
            antialiasing: true
            smooth: true
            rotation: control.iconRotation
        }

    }
    background: Rectangle {
        color: hovered || checked ? Style.current.secondaryBackground : "transparent"
        radius: control.width / 2
    }
}
