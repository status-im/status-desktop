import QtQuick 2.13

import QtQuick.Controls 2.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Control {
    id: root

    implicitWidth: visible ? 288 : 0
    implicitHeight: visible ? 28 : 0

    leftPadding: 8
    rightPadding: 8

    property string text
    property bool opened: true
    property bool highlighted: false
    property bool showActionButtons: false
    property bool showMenuButton: showActionButtons
    property bool showAddButton: showActionButtons
    property bool hasUnreadMessages: false
    property alias addButton: addButton
    property alias menuButton: menuButton
    property alias toggleButton: toggleButton

    signal clicked(var mouse)
    signal addButtonClicked(var mouse)
    signal menuButtonClicked(var mouse)
    signal toggleButtonClicked(var mouse)

    background: Rectangle {
        HoverHandler {
            id: hoverHandler
        }
        color: (hoverHandler.hovered || root.highlighted) ? Theme.palette.baseColor2 : "transparent"
        radius: 8
    }

    contentItem: Item {
        StatusBaseText {
            width: Math.min(implicitWidth, parent.width)
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Medium
            font.pixelSize: 15
            elide: Text.ElideRight
            color: Theme.palette.directColor4
            text: root.text
        }
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            StatusChatListCategoryItemButton {
                id: addButton
                icon.name: "add"
                icon.width: 20
                visible: (root.showAddButton && (hoverHandler.hovered || root.highlighted))
                onClicked: root.addButtonClicked(mouse)
                tooltip.text: qsTr("Add channel inside category")
            }
            StatusChatListCategoryItemButton {
                id: menuButton
                icon.name: "more"
                icon.width: 21
                visible: (root.showMenuButton && (hoverHandler.hovered || root.highlighted))
                onClicked: root.menuButtonClicked(mouse)
                tooltip.text: qsTr("More")
            }
            StatusChatListCategoryItemButton {
                id: toggleButton
                icon.name: "chevron-down"
                icon.width: 18
                icon.rotation: root.opened ? 0 : 270
                onClicked: root.toggleButtonClicked(mouse)
            }
        }
    }
}

