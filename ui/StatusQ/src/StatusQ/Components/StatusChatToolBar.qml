import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusChatToolBar
    implicitWidth: 518
    height: 56
    color: Theme.palette.statusAppLayout.backgroundColor

    property alias chatInfoButton: statusChatInfoButton
    property alias menuButton: menuButton
    property alias notificationButton: notificationButton
    property int notificationCount: 0

    property Component popupMenu

    signal chatInfoButtonClicked()
    signal menuButtonClicked()
    signal notificationButtonClicked()

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    StatusChatInfoButton {
        id: statusChatInfoButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        onClicked: statusChatToolBar.chatInfoButtonClicked()
    }

    Row {
        id: actionButtons
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        spacing: 8

        StatusFlatRoundButton {
            id: menuButton
            width: 32
            height: 32
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Secondary
            visible: !!statusChatToolBar.popupMenu

            onClicked: {
                statusChatToolBar.menuButtonClicked()
                highlighted = true
                let p = menuButton.mapToItem(statusChatToolBar, menuButton.x, menuButton.y)
                popupMenuSlot.item.popup(p.x + menuButton.width - popupMenuSlot.item.width, p.y + 4 + menuButton.height)
            }
        }

        Rectangle {
            height: 24
            width: 1
            color: Theme.palette.directColor7
            anchors.verticalCenter: parent.verticalCenter
            visible: menuButton.visible && notificationButton.visible
        }

        StatusFlatRoundButton {
            id: notificationButton
            width: 32
            height: 32

            icon.name: "notification"
            icon.height: 21
            type: StatusFlatRoundButton.Type.Secondary

            onClicked: statusChatToolBar.notificationButtonClicked()

            StatusBadge {
                id: statusBadge

                visible: value > 0
                anchors.top: parent.top
                anchors.left: parent.right
                anchors.topMargin: -3
                anchors.leftMargin: {
                    if (statusBadge.value > 99) {
                        return -22
                    }
                    if (statusBadge.value > 9) {
                        return -21
                    }
                    return -18
                }

                value: statusChatToolBar.notificationCount
                border.width: 2
                border.color: parent.hovered ? Theme.palette.baseColor2 : Theme.palette.statusAppLayout.backgroundColor
            }
        }

    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatToolBar.popupMenu
        onLoaded: {
            popupMenuSlot.item.closeHandler = function () {
                menuButton.highlighted = false
            }
        }
    }
}

