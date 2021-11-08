import QtQuick 2.13


import utils 1.0

import StatusQ.Controls 0.1 as StatusQ

import shared 1.0
import shared.popups 1.0

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
    property int communityIndex: root.store.chatsModelInst.communities.joinedCommunities.getCommunityIndex(model.message.communityId)
    function openProfile() {
        const pk = model.author
        const userProfileImage = appMain.getProfileImage(pk)
        openProfilePopup(root.store.chatsModelInst.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
    }

    Component {
        id: markReadBtnComponent
        StatusQ.StatusFlatRoundButton {
            id: markReadBtn
            width: 32
            height: 32
            icon.width: 24
            icon.height: 24
            icon.source: Style.svg("double-check")
            color: "transparent"
            //% "Mark as Read"
            tooltip.text: qsTrId("mark-as-read")
            tooltip.orientation: StatusQ.StatusToolTip.Orientation.Left
            tooltip.x: -tooltip.width - Style.current.padding
            tooltip.y: markReadBtn.height / 2 - height / 2 + 4
            onClicked: root.store.chatsModelInst.activityNotificationList.markActivityCenterNotificationRead(model.id, model.message.communityId, model.message.chatId, model.notificationType)
        }
    }


    Component {
        id: acceptRejectComponent
        AcceptRejectOptionsButtonsPanel {
            id: buttons
            onAcceptClicked: {
                const setActiveChannel = root.store.chatsModelInst.channelView.setActiveChannel
                const chatId = model.message.chatId
                const messageId = model.message.messageId
                root.store.profileModuleInst.addContact(model.author)
                root.store.chatsModelInst.activityNotificationList.acceptActivityCenterNotification(model.id)
                setActiveChannel(chatId)
                positionAtMessage(messageId)
            }
            onDeclineClicked: root.store.chatsModelInst.activityNotificationList.dismissActivityCenterNotification(model.id)
            onProfileClicked: root.openProfile()
            onBlockClicked: {
                const pk = model.author
                blockContactConfirmationDialog.contactName = chatsModel.userNameOrAlias(pk)
                blockContactConfirmationDialog.contactAddress = pk
                blockContactConfirmationDialog.open()
            }

            BlockContactConfirmationDialog {
                id: blockContactConfirmationDialog
                onBlockButtonClicked: {
                    root.store.profileModuleInst.blockContact(blockContactConfirmationDialog.contactAddress)
                    root.store.chatsModelInst.activityNotificationList.dismissActivityCenterNotification(model.id)
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
            rootStore: root.store
            messageStore: root.store.messageStore
            //TODO Remove
            fromAuthor: model.message.fromAuthor
            chatId: model.message.chatId
            userName: model.message.userName
            alias: model.message.alias
            localName: model.message.localName
            message: model.message.message
            plainText: model.message.plainText
            identicon: model.message.identicon
            isCurrentUser: model.message.isCurrentUser
            timestamp: model.message.timestamp
            sticker: model.message.sticker
            contentType: model.message.contentType
            outgoingStatus: model.message.outgoingStatus
            responseTo: model.message.responseTo
            imageClick: imagePopup.openPopup.bind(imagePopup)
            messageId: model.message.messageId
            linkUrls: model.message.linkUrls
            communityId: model.message.communityId
            hasMention: model.message.hasMention
            stickerPackId: model.message.stickerPackId
            pinnedBy: model.message.pinnedBy
            pinnedMessage: model.message.isPinned
            activityCenterMessage: true
            read: model.read
            clickMessage: function (isProfileClick) {
                if (isProfileClick) {
                    const pk = model.message.fromAuthor
                    const userProfileImage = appMain.getProfileImage(pk)
                    return openProfilePopup(root.store.chatsModelInst.userNameOrAlias(pk), pk, userProfileImage || root.store.utilsModelInst.generateIdenticon(pk))
                }

                activityCenter.close()

                if (model.message.communityId) {
                    root.store.chatsModelInst.communities.setActiveCommunity(model.message.communityId)
                }

                root.store.chatsModelInst.channelView.setActiveChannel(model.message.chatId)
                positionAtMessage(model.message.messageId)
            }

            prevMessageIndex: previousNotificationIndex
            prevMsgTimestamp: previousNotificationTimestamp
            Component.onCompleted: {
                messageStore.activityCenterMessage = true;
                messageStore.fromAuthor = model.message.fromAuthor;
                messageStore.chatId = model.message.chatId;
                messageStore.userName = model.message.userName;
                messageStore.alias = model.message.alias;
                messageStore.localName = model.message.localName;
                messageStore.message = model.message.message;
                messageStore.plainText = model.message.plainText;
                messageStore.identicon = model.message.identicon;
                messageStore.isCurrentUser = model.message.isCurrentUser;
                messageStore.timestamp = model.message.timestamp;
                messageStore.sticker = model.message.sticker;
                messageStore.contentType = model.message.contentType;
                messageStore.outgoingStatus = model.message.outgoingStatus;
                messageStore.responseTo = model.message.responseTo;
                messageStore.imageClick = imagePopup.openPopup.bind(imagePopup);
                messageStore.messageId = model.message.messageId;
                messageStore.linkUrls = model.message.linkUrls;
                messageStore.communityId = model.message.communityId;
                messageStore.hasMention = model.message.hasMention;
                messageStore.stickerPackId = model.message.stickerPackId;
                messageStore.pinnedBy = model.message.pinnedBy;
                messageStore.pinnedMessage = model.message.isPinned;
                messageStore.read = model.read;
                messageStore.prevMessageIndex = previousNotificationIndex;
                messageStore.prevMsgTimestamp = previousNotificationTimestamp;
                messageStore.clickMessage = function (isProfileClick) {
                    if (isProfileClick) {
                        const pk = model.message.fromAuthor
                        const userProfileImage = appMain.getProfileImage(pk)
                        return openProfilePopup(root.store.chatsModelInst.userNameOrAlias(pk), pk, userProfileImage || root.store.utilsModelInst.generateIdenticon(pk))
                    }

                    activityCenter.close()

                    if (model.message.communityId) {
                        root.store.chatsModelInst.communities.setActiveCommunity(model.message.communityId)
                    }

                    root.store.chatsModelInst.channelView.setActiveChannel(model.message.chatId)
                    positionAtMessage(model.message.messageId)
                }
            }
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
            communityId: model.message.communityId
            replyMessageIndex: root.store.chatsModelInst.messageView.getMessageIndex(model.chatId, model.responseTo)
            repliedMessageContent: replyMessageIndex > -1 ? root.store.chatsModelInst.messageView.getMessageData(chatId, replyMessageIndex, "message") : ""
            realChatType: {
                var chatType = root.store.chatsModelInst.channelView.chats.getChannelType(model.chatId)
                if (chatType === Constants.chatTypeCommunity) {
                    // TODO add a check for private community chats once it is created
                    return Constants.chatTypePublic
                }
                return chatType
            }
            profileImage: realChatType === Constants.chatTypeOneToOne ? appMain.getProfileImage(chatId) || ""  : ""
            channelName: root.store.chatsModelInst.getChannelNameById(badge.chatId)
            communityName: root.communityIndex > -1 ? root.store.chatsModelInst.communities.joinedCommunities.rowData(root.communityIndex, "name") : ""
            communityThumbnailImage: root.communityIndex > -1 ? root.store.chatsModelInst.communities.joinedCommunities.rowData(root.communityIndex, "thumbnailImage") : ""
            communityColor: !model.image && root.communityIndex > -1 ? root.store.chatsModelInst.communities.joinedCommunities.rowData(root.communityIndex, "communityColor"): ""

            onCommunityNameClicked: {
                root.store.chatsModelInst.communities.setActiveCommunity(badge.communityId)
            }
            onChannelNameClicked: {
                root.store.chatsModelInst.communities.setActiveCommunity(badge.communityId)
                root.store.chatsModelInst.setActiveChannel(badge.chatId)
            }

            Connections {
                enabled: badge.realChatType === Constants.chatTypeOneToOne
                target: root.store.allContacts
                onContactChanged: {
                    if (pubkey === badge.chatId) {
                        badge.profileImage = appMain.getProfileImage(badge.chatId)
                    }
                }
            }
        }
    }
}
