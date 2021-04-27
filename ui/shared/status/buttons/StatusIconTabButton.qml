import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../"
import "../core"
import "../"

TabButton {
    id: control

    property color iconColor: Style.current.secondaryText
    property color disabledColor: iconColor
    property string name: ""

    implicitWidth: 40
    implicitHeight: 40

    icon.height: 24
    icon.width: 24
    icon.color: {
        if (!enabled) {
            return control.disabledColor
        }
        return (hovered || checked) ? Style.current.blue : control.iconColor
    }

    contentItem: Item {
        anchors.fill: parent

        Loader {
            active: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: control.name !== "" && !icon.source.toString() ? letterIdenticon :
              !!icon.source.toString() ? imageIcon : defaultIcon
        }

        Component {
            id: defaultIcon
            StatusIcon {
                icon: control.icon.name
                height: control.icon.height
                width: control.icon.width
                color: control.icon.color
            }
        }

        Component {
            id: imageIcon
            RoundedImage {
                source: icon.source
                noMouseArea: true
            }
        }

        Component {
            id: letterIdenticon
            StatusLetterIdenticon {
                width: 26
                height: 26
                letterSize: 15
                chatName: control.name
                color: control.icon.color
            }
        }
    }

    background: Rectangle {
        color: hovered || ((!!icon.source.toString() || !!name) && checked) ? Style.current.tabButtonBg : "transparent"
        border.color: Style.current.primary
        border.width: (!!icon.source.toString() || !!name) && checked ? 1 : 0
        radius: control.width / 2
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
