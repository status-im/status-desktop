import QtQuick 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../shared/status/core"

import "../panels"
import "../views"
import "../controls"
import "../controls/messages"
import utils 1.0

//TODO RE-WRITE THIS COMPONENT
Item {
    id: root
    width: parent.width
    anchors.right: !messageStore.isCurrentUser ? undefined : parent.right
    height: visible ? childrenRect.height : 0
    z: (typeof chatLogView === "undefined") ? 1 : (chatLogView.count - index)

    ////////////////////////////////////////////////
    //TODO REMOVE
    property string fromAuthor: "0x0011223344556677889910"
    property string userName: "Jotaro Kujo"
    property string alias: ""
    property string localName: ""
    property string message: "That's right. We're friends...  Of justice, that is."
    property string plainText: "That's right. We're friends...  Of justice, that is."
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAGQAQMAAAC6caSPAAAABlBMVEXMzMz////TjRV2AAAAAWJLR0QB/wIt3gAAACpJREFUGBntwYEAAAAAw6D7Uw/gCtUAAAAAAAAAAAAAAAAAAAAAAAAAgBNPsAABAjKCqQAAAABJRU5ErkJggg=="
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
    property string displayUserName: {
        if (isCurrentUser) {
            //% "You"
            return qsTrId("You")
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
    property bool isStatusUpdate: false
    property int statusAgeEpoch: 0

    property int replyMessageIndex: chatsModel.messageView.messageList.getMessageIndex(responseTo);
    property string repliedMessageAuthor: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "userName") : "";
    property string repliedMessageAuthorPubkey: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "publicKey") : "";
    property bool repliedMessageAuthorIsCurrentUser: replyMessageIndex > -1 ? repliedMessageAuthorPubkey === profileModel.profile.pubKey : "";
    property bool repliedMessageIsEdited: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "isEdited") === "true" : false;
    property string repliedMessageContent: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "message") : "";
    property int repliedMessageType: replyMessageIndex > -1 ? parseInt(chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "contentType")) : 0;
    property string repliedMessageImage: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "image") : "";
    property string repliedMessageUserIdenticon: replyMessageIndex > -1 ? chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "identicon") : "";
    property string repliedMessageUserImage: replyMessageIndex > -1 ? appMain.getProfileImage(repliedMessageAuthorPubkey, repliedMessageAuthorIsCurrentUser , false) || "" : "";

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
                if (!byEmoji[reaction.emojiId].currentUserReacted && reaction.from === profileModel.profile.pubKey) {
                    byEmoji[reaction.emojiId].currentUserReacted = true
                }

            })
            return Object.values(byEmoji)
        } catch (e) {
            console.error('Error parsing emoji reactions', e)
            return []
        }
    }
    property var clickMessage: function(isProfileClick, isSticker = false, isImage = false, image = null, emojiOnly = false, hideEmojiPicker = false, isReply = false, isRightClickOnImage = false, imageSource = "") {
        if (placeholderMessage || activityCenterMessage) {
            return
        }

        if (!isProfileClick) {
            SelectedMessage.set(messageId, fromAuthor);
        }

        messageContextMenu.messageId = root.messageId
        messageContextMenu.contentType = root.contentType
        messageContextMenu.linkUrls = root.linkUrls;
        messageContextMenu.isProfile = !!isProfileClick;
        messageContextMenu.isCurrentUser = root.isCurrentUser
        messageContextMenu.isText = root.isText
        messageContextMenu.isSticker = isSticker;
        messageContextMenu.emojiOnly = emojiOnly;
        messageContextMenu.hideEmojiPicker = hideEmojiPicker;
        messageContextMenu.pinnedMessage = pinnedMessage;
        messageContextMenu.isCurrentUser = isCurrentUser;
        messageContextMenu.isRightClickOnImage = isRightClickOnImage
        messageContextMenu.imageSource = imageSource
        messageContextMenu.onClickEdit = function() {root.isEdit = true}

        if (isReply) {
            let nickname = appMain.getUserNickname(repliedMessageAuthor)
            messageContextMenu.show(repliedMessageAuthor, repliedMessageAuthorPubkey, repliedMessageUserImage || repliedMessageUserIdenticon, plainText, nickname, emojiReactionsModel);
        } else {
            let nickname = appMain.getUserNickname(fromAuthor)
            messageContextMenu.show(userName, fromAuthor, root.profileImageSource || identicon, plainText, nickname, emojiReactionsModel);
        }

         messageContextMenu.x = messageContextMenu.setXPosition()
         messageContextMenu.y = messageContextMenu.setYPosition()
    }
    /////////////////////////////////////////////


    property var rootStore
    property var messageStore
    function startMessageFoundAnimation() {
        messageLoader.item.startMessageFoundAnimation();
    }

    Connections {
        enabled: !messageStore.placeholderMessage
        target: rootStore.profileModelInst.contacts.list
        onContactChanged: {
            if (rootStore.profileModelInst.profile.pubkey === messageStore.fromAuthor) {
                const img = appMain.getProfileImage(messageStore.userPubKey, messageStore.isCurrentUser, messageStore.useLargeImage)
                if (img) {
                    messageStore.profileImageSource = img
                }
            } else if (messageStore.replyMessageIndex > -1 && pubkey === messageStore.repliedMessageAuthorPubkey) {
                const imgReply = appMain.getProfileImage(messageStore.repliedMessageAuthorPubkey, messageStore.repliedMessageAuthorIsCurrentUser, false)
                if (imgReply) {
                    messageStore.repliedMessageUserImage = imgReply
                }
            }
        }
    }

    Connections {
        target: rootStore.chatsModelInst.messageView
        onHideMessage: {
            // This hack is used because message_list deleteMessage sometimes does not remove the messages (there might be an issue with the delegate model)
            if(mId === messageStore.messageId){
                root.visible = 0;
                root.height = 0;
            }
        }
    }

    Loader {
        id: messageLoader
        width: parent.width
        sourceComponent: {
            switch(messageStore.contentType) {
                case Constants.chatIdentifier:
                    return channelIdentifierComponent
                case Constants.fetchMoreMessagesButton:
                    return fetchMoreMessagesButtonComponent
                case Constants.systemMessagePrivateGroupType:
                    return privateGroupHeaderComponent
                case Constants.gapType:
                    return gapComponent
                default:
                    return messageStore.isStatusUpdate ? statusUpdateComponent :
                                            (appSettings.useCompactMode ? compactMessageComponent : messageComponent)
            }
        }
    }

    Component {
        id: gapComponent
        GapComponent {
            onClicked: {
                rootStore.chatsModelInst.messageView.fillGaps(messageStore.messageId)
                root.visible = false;
                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
            nextMessageIndex: root.messageStore.nextMessageIndex
            nextMsgTimestamp: root.messageStore.nextMsgTimestamp
            onClicked: {
                rootStore.chatsModelInst.messageView.hideLoadingIndicator();
            }
            onTimerTriggered: {
                rootStore.chatsModelInst.requestMoreMessages(Constants.fetchRangeLast24Hours);
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifierView {
            authorCurrentMsg: messageStore.authorCurrentMsg
            profileImage: messageStore.profileImageSource
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
            visible: messageStore.isStatusMessage
            font.pixelSize: 14
            color: Style.current.secondaryText
            width:  parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
            topPadding: messageStore.prevMessageIndex === 1 ? Style.current.bigPadding : 0
        }
    }

    Component {
        id: messageComponent
        NormalMessageView {
            store: root.rootStore
            messageStore: root.messageStore
            linkUrls: messageStore.linkUrls
            isCurrentUser: messageStore.isCurrentUser
            contentType: messageStore.contentType
            container: root
        }
    }

    Component {
        id: statusUpdateComponent
        StatusUpdatePanel {
            container: root
            statusAgeEpoch: messageStore.statusAgeEpoch
            emojiReactionsModel: messageStore.emojiReactionsModel
            messageContextMenu: messageStore.messageContextMenu
            timestamp: messageStore.timestamp
            isCurrentUser: messageStore.isCurrentUser
            isMessageActive: messageStore.isMessageActive
            displayUserName: messageStore.displayUserName
            userName: messageStore.userName
            isImage: messageStore.isImage
            isMessage: messageStore.isMessage
            profileImageSource: messageStore.profileImageSource
            userIdenticon: messageStore.identicon
            onAddEmoji: {
                root.parent.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
            onChatImageClicked: {
                messageStore.imageClick(image);
            }
            onUserNameChanged: {
                root.parent.clickMessage(isProfileClick);
            }
            onEmojiBtnClicked: {
                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly);
            }
            onClickMessage: {
                root.parent.lickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
            onSetMessageActive: {
                root.messageStore.setMessageActive(messageId, active);;
            }
        }
    }

    Component {
        id: compactMessageComponent
        CompactMessageView {
            store: root.rootStore
            messageStore: root.messageStore
            linkUrls: messageStore.linkUrls
            isCurrentUser: messageStore.isCurrentUser
            contentType: messageStore.contentType
            showEdit: messageStore.showEdit
            container: root
            messageContextMenu: messageStore.messageContextMenu
            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
        }
    }
}
