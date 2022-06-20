import QtQuick 2.13

import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import "../controls/activityCenter" as ActivityCenter

Rectangle {
    id: wrapper

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

    height: visible ? Style.dp(24) : 0
    width: childrenRect.width + Style.dp(12)
    color: Style.current.transparent
    border.color: Style.current.borderSecondary
    border.width: Style.dp(1)
    radius: Style.dp(11)

    Loader {
        active: true
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: Style.dp(4)
        sourceComponent: {
            switch (wrapper.notificationType) {
            case Constants.activityCenterNotificationTypeMention: return wrapper.isCommunity? communityBadgeComponent : channelBadgeComponent
            case Constants.activityCenterNotificationTypeReply: return replyComponent
            default: return wrapper.isCommunity? communityBadgeComponent : channelBadgeComponent
            }
        }
    }

    Component {
        id: replyComponent
        ActivityCenter.ReplyComponent {
            width: childrenRect.width
            height: parent.height
            repliedMessageId: wrapper.repliedMessageId
            repliedMessageContent: wrapper.repliedMessageContent
        }
    }

    Component {
        id: communityBadgeComponent
        ActivityCenter.CommunityBadge {
            width: childrenRect.width
            height: parent.height

            textColor: wrapper.textColor
            image: wrapper.communityThumbnailImage
            iconColor: wrapper.communityColor
            communityName: wrapper.communityName
            channelName: wrapper.channelName
            name: wrapper.name

            onCommunityNameClicked: wrapper.communityNameClicked()
            onChannelNameClicked: wrapper.channelNameClicked()
        }
    }

    Component {
        id: channelBadgeComponent
        ActivityCenter.ChannelBadge {
            width: childrenRect.width
            height: parent.height

            realChatType: wrapper.realChatType
            textColor: wrapper.textColor
            name: wrapper.name
            profileImage: wrapper.profileImage
        }
    }
}
