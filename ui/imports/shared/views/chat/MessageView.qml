import QtQuick 2.13

import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.panels.chat 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

Column {
    id: root
    width: parent.width
    anchors.right: !isCurrentUser ? undefined : parent.right
    z: (typeof chatLogView === "undefined") ? 1 : (chatLogView.count - index)

    property var messageStore
    property var messageContextMenu

    property string messageId: ""
    property string responseToMessageWithId: ""
    property string senderId: ""
    property string senderDisplayName: ""
    property string senderLocalName: ""
    property string senderIcon: ""
    property bool isSenderIconIdenticon: true
    property bool amISender: false
    property string message: ""
    property string messageImage: ""
    property string messageTimestamp: ""
    property string messageOutgoingStatus: ""
    property int messageContentType: 1
    property bool pinnedMessage: false
    property var reactionsModel: []

    property int prevMessageIndex: -1
    property var prevMessageAsJsonObj
    property int nextMessageIndex: -1
    property var nextMessageAsJsonObj

    property string hoveredMessage
    property string activeMessage
    property bool isHovered: typeof hoveredMessage !== "undefined" && hoveredMessage === messageId
    property bool isMessageActive: typeof activeMessage !== "undefined" && activeMessage === messageId

    function setHovered(messageId, hovered) {
        if (hovered) {
            hoveredMessage = messageId;
        } else if (hoveredMessage === messageId) {
            hoveredMessage = "";
        }
    }

    function setMessageActive(messageId, active) {
        if (active) {
            activeMessage = messageId;
        } else if (activeMessage === messageId) {
            activeMessage = "";
        }
    }

    // Legacy
    property string responseTo: responseToMessageWithId
    property bool isCurrentUser: amISender
    property int contentType: messageContentType
    property string timestamp: messageTimestamp
    property string displayUserName: senderDisplayName
    property string outgoingStatus: messageOutgoingStatus
    property string authorCurrentMsg: senderId
    property string authorPrevMsg: {
        if(!prevMessageAsJsonObj)
            return ""

        return prevMessageAsJsonObj.senderId
    }
    property string prevMsgTimestamp: {
        if(!prevMessageAsJsonObj)
            return ""

        return prevMessageAsJsonObj.timestamp
    }
    property string nextMsgTimestamp: {
        if(!nextMessageAsJsonObj)
            return ""

        return nextMessageAsJsonObj.timestamp
    }

    property bool shouldRepeatHeader: ((parseInt(timestamp, 10) - parseInt(prevMsgTimestamp, 10)) / 60 / 1000) > Constants.repeatHeaderInterval

    //////////////////////////////////////
    //TODO CHECCK - REMOVE
    property string plainText: "That's right. We're friends...  Of justice, that is."
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property string emojiReactions: ""
    property bool timeout: false
    property bool hasMention: false
    property string linkUrls: ""
    property bool placeholderMessage: false
    property bool activityCenterMessage: false
    property bool read: true
    property string pinnedBy
    property bool forceHoverHandler: false // Used to force the HoverHandler to be active (useful for messages in popups)
    property int stickerPackId: -1
    property int gapFrom: 0
    property int gapTo: 0
    property bool isEdit: false
    property string replaces: ""
    property bool isEdited: false
    property bool showEdit: true

    //////////////////////////////////////

    property bool isEmoji: contentType === Constants.messageContentType.emojiType
    property bool isImage: contentType === Constants.messageContentType.imageType
    property bool isAudio: contentType === Constants.messageContentType.audioType
    property bool isStatusMessage: contentType === Constants.messageContentType.systemMessagePrivateGroupType
    property bool isSticker: contentType === Constants.messageContentType.stickerType
    property bool isText: contentType === Constants.messageContentType.messageType || contentType === Constants.messageContentType.editType
    property bool isMessage: isEmoji || isImage || isSticker || isText || isAudio
                             || contentType === Constants.messageContentType.communityInviteType || contentType === Constants.messageContentType.transactionType

    property bool isExpired: (outgoingStatus === "sending" && (Math.floor(timestamp) + 180000) < Date.now())
    property bool isStatusUpdate: false
    property int statusAgeEpoch: 0

    signal imageClick(var image)
    property var scrollToBottom: function () {}

    property var clickMessage: function(isProfileClick,
                                        isSticker = false,
                                        isImage = false,
                                        image = null,
                                        emojiOnly = false,
                                        hideEmojiPicker = false,
                                        isReply = false,
                                        isRightClickOnImage = false,
                                        imageSource = "") {

        if (placeholderMessage || activityCenterMessage) {
            return
        }

        messageContextMenu.myPublicKey = userProfile.pubKey
        messageContextMenu.amIAdmin = messageStore.amIChatAdmin()
        messageContextMenu.chatType = messageStore.getChatType()

        messageContextMenu.messageId = root.messageId
        messageContextMenu.messageSenderId = root.senderId
        messageContextMenu.messageContentType = root.messageContentType
        messageContextMenu.pinnedMessage = root.pinnedMessage
        messageContextMenu.canPin = messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins

        messageContextMenu.selectedUserPublicKey = root.senderId
        messageContextMenu.selectedUserDisplayName = root.senderDisplayName
        messageContextMenu.selectedUserIcon = root.senderIcon
        messageContextMenu.isSelectedUserIconIdenticon = root.isSenderIconIdenticon

        messageContextMenu.imageSource = imageSource

        messageContextMenu.isProfile = !!isProfileClick
        messageContextMenu.isRightClickOnImage = isRightClickOnImage
        messageContextMenu.emojiOnly = emojiOnly
        messageContextMenu.hideEmojiPicker = hideEmojiPicker

        if(isReply){
            let obj = messageStore.getMessageByIdAsJson(responseTo)
            if(!obj)
                return

            messageContextMenu.messageSenderId = obj.id
            messageContextMenu.selectedUserPublicKey = obj.id
            messageContextMenu.selectedUserDisplayName = obj.senderDisplayName
            messageContextMenu.selectedUserIcon = obj.senderIcon
            messageContextMenu.isSelectedUserIconIdenticon = obj.isSenderIconIdenticon
        }


        messageContextMenu.x = messageContextMenu.setXPosition()
        messageContextMenu.y = messageContextMenu.setYPosition()

        messageContextMenu.popup()
    }


//    function showReactionAuthors(fromAccounts, emojiId) {
//        return root.rootStore.showReactionAuthors(fromAccounts, emojiId)
//    }

//    function startMessageFoundAnimation() {
//        messageLoader.item.startMessageFoundAnimation();
//    }
    /////////////////////////////////////////////


    signal openStickerPackPopup(string stickerPackId)
    // Not Refactored Yet
//    Connections {
//        enabled: (!placeholderMessage && !!root.rootStore)
//        target: !!root.rootStore ? root.rootStore.allContacts : null
//        onContactChanged: {
//            if (pubkey === fromAuthor) {
//                const img = appMain.getProfileImage(userPubKey, isCurrentUser, useLargeImage)
//                if (img) {
//                    profileImageSource = img
//                }
//            } else if (replyMessageIndex > -1 && pubkey === repliedMessageAuthorPubkey) {
//                const imgReply = appMain.getProfileImage(repliedMessageAuthorPubkey, repliedMessageAuthorIsCurrentUser, false)
//                if (imgReply) {
//                    repliedMessageUserImage = imgReply
//                }
//            }
//        }
//    }

//    Connections {
//        enabled: !!root.rootStore
//        target: !!root.rootStore ? root.chatsModel.messageView : null
//        onHideMessage: {
//            // This hack is used because message_list deleteMessage sometimes does not remove the messages (there might be an issue with the delegate model)
//            if(mId === messageId){
//                root.visible = 0;
//                root.height = 0;
//            }
//        }
//    }

    Loader {
        id: messageLoader
        active: root.visible
        width: parent.width
        sourceComponent: {
            switch(contentType) {
                case Constants.messageContentType.chatIdentifier:
                    return channelIdentifierComponent
                case Constants.messageContentType.fetchMoreMessagesButton:
                    return fetchMoreMessagesButtonComponent
                case Constants.messageContentType.systemMessagePrivateGroupType:
                    return privateGroupHeaderComponent
                case Constants.messageContentType.gapType:
                    return gapComponent
                default:
                    return isStatusUpdate ? statusUpdateComponent : compactMessageComponent

            }
        }
    }

    Component {
        id: gapComponent
        GapComponent {
            onClicked: {
                // Not Refactored Yet - Should do it via messageStore
//                root.chatsModel.messageView.fillGaps(messageStore.messageId);
//                root.visible = false;
//                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
            nextMessageIndex: root.nextMessageIndex
            nextMsgTimestamp: root.nextMsgTimestamp
            onClicked: {
                // Not Refactored Yet - Should do it via messageStore
//                root.chatsModel.messageView.hideLoadingIndicator();
            }
            onTimerTriggered: {
                // Not Refactored Yet - Should do it via messageStore
//                root.chatsModel.requestMoreMessages(Constants.fetchRangeLast24Hours);
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifierView {
            chatName: root.senderDisplayName
            chatType: messageStore.getChatType()
            chatColor: messageStore.getChatColor()
            chatIcon: root.senderIcon
            chatIconIsIdenticon: root.isSenderIconIdenticon
        }
    }

    // Private group Messages
    Component {
        id: privateGroupHeaderComponent
        StyledText {
            wrapMode: Text.Wrap
            text: {
                return `<html>`+
                `<head>`+
                    `<style type="text/css">`+
                    `a {`+
                        `color: ${Style.current.textColor};`+
                        `text-decoration: none;`+
                    `}`+
                    `</style>`+
                `</head>`+
                `<body>`+
                    `${message}`+
                `</body>`+
            `</html>`;
            }
            visible: isStatusMessage
            font.pixelSize: 14
            color: Style.current.secondaryText
            width:  parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
            topPadding: root.prevMessageIndex === 1 ? Style.current.bigPadding : 0
        }
    }

    Component {
        id: statusUpdateComponent
        StatusUpdateView {
            statusAgeEpoch: root.statusAgeEpoch
            container: root
            // Not Refactored Yet
//            store: root.rootStore
            messageContextMenu: root.messageContextMenu
            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
            onChatImageClicked: {
            // Not Refactored Yet - Should do it via messageStore
//                root.imageClick(image);
            }
            onUserNameClicked: {
                // Not Refactored Yet - Should do it via messageStore
//                root.parent.clickMessage(isProfileClick);
            }
            onEmojiBtnClicked: {
                // Not Refactored Yet - Should do it via messageStore
//                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly);
            }
            onClickMessage: {
                // Not Refactored Yet - Should do it via messageStore
//                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
            onSetMessageActive: {
                root.setMessageActive(messageId, active);
            }
        }
    }

    Component {
        id: compactMessageComponent
        CompactMessageView {
            messageContextMenu: root.messageContextMenu
            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker)
            }

            onClickMessage: {
                root.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply, isRightClickOnImage, imageSource)
            }
            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }
        }
    }
}
