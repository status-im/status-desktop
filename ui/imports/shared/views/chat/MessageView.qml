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

    property var rootStore
    property var messageStore
    //property var chatsModel: !!root.rootStore ? root.rootStore.chatsModelInst : null

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
    //TODO REMOVE
//    property string fromAuthor: "0x0011223344556677889910"
//    property string userName: "Jotaro Kujo"
//    property string alias: ""
//    property string localName: ""
//    property string message: "That's right. We're friends...  Of justice, that is."
    property string plainText: "That's right. We're friends...  Of justice, that is."
//    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAGQAQMAAAC6caSPAAAABlBMVEXMzMz////TjRV2AAAAAWJLR0QB/wIt3gAAACpJREFUGBntwYEAAAAAw6D7Uw/gCtUAAAAAAAAAAAAAAAAAAAAAAAAAgBNPsAABAjKCqQAAAABJRU5ErkJggg=="
//    property bool isCurrentUser: false
//    property string timestamp: "1234567"
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
//    property int contentType: 1 // constants don't work in default props
    property string chatId: "chatId"
//    property string outgoingStatus: ""
//    property string responseTo: ""
//    property string messageId: ""
    property string emojiReactions: ""
//    property int prevMessageIndex: -1
//    property int nextMessageIndex: -1
    property bool timeout: false
    property bool hasMention: false
    property string linkUrls: ""
    property bool placeholderMessage: false
    property bool activityCenterMessage: false
//    property bool pinnedMessage: false
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
//    property string displayUserName: {
//        if (isCurrentUser) {
//            //% "You"
//            return qsTrId("You")
//        }

//        if (localName !== "") {
//            return localName
//        }

//        if (userName !== "") {
//            return Utils.removeStatusEns(userName)
//        }
//        return Utils.removeStatusEns(alias)
//    }

//    property string authorCurrentMsg: "authorCurrentMsg"
//    property string authorPrevMsg: "authorPrevMsg"

//    property string prevMsgTimestamp: !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(prevMessageIndex, "timestamp") : ""
//    property string nextMsgTimestamp: !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(nextMessageIndex, "timestamp"): ""

//    property bool shouldRepeatHeader: ((parseInt(timestamp, 10) - parseInt(prevMsgTimestamp, 10)) / 60 / 1000) > Constants.repeatHeaderInterval

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

    // TODO: we don't use replyMessageIndex any more, but messageId
//    property int replyMessageIndex: !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageIndex(responseTo) : -1
//    property string repliedMessageAuthor: replyMessageIndex > -1 ? !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "userName") : "" : "";
//    property string repliedMessageAuthorPubkey: replyMessageIndex > -1 ? root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "publicKey") : "";
//    property bool repliedMessageAuthorIsCurrentUser: replyMessageIndex > -1 ? repliedMessageAuthorPubkey === userProfile.pubKey : "";
//    property bool repliedMessageIsEdited: replyMessageIndex > -1 ? !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "isEdited") === "true" : false : false;
//    property string repliedMessageContent: replyMessageIndex > -1 ? !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "message") : "" : "";
//    property int repliedMessageType: replyMessageIndex > -1 ? !!root.chatsModel ? parseInt(root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "contentType")) : 0 : 0;
//    property string repliedMessageImage: replyMessageIndex > -1 ? !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "image") : "" : "";
//    property string repliedMessageUserIdenticon: replyMessageIndex > -1 ? !!root.chatsModel ? root.chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "identicon") : "" : "";
//    property string repliedMessageUserImage: replyMessageIndex > -1 ? appMain.getProfileImage(repliedMessageAuthorPubkey, repliedMessageAuthorIsCurrentUser , false) || "" : "";

    property var imageClick: function () {}
    property var scrollToBottom: function () {}
//    property string userPubKey: {
//        if (contentType === Constants.messageContentType.chatIdentifier) {
//            return chatId
//        }
//        return fromAuthor
//    }
//    property bool useLargeImage: contentType === Constants.messageContentType.chatIdentifier

    // Not Refactored Yet - This will be determined on the backend
