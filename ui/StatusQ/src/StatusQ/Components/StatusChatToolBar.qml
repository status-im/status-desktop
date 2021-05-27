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
    property int notificationCount: 0

    signal chatInfoButtonClicked()
    signal menuButtonClicked()
    signal notificationButtonClicked()

    StatusChatInfoButton {
        id: statusChatInfoButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        onClicked: statusChatToolBar.chatInfoButtonClicked()
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        spacing: 8

        StatusFlatRoundButton {
            width: 32
            height: 32
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Secondary

            onClicked: statusChatToolBar.menuButtonClicked()
        }

        Rectangle {
            height: 24
            width: 1
            color: Theme.palette.directColor7
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusFlatRoundButton {
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

