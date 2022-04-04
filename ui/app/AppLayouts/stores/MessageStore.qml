import QtQuick 2.13
import utils 1.0

QtObject {
    id: root
    property string hoveredMessage
    property string activeMessage
    property string fromAuthor: "0x0011223344556677889910"
    property string userName: "Jotaro Kujo"
    property string alias: ""
    property string localName: ""
    property string message: "That's right. We're friends...  Of justice, that is."
    property string plainText: "That's right. We're friends...  Of justice, that is."
    property bool isCurrentUser: false
    property string timestamp: "1234567"
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int contentType: 1 // constants don't work in default props
    property string chatId: "chatId"
    property string outgoingStatus: ""
    property string responseTo: ""
    property string messageId: ""
    property string emojiReactions: ""
    property int prevMessageIndex: -1
    property int nextMessageIndex: -1
    property bool timeout: false
    property bool hasMention: false
    property string linkUrls: ""
    property bool placeholderMessage: false
    property bool activityCenterMessage: false
    property bool pinnedMessage: false
    property bool read: true
    property string pinnedBy
    property bool forceHoverHandler: false // Used to force the HoverHandler to be active (useful for messages in popups)
    property string communityId: ""
    property int stickerPackId: -1
    property int gapFrom: 0
    property int gapTo: 0
    property bool isEdit: false
    property string replaces: ""
    property bool isEdited: false
    property bool showEdit: true
    property var messageContextMenu
    property bool isMessageActive: typeof root.activeMessage !== "undefined" && root.activeMessage === root.messageId
    property string displayUserName: {
        if (isCurrentUser) {
            return qsTr("You")
        }

        if (localName !== "") {
            return localName
        }

        if (userName !== "") {
            return Utils.removeStatusEns(userName)
        }
        return Utils.removeStatusEns(alias)
    }

    property string authorCurrentMsg: "authorCurrentMsg"
    property string authorPrevMsg: "authorPrevMsg"

    property string prevMsgTimestamp: chatsModel.messageView.messageList.getMessageData(prevMessageIndex, "timestamp")
    property string nextMsgTimestamp: chatsModel.messageView.messageList.getMessageData(nextMessageIndex, "timestamp")

    property bool shouldRepeatHeader: ((parseInt(timestamp, 10) - parseInt(prevMsgTimestamp, 10)) / 60 / 1000) > Constants.repeatHeaderInterval

    property bool isEmoji: contentType === Constants.emojiType
    property bool isImage: contentType === Constants.imageType
    property bool isAudio: contentType === Constants.audioType
    property bool isStatusMessage: contentType === Constants.systemMessagePrivateGroupType
    property bool isSticker: contentType === Constants.stickerType
    property bool isText: contentType === Constants.messageType || contentType === Constants.editType
    property bool isMessage: isEmoji || isImage || isSticker || isText || isAudio
                             || contentType === Constants.communityInviteType || contentType === Constants.transactionType

    property bool isExpired: (outgoingStatus === "sending" && (Math.floor(timestamp) + 180000) < Date.now())
    property int statusAgeEpoch: 0

//    property int replyMessageIndex: chatsModel.messageView.messageList.getMessageIndex(responseTo);
//    property string repliedMessageAuthor: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "userName") : "";
//    property string repliedMessageAuthorPubkey: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "publicKey") : "";
//    property bool repliedMessageAuthorIsCurrentUser: replyMessageIndex > -1 ? repliedMessageAuthorPubkey === userProfile.pubKey : "";
//    property bool repliedMessageIsEdited: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "isEdited") === "true" : false;
//    property string repliedMessageContent: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "message") : "";
//    property int repliedMessageType: replyMessageIndex > -1 ? parseInt(chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "contentType")) : 0;
//    property string repliedMessageImage: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "image") : "";
//    property string repliedMessageUserIdenticon: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "identicon") : "";
//    property string repliedMessageUserImage: replyMessageIndex > -1 ? appMain.getProfileImage(repliedMessageAuthorPubkey, repliedMessageAuthorIsCurrentUser , false) || "" : "";

    property var imageClick: function () {}
    property var scrollToBottom: function () {}
    property string userPubKey: {
        if (contentType === Constants.chatIdentifier) {
            return chatId
        }
        return fromAuthor
    }
    property bool useLargeImage: contentType === Constants.chatIdentifier

    property string profileImageSource: !placeholderMessage && appMain.getProfileImage(userPubKey, isCurrentUser, useLargeImage) || ""

    property var emojiReactionsModel: {
        if (!emojiReactions) {
            return []
        }

        try {
            // group by id
            var allReactions = Object.values(JSON.parse(emojiReactions))
            var byEmoji = {}
            allReactions.forEach(function (reaction) {
                if (!byEmoji[reaction.emojiId]) {
                    byEmoji[reaction.emojiId] = {
                        emojiId: reaction.emojiId,
                        fromAccounts: [],
                        count: 0,
                        currentUserReacted: false
                    }
                }
                byEmoji[reaction.emojiId].count++;
                byEmoji[reaction.emojiId].fromAccounts.push(chatsModel.userNameOrAlias(reaction.from));
                if (!byEmoji[reaction.emojiId].currentUserReacted && reaction.from === userProfile.pubKey) {
                    byEmoji[reaction.emojiId].currentUserReacted = true
                }

            })
            return Object.values(byEmoji)
        } catch (e) {
            console.error('Error parsing emoji reactions', e)
            return []
        }
    }
    property var clickMessage: function(isProfileClick, isSticker = false, isImage = false, image = null, isEmoji = false, hideEmojiPicker = false, isReply = false, isRightClickOnImage = false, imageSource = "") {
        if (placeholderMessage || activityCenterMessage) {
            return
        }

        if (!isProfileClick) {
            SelectedMessage.set(messageId, fromAuthor);
        }

        messageContextMenu.messageId = messageId
        messageContextMenu.contentType = contentType
        messageContextMenu.linkUrls = linkUrls;
        messageContextMenu.isProfile = !!isProfileClick;
        messageContextMenu.isCurrentUser = isCurrentUser
        messageContextMenu.isText = isText
        messageContextMenu.isSticker = isSticker;
        messageContextMenu.isEmoji = isEmoji;
        messageContextMenu.hideEmojiPicker = hideEmojiPicker;
        messageContextMenu.pinnedMessage = pinnedMessage;
        messageContextMenu.isCurrentUser = isCurrentUser;
        messageContextMenu.isRightClickOnImage = isRightClickOnImage
        messageContextMenu.imageSource = imageSource
        messageContextMenu.onClickEdit = function() {isEdit = true}

        //TODO remove dynamic scoping
        if (isReply) {
            let nickname = appMain.getUserNickname(repliedMessageAuthor)
            messageContextMenu.show(repliedMessageAuthor, repliedMessageAuthorPubkey, repliedMessageUserImage, plainText, nickname, emojiReactionsModel);
        } else {
            let nickname = appMain.getUserNickname(fromAuthor)
            messageContextMenu.show(userName, fromAuthor, profileImageSource, plainText, nickname, emojiReactionsModel);
        }

         messageContextMenu.x = messageContextMenu.setXPosition()
         messageContextMenu.y = messageContextMenu.setYPosition()
    }

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
}
