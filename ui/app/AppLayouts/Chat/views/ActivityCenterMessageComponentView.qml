import QtQuick 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"
import ".."

import "../controls"
import "../panels"

Item {
    id: root

    visible: {
        if (hideReadNotifications && model.read) {
            return false
        }

        return activityCenter.currentFilter === ActivityCenter.Filter.All ||
                (model.notificationType === Constants.activityCenterNotificationTypeMention && activityCenter.currentFilter === ActivityCenter.Filter.Mentions) ||
                (model.notificationType === Constants.activityCenterNotificationTypeOneToOne && activityCenter.currentFilter === ActivityCenter.Filter.ContactRequests) ||
                (model.notificationType === Constants.activityCenterNotificationTypeReply && activityCenter.currentFilter === ActivityCenter.Filter.Replies)
    }
    width: parent.width
    // Setting a height of 0 breaks the layout for when it comes back visible
    // The Item never goes back to actually have a height or width
    height: visible ? messageNotificationContent.height : 0.01
    property var store
    function openProfile() {
        const pk = model.author
        const userProfileImage = appMain.getProfileImage(pk)
        openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
    }

    Component {
        id: markReadBtnComponent
        StatusIconButton {
            id: markReadBtn
            icon.name: "double-check"
            iconColor: Style.current.primary
            icon.width: 24
            icon.height: 24
            width: 32
            height: 32

            onClicked: chatsModel.activityNotificationList.markActivityCenterNotificationRead(model.id, model.message.communityId, model.message.chatId, model.notificationType)

            StatusToolTip {
                visible: markReadBtn.hovered
                //% "Mark as Read"
                text: qsTrId("mark-as-read")
                orientation: "left"
                x: - width - Style.current.padding
                y: markReadBtn.height / 2 - height / 2 + 4
            }
        }
    }


    Component {
        id: acceptRejectComponent
        AcceptRejectOptionsButtonsPanel {
            id: buttons
            onAcceptClicked: {
                const setActiveChannel = chatsModel.channelView.setActiveChannel
                const chatId = model.message.chatId
                const messageId = model.message.messageId
                profileModel.contacts.addContact(model.author)
                chatsModel.activityNotificationList.acceptActivityCenterNotification(model.id)
                setActiveChannel(chatId)
                positionAtMessage(messageId)
            }
            onDeclineClicked: chatsModel.activityNotificationList.dismissActivityCenterNotification(model.id)
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
                    profileModel.contacts.blockContact(blockContactConfirmationDialog.contactAddress)
                    chatsModel.activityNotificationList.dismissActivityCenterNotification(model.id)
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
                        return openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
                    }

                    activityCenter.close()

                    if (model.message.communityId) {
                        chatsModel.communities.setActiveCommunity(model.message.communityId)
                    }

                    chatsModel.channelView.setActiveChannel(model.message.chatId)
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
            visible: model.notificationType !== Constants.activityCenterNotificationTypeOneToOne
            name: model.name
            chatId: model.chatId
            notificationType: model.notificationType
            responseTo: model.message.responseTo
            communityId: model.message.communityId
            anchors.top: notificationMessage.bottom
            anchors.left: parent.left
            anchors.leftMargin: 61 // TODO find a way to align with the text of the message
        }
    }
}
