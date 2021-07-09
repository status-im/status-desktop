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
    property alias membersButton: membersButton
    property alias searchButton: searchButton
    property int notificationCount: 0

    property Component popupMenu

    signal chatInfoButtonClicked()
    signal menuButtonClicked()
    signal notificationButtonClicked()
    signal membersButtonClicked()
    signal searchButtonClicked()

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
            id: searchButton
            width: 32
            height: 32
            icon.name: "search"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: statusChatToolBar.searchButtonClicked()
        }

        StatusFlatRoundButton {
            id: membersButton
            width: 32
            height: 32
            icon.name: "group-chat"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: statusChatToolBar.membersButtonClicked()
        }

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
                popupMenuSlot.item.popup(-popupMenuSlot.item.width + menuButton.width, menuButton.height + 4)
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

        Rectangle {
            height: 24
            width: 1
            color: Theme.palette.directColor7
            anchors.verticalCenter: parent.verticalCenter
            visible: notificationButton.visible &&
                (menuButton.visible || membersButton.visible || searchButton.visible)
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
}

