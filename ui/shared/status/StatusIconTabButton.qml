import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../shared"
import "../../shared/panels"
import "../../shared/status"

TabButton {
    id: control
    visible: enabled
    width: Style.dp(40)
    height: enabled ? Style.dp(40) : 0
    anchors.horizontalCenter: parent.horizontalCenter
    property color iconColor: Style.current.secondaryText
    property color disabledColor: iconColor
    property int iconRotation: 0
    property string iconSource
    property string section
    property bool doNotHandleClick: false
    property bool borderOnChecked: false
    property bool useLetterIdenticon: false
    property string name: ""

    onClicked: {
        if (doNotHandleClick) {
            return
        }

        // Not Refactored Yet
//        chatsModel.communities.activeCommunity.active = false
        Global.changeAppSectionBySectionType(section)
    }

    icon.height: Style.dp(24)
    icon.width: Style.dp(24)
    icon.color: {
        if (!enabled) {
            return control.disabledColor
        }
        return (hovered || checked) ? Style.current.blue : control.iconColor
    }

    onIconChanged: {
        if (iconSource) {
            icon.source = iconSource
            return
        }

        icon.source = icon.name ? Style.svg(icon.name) : ""
    }

    contentItem: Item {
        anchors.fill: parent

        Loader {
            active: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: useLetterIdenticon ? letterIdenticon :
              !!iconSource ? imageIcon : defaultIcon
        }

        Component {
            id: defaultIcon
            SVGImage {
                id: iconImg
                source: control.icon.source
                height: control.icon.height
                width: control.icon.width
                fillMode: Image.PreserveAspectFit
                rotation: control.iconRotation
                ColorOverlay {
                    anchors.fill: iconImg
                    source: iconImg
                    color: control.icon.color
                    antialiasing: true
                    smooth: true
                }
            }
        }

        Component {
            id: imageIcon
            RoundedImage {
                source: iconSource
                noMouseArea: true
            }
        }

        Component {
            id: letterIdenticon
            StatusLetterIdenticon {
                width: Style.dp(26)
                height: Style.dp(26)
                letterSize: Style.current.primaryTextFontSize
                chatName: control.name
                color: control.iconColor
            }
        }
    }

    background: Rectangle {
        color: hovered || (borderOnChecked && checked) ? Style.current.tabButtonBg : "transparent"
        border.color: Style.current.primary
        border.width: borderOnChecked && checked ? 1 : 0
        radius: control.width / 2
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
