import QtQuick 2.13


import utils 1.0

import StatusQ.Controls 0.1

import shared 1.0
import shared.views 1.0
import shared.popups 1.0
import shared.views.chat 1.0

import "../controls"
import "../panels"
import "../popups"

Item {
    id: root
    width: parent.width
    // Setting a height of 0 breaks the layout for when it comes back visible
    // The Item never goes back to actually have a height or width
    height: visible ? messageNotificationContent.height : 0.01
    visible: {
        if (hideReadNotifications && model.read) {
            return false
        }
        return activityCenter.currentFilter === ActivityCenterPopup.Filter.All ||
                (model.notificationType === Constants.activityCenterNotificationTypeMention && activityCenter.currentFilter === ActivityCenterPopup.Filter.Mentions) ||
                (model.notificationType === Constants.activityCenterNotificationTypeOneToOne && activityCenter.currentFilter === ActivityCenterPopup.Filter.ContactRequests) ||
                (model.notificationType === Constants.activityCenterNotificationTypeReply && activityCenter.currentFilter === ActivityCenterPopup.Filter.Replies)
    }

    property var store
    property var chatSectionModule
    property int previousNotificationIndex
    property string previousNotificationTimestamp
    // Not Refactored Yet
    property int communityIndex: -1 //root.store.chatsModelInst.communities.joinedCommunities.getCommunityIndex(model.message.communityId)
    function openProfile() {
        Global.openProfilePopup(model.author)
    }

    Component {
        id: markReadBtnComponent
        StatusFlatRoundButton {
            id: markReadBtn
            width: 32
            height: 32
            icon.width: 24
            icon.height: 24
            icon.source: Style.svg("double-check")
            color: "transparent"
            //% "Mark as Read"
            tooltip.text: !model.read ?
                qsTr("Mark as Read") :
                qsTr("Mark as Unread")
            tooltip.orientation: StatusToolTip.Orientation.Left
            tooltip.x: -tooltip.width - Style.current.padding
            tooltip.y: markReadBtn.height / 2 - height / 2 + 4
            onClicked: {
                if (!model.read) {
                    return root.store.activityCenterModuleInst.markActivityCenterNotificationRead(model.id, model.message.communityId, model.chatId, model.notificationType)
                }
                return root.store.activityCenterModuleInst.markActivityCenterNotificationUnread(model.id, model.message.communityId, model.message.chatId, model.notificationType)
            }
        }
    }


    Component {
        id: acceptRejectComponent
        AcceptRejectOptionsButtonsPanel {
            id: buttons
            onAcceptClicked: {
                // Not Refactored Yet
//                const setActiveChannel = root.store.chatsModelInst.channelView.setActiveChannel
//                const chatId = model.message.chatId
//                const messageId = model.message.messageId
                root.store.activityCenterModuleInst.acceptActivityCenterNotification(model.id)
//                root.store.chatsModelInst.activityNotificationList.acceptActivityCenterNotification(model.id)
//                setActiveChannel(chatId)
//                positionAtMessage(messageId)
            }
            onDeclineClicked: root.store.activityCenterModuleInst.dismissActivityCenterNotification(model.id)
            onProfileClicked: root.openProfile()
            onBlockClicked: {
                // Not Refactored Yet
//                const pk = model.author
//                blockContactConfirmationDialog.contactName = chatsModel.userNameOrAlias(pk)
//                blockContactConfirmationDialog.contactAddress = pk
//                blockContactConfirmationDialog.open()
            }

            BlockContactConfirmationDialog {
                id: blockContactConfirmationDialog
                onBlockButtonClicked: {
                    // Not Refactored Yet
//                    root.store.profileModuleInst.blockContact(blockContactConfirmationDialog.contactAddress)
                    root.store.activityCenterModuleInst.dismissActivityCenterNotification(model.id)
                    blockContactConfirmationDialog.close()
                }
            }
        }
    }

    Item {
        id: messageNotificationContent
        width: parent.width
        height: childrenRect.height
        MessageView {
            id: notificationMessage
            anchors.right: undefined
            messageStore: root.store.messageStore
            messageId: model.id
            senderDisplayName: model.message.senderDisplayName
            message: model.message.messageText
            responseToMessageWithId: model.message.responseToMessageWithId
            senderId: model.message.senderId
            senderLocalName: model.message.senderLocalName
            senderIcon: model.message.senderIcon
            isSenderIconIdenticon: model.message.isSenderIconIdenticon
            amISender: model.message.amISender
            messageImage: model.message.messageImage
            messageTimestamp: model.timestamp
            //timestamp: model.message.timestamp
            messageOutgoingStatus: model.message.outgoingStatus
            messageContentType: model.message.contentType
            //pinnedMessage: model.message.pinned
            //messagePinnedBy: model.message.pinnedBy
            //reactionsModel: model.message.reactions
            activityCenterMessage: true
            read: model.read
            onImageClicked: { Global.openImagePopup(image); }
            scrollToBottom: null
            clickMessage: function (isProfileClick) {
                if (isProfileClick) {
                    return Global.openProfilePopup(model.message.senderId);
                }

                activityCenter.close()

//                if (model.message.communityId) {
//                    root.chatSectionModule..communities.setActiveCommunity(model.message.communityId)
//                }

//                root.chatSectionModule.setActiveChannel(model.chatId);
                positionAtMessage(model.id);
            }
            prevMessageIndex: root.previousNotificationIndex
            prevMsgTimestamp: root.previousNotificationTimestamp
        }

        Rectangle {
            id: bottomBackdrop
            visible: badge.visible
            anchors.top: notificationMessage.bottom
            anchors.bottom: badge.bottom
            anchors.bottomMargin: visible ? -Style.current.smallPadding : 0
            width: parent.width
            color: model.read ? Style.current.transparent : Utils.setColorAlpha(Style.current.blue, 0.1)
        }

        Loader {
            active: true
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottom: notificationMessage.bottom
            anchors.bottomMargin: 14
            z: 52

            sourceComponent: {
                if (model.notificationType === Constants.activityCenterNotificationTypeOneToOne) {
                    return acceptRejectComponent
                }
                return markReadBtnComponent
            }
        }

        ActivityChannelBadgePanel {
            id: badge
            anchors.top: notificationMessage.bottom
            anchors.left: parent.left
            anchors.leftMargin: 61 // TODO find a way to align with the text of the message
            visible: model.notificationType !== Constants.activityCenterNotificationTypeOneToOne
            name: model.name
            chatId: model.chatId
            notificationType: model.notificationType
//            communityId: model.message.communityId
            // Not Refactored Yet
//            replyMessageIndex: root.store.chatsModelInst.messageView.getMessageIndex(model.chatId, model.responseTo)
            // Not Refactored Yet
//            repliedMessageContent: replyMessageIndex > -1 ? root.store.chatsModelInst.messageView.getMessageData(chatId, replyMessageIndex, "message") : ""
//            realChatType: {
                // Not Refactored Yet
//                var chatType = root.store.chatsModelInst.channelView.chats.getChannelType(model.chatId)
//                if (chatType === Constants.chatType.communityChat) {
//                    // TODO add a check for private community chats once it is created
//                    return Constants.chatType.publicChat
//                }
//                return chatType
//            }
            profileImage: realChatType === Constants.chatType.oneToOne ? Global.getProfileImage(chatId) || ""  : ""
            // Not Refactored Yet
//            channelName: root.store.chatsModelInst.getChannelNameById(badge.chatId)
            // Not Refactored Yet
//            communityName: root.communityIndex > -1 ? root.store.chatsModelInst.communities.joinedCommunities.rowData(root.communityIndex, "name") : ""
            // Not Refactored Yet
//            communityThumbnailImage: root.communityIndex > -1 ? root.store.chatsModelInst.communities.joinedCommunities.rowData(root.communityIndex, "thumbnailImage") : ""
            // Not Refactored Yet
//            communityColor: !model.image && root.communityIndex > -1 ? root.store.chatsModelInst.communities.joinedCommunities.rowData(root.communityIndex, "communityColor"): ""

            onCommunityNameClicked: {
                // Not Refactored Yet
//                root.store.chatsModelInst.communities.setActiveCommunity(badge.communityId)
            }
            onChannelNameClicked: {
                // Not Refactored Yet
//                root.store.chatsModelInst.communities.setActiveCommunity(badge.communityId)
//                root.store.chatsModelInst.setActiveChannel(badge.chatId)
            }

            // Not Refactored Yet
//            Connections {
//                enabled: badge.realChatType === Constants.chatType.oneToOne
//                target: root.store.allContacts
//                onContactChanged: {
//                    if (pubkey === badge.chatId) {
//                        badge.profileImage = Global.getProfileImage(badge.chatId)
//                    }
//                }
//            }
        }
    }
}
