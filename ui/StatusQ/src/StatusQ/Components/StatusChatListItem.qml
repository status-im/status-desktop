import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusChatListItem

    property string chatId: ""
    property string name: ""
    property alias badge: statusBadge
    property bool hasUnreadMessages: false
    property bool hasMention: false
    property bool muted: false
    property StatusImageSettings image: StatusImageSettings {}
    property StatusIconSettings icon: StatusIconSettings {
        color: Theme.palette.miscColor5
    }
    property int type: StatusChatListItem.Type.PublicChat
    property bool selected: false

    signal clicked(var mouse)
    signal unmute()

    enum Type {
        PublicChat,
        GroupChat,
        CommunityChat,
        OneToOneChat
    }

    implicitWidth: 287
    implicitHeight: 40

    radius: 8

    color: {
        if (selected) {
            return Theme.palette.statusChatListItem.selectedBackgroundColor
        }
        return sensor.containsMouse ? Theme.palette.statusChatListItem.hoverBackgroundColor : Theme.palette.baseColor4
    }

    MouseArea {
        id: sensor

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor 
        hoverEnabled: true

        onClicked: statusChatListItem.clicked(mouse)

        Loader {
            id: identicon
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            sourceComponent: !!statusChatListItem.image.source.toString() ?
                statusRoundedImageCmp : statusLetterIdenticonCmp
        }

        Component {
            id: statusLetterIdenticonCmp
            StatusLetterIdenticon {
                height: 24
                width: 24
                name: statusChatListItem.name
                letterSize: 15
                color: statusChatListItem.icon.color
            }
        }

        Component {
            id: statusRoundedImageCmp
            Item {
                height: 24
                width: 24
                StatusRoundedImage {
                    id: statusRoundedImage
                    width: parent.width
                    height: parent.height
                    image.source: statusChatListItem.image.source
                    showLoadingIndicator: true
                }

                Loader {
                    sourceComponent: statusLetterIdenticonCmp
                    active: statusRoundedImage.image.status === Image.Error
                }
            }
        }

        StatusIcon {
            id: statusIcon
            anchors.left: identicon.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            width: 14
            visible: statusChatListItem.type !== StatusChatListItem.Type.OneToOneChat
            opacity: {
                if (statusChatListItem.muted && !sensor.containsMouse) {
                    return 0.4
                }
                return statusChatListItem.hasMention || 
                  statusChatListItem.hasUnreadMessages || 
                  statusChatListItem.selected ||
                  statusBadge.visible ||
                  sensor.containsMouse ? 1.0 : 0.7
            }

            icon: {
                switch (statusChatListItem.type) {
                    case StatusChatListItem.Type.PublicCat:
                        return Theme.palette.name == "light" ? "public-chat" : "public-chat-white"
                        break;
                    case StatusChatListItem.Type.GroupChat:
                        return Theme.palette.name == "light" ? "group" : "group-white"
                        break;
                    case StatusChatListItem.Type.CommunityChat:
                        return Theme.palette.name == "light" ? "channel" : "channel-white"
                        break;
                    default:
                        return Theme.palette.name == "light" ? "public-chat" : "public-chat-white"
                }
            }
        }

        StatusBaseText {
            id: chatName
            anchors.left: statusIcon.visible ? statusIcon.right : identicon.right
            anchors.leftMargin: statusIcon.visible ? 1 : 8
            anchors.verticalCenter: parent.verticalCenter

            text: statusChatListItem.name
            color: {
                if (statusChatListItem.muted && !sensor.containsMouse) {
                    return Theme.palette.directColor5
                }
                return statusChatListItem.hasMention || 
                  statusChatListItem.hasUnreadMessages ||
                  statusChatListItem.selected ||
                  sensor.containsMouse ||
                  statusBadge.visible ? Theme.palette.directColor1 : Theme.palette.directColor4
            }
            font.weight: statusChatListItem.hasMention || 
              statusChatListItem.hasUnreadMessages ||
              statusBadge.visible ? Font.Bold : Font.Medium
        }

        StatusBadge {
            id: statusBadge

            anchors.right: mutedIcon.visible ? mutedIcon.left : parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            border.width: 4
            border.color: color
            visible: statusBadge.value > 0
        }

        StatusIcon {
            id: mutedIcon
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            opacity: mutedIconSensor.containsMouse ? 1.0 : 0.2
            icon: Theme.palette.name === "light" ? "muted" : "muted-white"
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
    }
}