//    property string profileImageSource: !placeholderMessage && appMain.getProfileImage(userPubKey, isCurrentUser, useLargeImage) || ""

    property var emojiReactionsModel: {
        // Not Refactored Yet
        return []
//        if (!emojiReactions) {
//            return []
//        }

//        try {
//            // group by id
//            var allReactions = Object.values(JSON.parse(emojiReactions))
//            var byEmoji = {}
//            allReactions.forEach(function (reaction) {
//                if (!byEmoji[reaction.emojiId]) {
//                    byEmoji[reaction.emojiId] = {
//                        emojiId: reaction.emojiId,
//                        fromAccounts: [],
//                        count: 0,
//                        currentUserReacted: false
//                    }
//                }
//                byEmoji[reaction.emojiId].count++;
//                byEmoji[reaction.emojiId].fromAccounts.push(root.chatsModel.userNameOrAlias(reaction.from));
//                if (!byEmoji[reaction.emojiId].currentUserReacted && reaction.from === userProfile.pubKey) {
//                    byEmoji[reaction.emojiId].currentUserReacted = true
//                }

//            })
//            return Object.values(byEmoji)
//        } catch (e) {
//            console.error('Error parsing emoji reactions', e)
//            return []
//        }
    }

    property var clickMessage: function(isProfileClick, isSticker = false, isImage = false, image = null, emojiOnly = false, hideEmojiPicker = false, isReply = false, isRightClickOnImage = false, imageSource = "") {
        // Not Refactored Yet
//        if (placeholderMessage || activityCenterMessage) {
//            return
//        }

//        if (!isProfileClick) {
//            SelectedMessage.set(messageId, fromAuthor);
//        }

//        messageContextMenu.messageId = root.messageId
//        messageContextMenu.contentType = root.contentType
//        messageContextMenu.linkUrls = root.linkUrls;
//        messageContextMenu.isProfile = !!isProfileClick;
//        messageContextMenu.isCurrentUser = root.isCurrentUser
//        messageContextMenu.isText = root.isText
//        messageContextMenu.isSticker = isSticker;
//        messageContextMenu.emojiOnly = emojiOnly;
//        messageContextMenu.hideEmojiPicker = hideEmojiPicker;
//        messageContextMenu.pinnedMessage = pinnedMessage;
//        messageContextMenu.isCurrentUser = isCurrentUser;
//        messageContextMenu.isRightClickOnImage = isRightClickOnImage
//        messageContextMenu.imageSource = imageSource
//        messageContextMenu.onClickEdit = function() {root.isEdit = true}

//        if (isReply) {
//            let nickname = appMain.getUserNickname(repliedMessageAuthor)
//            messageContextMenu.show(repliedMessageAuthor, repliedMessageAuthorPubkey, repliedMessageUserImage || repliedMessageUserIdenticon, plainText, nickname, emojiReactionsModel);
//        } else {
//            let nickname = appMain.getUserNickname(fromAuthor)
//            messageContextMenu.show(userName, fromAuthor, root.profileImageSource || identicon, plainText, nickname, emojiReactionsModel);
//        }

//         messageContextMenu.x = messageContextMenu.setXPosition()
//         messageContextMenu.y = messageContextMenu.setYPosition()
    }


//    function showReactionAuthors(fromAccounts, emojiId) {
//        return root.rootStore.showReactionAuthors(fromAccounts, emojiId)
//    }

//    function startMessageFoundAnimation() {
//        messageLoader.item.startMessageFoundAnimation();
//    }
    /////////////////////////////////////////////

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
                    return isStatusUpdate ? statusUpdateComponent :
                                            (localAccountSensitiveSettings.useCompactMode ? compactMessageComponent : messageComponent)

            }
        }
    }

    Component {
        id: gapComponent
        GapComponent {
            onClicked: {
                // Not Refactored Yet
//                root.chatsModel.messageView.fillGaps(messageStore.messageId);
//                root.visible = false;
//                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
//            nextMessageIndex: root.messageStore.nextMessageIndex
//            nextMsgTimestamp: root.messageStore.nextMsgTimestamp
            onClicked: {
                // Not Refactored Yet
//                root.chatsModel.messageView.hideLoadingIndicator();
            }
            onTimerTriggered: {
                // Not Refactored Yet
//                root.chatsModel.requestMoreMessages(Constants.fetchRangeLast24Hours);
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        Rectangle {
            color: "blue"
            width: 100
            height: 100
        }
        // Not Refactored Yet
//        ChannelIdentifierView {
//            store: root.rootStore
//            profileImage: profileImageSource
//            authorCurrentMsg: root.authorCurrentMsg
//        }
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
        id: messageComponent
        NormalMessageView {
            container: root
        }
    }

    Component {
        id: statusUpdateComponent
        StatusUpdateView {
            statusAgeEpoch: root.statusAgeEpoch
            container: root
            store: root.rootStore
            messageContextMenu: root.messageContextMenu
            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
            onChatImageClicked: {
                messageStore.imageClick(image);
            }
            onUserNameClicked: {
                root.parent.clickMessage(isProfileClick);
            }
            onEmojiBtnClicked: {
                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly);
            }
            onClickMessage: {
                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
            onSetMessageActive: {
                root.messageStore.setMessageActive(messageId, active);;
            }
        }
    }

    Component {
        id: compactMessageComponent
        CompactMessageView {
            messageContextMenu: root.messageContextMenu
            container: root
            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
        }
    }
}
