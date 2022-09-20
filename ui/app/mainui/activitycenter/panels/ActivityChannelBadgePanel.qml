import QtQuick 2.13

import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import "../controls"

Rectangle {
    id: root

    property bool isCommunity: false
    property string name: "channelName"
    property int realChatType: -1
    property string channelName: ""
    property string communityName: ""
    property string communityColor: ""
    property string communityThumbnailImage: ""
    property string repliedMessageId: ""
    property string repliedMessageContent: ""
    property int notificationType
    property string profileImage: ""

    property color textColor: Theme.palette.baseColor1

    signal communityNameClicked()
    signal channelNameClicked()

    height: visible ? 24 : 0
    width: childrenRect.width + 12
    color: Style.current.transparent
    border.color: Style.current.borderSecondary
    border.width: 1
    radius: 11
    visible: (repliedMessageId > -1)


    Loader {
        active: true
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: 4
        sourceComponent: {
            switch (root.notificationType) {
            case Constants.activityCenterNotificationTypeMention: 
                return root.isCommunity ? communityBadgeComponent : channelBadgeComponent
            case Constants.activityCenterNotificationTypeReply: 
                return replyComponent
            default: 
                return root.isCommunity ? communityBadgeComponent : channelBadgeComponent
            }
        }
    }

    Component {
        id: replyComponent

        ReplyComponent {
            width: childrenRect.width
            height: parent.height
            repliedMessageContent: root.repliedMessageContent
        }
    }

    Component {
        id: communityBadgeComponent

        CommunityBadge {
            width: childrenRect.width
            height: parent.height

            textColor: root.textColor
            image: root.communityThumbnailImage
            iconColor: root.communityColor
            communityName: root.communityName
            channelName: root.channelName
            name: root.name

            onCommunityNameClicked: root.communityNameClicked()
            onChannelNameClicked: root.channelNameClicked()
        }
    }

    Component {
        id: channelBadgeComponent

        ChannelBadge {
            width: childrenRect.width
            height: parent.height

            realChatType: root.realChatType
            textColor: root.textColor
            name: root.name
            profileImage: root.profileImage
        }
    }
}
