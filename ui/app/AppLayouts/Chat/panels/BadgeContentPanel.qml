import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Components 0.1 as StatusQ
import StatusQ.Core 0.1

Item {
    id: wrapper

    property color textColor: Style.current.textColor
    property string chatId: ""
    property string name: "channelName"
    property string identicon
    property string communityId
    property bool hideSecondIcon: false
    property int chatType: chatsModel.channelView.chats.getChannelType(chatId)
    property int realChatType: {
        if (chatType === Constants.chatTypeCommunity) {
            // TODO add a check for private community chats once it is created
            return Constants.chatTypePubliccommunityComponent
        }
        return chatType
    }

    property string profileImage: realChatType === Constants.chatTypeOneToOne ? appMain.getProfileImage(chatId) || ""  : ""

    height: 24
    width: childrenRect.width

    Loader {
        active: true
        height: parent.height
        sourceComponent: wrapper.communityId ? communityComponent : channelComponent
    }

    Component {
        id: communityComponent

        Item {
            property int communityIndex: chatsModel.communities.joinedCommunities.getCommunityIndex(wrapper.communityId)

            property string image: communityIndex > -1 ? chatsModel.communities.joinedCommunities.rowData(communityIndex, "thumbnailImage") : ""
            property string iconColor: !image && communityIndex > -1 ? chatsModel.communities.joinedCommunities.rowData(communityIndex, "communityColor"): ""
            property bool useLetterIdenticon: !image
            property string communityName: communityIndex > -1 ? chatsModel.communities.joinedCommunities.rowData(communityIndex, "name") : ""
            property string channelName: chatsModel.getChannelNameById(wrapper.chatId)

            id: communityBadge
            width: childrenRect.width
            height: parent.height
            SVGImage {
                id: communityIcon
                visible: !hideSecondIcon
                width: 16
                height: 16
                source: Style.svg("communities")
                anchors.left: parent.left
                anchors.verticalCenter:parent.verticalCenter

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: wrapper.textColor
                }
            }

            Loader {
                id: communityImageLoader
                active: true
                anchors.left: communityIcon.visible ? communityIcon.right : parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: communityBadge.useLetterIdenticon ? letterIdenticon :imageIcon
            }

            Component {
                id: imageIcon
                RoundedImage {
                    source: communityBadge.image
                    noMouseArea: true
                    noHover: true
                    width: 16
                    height: 16
                }
            }

            Component {
                id: letterIdenticon
                StatusQ.StatusLetterIdenticon {
                    width: 16
                    height: 16
                    letterSize: 12
                    name: communityBadge.communityName
                    color: communityBadge.iconColor
                }
            }

            StyledTextEdit {
                id: communityName
                text: Utils.getLinkStyle(communityBadge.communityName, hoveredLink, wrapper.textColor)
                height: 18
                readOnly: true
                textFormat: Text.RichText
                width: implicitWidth > 300 ? 300 : implicitWidth
                clip: true
                anchors.left: communityImageLoader.right
                anchors.leftMargin: 4
                color: wrapper.textColor
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
                onLinkActivated: function () {
                    chatsModel.communities.setActiveCommunity(wrapper.communityId)
                }
            }

            SVGImage {
                id: caretImage
                source: Style.svg("show-category")
                width: 16
                height: 16
                anchors.left: communityName.right
                anchors.verticalCenter: parent.verticalCenter

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: wrapper.textColor
                }
            }

            StyledTextEdit {
                id: channelName
                text: communityBadge.getLinkStyle(communityBadge.channelName || wrapper.name, hoveredLink, wrapper.textColor)
                height: 18
                readOnly: true
                textFormat: Text.RichText
                width: implicitWidth > 300 ? 300 : implicitWidth
                clip: true
                anchors.left: caretImage.right
                color: wrapper.textColor
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
                onLinkActivated: function () {
                    chatsModel.communities.setActiveCommunity(wrapper.communityId)
                    chatsModel.setActiveChannel(model.message.chatId)
                }
            }
        }
    }

    Component {
        id: channelComponent

        Item {
            width: childrenRect.width
            height: parent.height

            Connections {
                enabled: realChatType === Constants.chatTypeOneToOne
                target: contactsModule.model.list
                onContactChanged: {
                    if (pubkey === wrapper.chatId) {
                        wrapper.profileImage = appMain.getProfileImage(wrapper.chatId)
                    }
                }
            }

            SVGImage {
                id: channelIcon
                width: 16
                height: 16
                fillMode: Image.PreserveAspectFit
                source: Style.svg("channel-icon-" + (wrapper.realChatType === Constants.chatTypePublic ? "public-chat" : "group"))
                anchors.left: parent.left
                anchors.verticalCenter:parent.verticalCenter
            }

            StatusQ.StatusSmartIdenticon {
                id: contactImage
                anchors.left: channelIcon.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                image: StatusImageSettings {
                    width: 16
                    height: 16
                    source: wrapper.profileImage || wrapper.identicon
                    isIdenticon: true
                }
                icon: StatusIconSettings {
                    width: 16
                    height: 16
                    letterSize: 11
                }
                name: wrapper.name
            }

            StyledText {
                id: contactInfo
                text: wrapper.realChatType !== Constants.chatTypePublic ?
                          Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(wrapper.name))) :
                          "#" + Utils.filterXSS(wrapper.name)
                anchors.left: contactImage.right
                anchors.leftMargin: 4
                color: wrapper.textColor
                font.weight: Font.Medium
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
