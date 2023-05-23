import QtQuick 2.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root

    anchors.centerIn: parent

    headerSettings.title: "Cryptokitties"
    headerSettings.subTitle: "Public Community"
    headerSettings.asset.isImage: true
    headerSettings.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"

    contentItem: Column {
        width: root.width

        StatusModalDivider {
            bottomPadding: 8
        }

        StatusBaseText {
            text: "A community of cat lovers, meow!"
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            height: 46
            color: Theme.palette.directColor1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        StatusDescriptionListItem {
            title: "Share community"
            subTitle: "https://status.app/u/0x04...45f19"
            tooltip.text: "Copy to clipboard"
            asset.name: "copy"
            iconButton.onClicked: tooltip.visible = !tooltip.visible
            width: parent.width
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            statusListItemTitle.font.pixelSize: 17
            title: "Members"
            asset.name: "group-chat"
            label: "184"
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            statusListItemTitle.font.pixelSize: 17
            title: "Notifications"
            asset.name: "notification"
            components: [
                StatusSwitch {}
            ]
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            statusListItemTitle.font.pixelSize: 17
            title: "Edit community"
            asset.name: "edit"
            type: StatusListItem.Type.Secondary
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            statusListItemTitle.font.pixelSize: 17
            title: "Transfer ownership"
            asset.name: "exchange"
            type: StatusListItem.Type.Secondary
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            statusListItemTitle.font.pixelSize: 17
            title: "Leave community"
            asset.name: "arrow-left"
            type: StatusListItem.Type.Secondary
        }
    }
}
