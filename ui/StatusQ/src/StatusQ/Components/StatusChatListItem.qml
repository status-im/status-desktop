import QtQuick 2.13
import QtQml.Models 2.13
import QtQuick.Controls 2.13 as QC
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusChatListItem

    objectName: "chatItem"
    property int originalOrder: -1
    property string chatId: ""
    property string categoryId: ""
    property string name: ""
    property alias badge: statusBadge
    property bool hasUnreadMessages: false
    property int notificationsCount: 0
    property bool muted: false
    property StatusImageSettings image: StatusImageSettings {
        width: 24
        height: 24
    }
    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
        color: Theme.palette.miscColor5
        letterSize: emoji ? 11 : 15
        emoji: ""
        emojiSize: Emoji.size.verySmall
        charactersLen: 1
    }
    property int type: StatusChatListItem.Type.PublicChat
    property bool highlighted: false
    property bool highlightWhenCreated: false
    property bool selected: false
    property bool dragged: false
    property alias sensor: sensor

    signal clicked(var mouse)
    signal unmute()

    enum Type {
        Unknown0, // 0
        OneToOneChat, // 1
        PublicChat, // 2
        GroupChat, // 3
        Unknown1, // 4
        Unknown2, // 5
        CommunityChat // 6
    }

    implicitWidth: 288
    implicitHeight: 40

    radius: 8

    color: {
        if (selected) {
            return Theme.palette.statusChatListItem.selectedBackgroundColor
        }
        return hoverHander.hovered || highlighted ? Theme.palette.statusChatListItem.hoverBackgroundColor : Theme.palette.baseColor4
    }

    opacity: dragged ? 0.7 : 1

    MouseArea {
        id: sensor

        HoverHandler {
            id: hoverHander
        }

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: statusChatListItem.clicked(mouse)

        StatusSmartIdenticon {
            id: identicon
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            image: statusChatListItem.image
            icon: statusChatListItem.icon
            name: statusChatListItem.name
        }

        StatusIcon {
            id: statusIcon
            anchors.left: identicon.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            width: 14
            visible: statusChatListItem.type !== StatusChatListItem.Type.OneToOneChat
            opacity: {
                if (statusChatListItem.muted && !hoverHander.hovered && !statusChatListItem.highlighted) {
                    return 0.4
                }
                return statusChatListItem.hasUnreadMessages ||
                        statusChatListItem.notificationsCount > 0 ||
                        statusChatListItem.selected ||
                        statusChatListItem.highlighted ||
                        statusBadge.visible ||
                        hoverHander.hovered ? 1.0 : 0.7
            }

            icon: {
                switch (statusChatListItem.type) {
                case StatusChatListItem.Type.PublicCat:
                    return Theme.palette.name == "light" ? "tiny/public-chat" : "tiny/public-chat-white"
                    break;
                case StatusChatListItem.Type.GroupChat:
                    return Theme.palette.name == "light" ? "tiny/group" : "tiny/group-white"
                    break;
                case StatusChatListItem.Type.CommunityChat:
                    return Theme.palette.name == "light" ? "tiny/channel" : "tiny/channel-white"
                    break;
                default:
                    return Theme.palette.name == "light" ? "tiny/public-chat" : "tiny/public-chat-white"
                }
            }
        }

        StatusBaseText {
            id: chatName
            anchors.left: statusIcon.visible ? statusIcon.right : identicon.right
            anchors.leftMargin: statusIcon.visible ? 1 : 8
            anchors.right: mutedIcon.visible ? mutedIcon.left :
                                               statusBadge.visible ? statusBadge.left : parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter

            text: (statusChatListItem.type === StatusChatListItem.Type.PublicChat &&
                  !statusChatListItem.name.startsWith("#") ?
                      "#" + statusChatListItem.name :
                      statusChatListItem.name)
            elide: Text.ElideRight
            color: {
                if (statusChatListItem.muted && !hoverHander.hovered && !statusChatListItem.highlighted) {
                    return Theme.palette.directColor5
                }
                return statusChatListItem.hasUnreadMessages ||
                        statusChatListItem.notificationsCount > 0 ||
                        statusChatListItem.selected ||
                        statusChatListItem.highlighted ||
                        statusChatListItem.highlightWhenCreated ||
                        hoverHander.hovered ||
                        statusBadge.visible ? Theme.palette.directColor1 : Theme.palette.directColor4
            }
            font.weight: !statusChatListItem.muted &&
                         (statusChatListItem.hasUnreadMessages ||
                          statusChatListItem.notificationsCount > 0 ||
                          statusChatListItem.highlightWhenCreated ||
                          statusBadge.visible) ? Font.Bold : Font.Medium
            font.pixelSize: 15
        }

        StatusIcon {
            id: mutedIcon
            anchors.right: statusBadge.visible ? statusBadge.left : parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            opacity: mutedIconSensor.containsMouse ? 1.0 : 0.2
            icon: Theme.palette.name === "light" ? "tiny/muted" : "tiny/muted-white"
            visible: statusChatListItem.muted

            MouseArea {
                id: mutedIconSensor
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: statusChatListItem.unmute()
            }

            StatusToolTip {
                text: "Unmute"
                visible: mutedIconSensor.containsMouse
            }
        }

        StatusBadge {
            id: statusBadge

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8

            color: statusChatListItem.muted ? Theme.palette.primaryColor2 : Theme.palette.primaryColor1
            border.width: 4
            border.color: color
            value: statusChatListItem.notificationsCount
            visible: statusChatListItem.notificationsCount > 0
        }
    }
}
