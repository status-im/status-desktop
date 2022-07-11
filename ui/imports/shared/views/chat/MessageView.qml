import QtQuick 2.13

import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.panels.chat 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

Loader {
    id: root

    width: parent.width
    z: (typeof chatLogView === "undefined") ? 1 : (chatLogView.count - index)

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
                return compactMessageComponent

        }
    }

    property var store
    property var messageStore
    property var usersStore
    property var contactsStore
    property var messageContextMenu
    property string channelEmoji
    property bool isActiveChannel: false

    property var emojiPopup

    // Once we redo qml we will know all section/chat related details in each message form the parent components
    // without an explicit need to fetch those details via message store/module.
    property bool isChatBlocked: false

    property int itemIndex: -1
    property string messageId: ""
    property string communityId: ""
    property string responseToMessageWithId: ""
    property string senderId: ""
    property string senderDisplayName: ""
    property string senderLocalName: ""
    property string senderIcon: ""
    property bool amISender: false
    property bool senderIsAdded: false
    property int senderTrustStatus: Constants.trustStatus.unknown
    readonly property string senderIconToShow: {
        if ((!senderIsAdded &&
            Global.privacyModuleInst.profilePicturesVisibility !==
            Constants.profilePicturesVisibility.everyone)) {
            return ""
        }
        return senderIcon
    }
    property string message: ""
    property string messageImage: ""
    property string messageTimestamp: ""
    property string messageOutgoingStatus: ""
    property int messageContentType: 1
    property bool pinnedMessage: false
    property string messagePinnedBy: ""
    property var reactionsModel: []
    property string linkUrls: ""
    property bool isInPinnedPopup: false // The pinned popup limits the number of buttons shown
    property var transactionParams

    property int gapFrom: 0
    property int gapTo: 0

    property int prevMessageIndex: -1
    property var prevMessageAsJsonObj
    property int nextMessageIndex: -1
    property var nextMessageAsJsonObj

    property string hoveredMessage
    property string activeMessage
    property bool isHovered: typeof hoveredMessage !== "undefined" && hoveredMessage === messageId
    property bool isMessageActive: typeof activeMessage !== "undefined" && activeMessage === messageId

    property bool editModeOn: false

    function setHovered(messageId, hovered) {
        if (hovered) {
            hoveredMessage = messageId;
        } else if (hoveredMessage === messageId) {
            hoveredMessage = "";
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
        if(!prevMessageAsJsonObj ||
            // The system message for private groups appear as created by the group host, but it shouldn't
            prevMessageAsJsonObj.contentType === Constants.messageContentType.systemMessagePrivateGroupType) {
            return ""
        }

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
    property string emojiReactions: ""
    property bool timeout: false
    property bool hasMention: false
    property bool placeholderMessage: false
    property bool activityCenterMessage: false
    property bool read: true
    property bool forceHoverHandler: false // Used to force the HoverHandler to be active (useful for messages in popups)
    property string replaces: ""
    property bool isEdited: false
    property bool stickersLoaded: false
    //////////////////////////////////////

    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int stickerPack: -1
    property bool isEmoji: contentType === Constants.messageContentType.emojiType
    property bool isImage: contentType === Constants.messageContentType.imageType
    property bool isAudio: contentType === Constants.messageContentType.audioType
    property bool isStatusMessage: contentType === Constants.messageContentType.systemMessagePrivateGroupType
    property bool isSticker: contentType === Constants.messageContentType.stickerType
    property bool isText: contentType === Constants.messageContentType.messageType || contentType === Constants.messageContentType.editType
    property bool isMessage: isEmoji || isImage || isSticker || isText || isAudio
                             || contentType === Constants.messageContentType.communityInviteType || contentType === Constants.messageContentType.transactionType

    property bool isExpired: (outgoingStatus === "sending" && (Math.floor(timestamp) + 180000) < Date.now())
    property int statusAgeEpoch: 0

    signal imageClicked(var image)
    property var scrollToBottom: function () {}

    property var clickMessage: function(isProfileClick,
                                        isSticker = false,
                                        isImage = false,
                                        image = null,
                                        isEmoji = false,
                                        hideEmojiPicker = false,
                                        isReply = false,
                                        isRightClickOnImage = false,
                                        imageSource = "") {

        if (placeholderMessage || activityCenterMessage) {
            return
        }

        messageContextMenu.myPublicKey = userProfile.pubKey
        messageContextMenu.amIChatAdmin = messageStore.amIChatAdmin()
        messageContextMenu.pinMessageAllowedForMembers = messageStore.pinMessageAllowedForMembers()
        messageContextMenu.chatType = messageStore.getChatType()

        messageContextMenu.messageId = root.messageId
        messageContextMenu.messageSenderId = root.senderId
        messageContextMenu.messageContentType = root.messageContentType
        messageContextMenu.pinnedMessage = root.pinnedMessage
        messageContextMenu.canPin = messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins

        messageContextMenu.selectedUserPublicKey = root.senderId
        messageContextMenu.selectedUserDisplayName = root.senderDisplayName
        messageContextMenu.selectedUserIcon = root.senderIconToShow

        messageContextMenu.imageSource = imageSource

        messageContextMenu.isProfile = !!isProfileClick
        messageContextMenu.isRightClickOnImage = isRightClickOnImage
        messageContextMenu.isEmoji = isEmoji
        messageContextMenu.isSticker = isSticker
        messageContextMenu.hideEmojiPicker = hideEmojiPicker

        if(isReply){
            let obj = messageStore.getMessageByIdAsJson(responseTo)
            if(!obj)
                return

            messageContextMenu.messageSenderId = obj.senderId
            messageContextMenu.selectedUserPublicKey = obj.senderId
            messageContextMenu.selectedUserDisplayName = obj.senderDisplayName
            messageContextMenu.selectedUserIcon = obj.senderIconToShow
        }

        messageContextMenu.popup()
    }

    signal showReplyArea(string messageId, string author)


//    function showReactionAuthors(fromAccounts, emojiId) {
//        return root.rootStore.showReactionAuthors(fromAccounts, emojiId)
//    }

    function startMessageFoundAnimation() {
        root.item.startMessageFoundAnimation();
    }
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

    Component {
        id: gapComponent
        GapComponent {
            gapFrom: root.gapFrom
            gapTo: root.gapTo
            onClicked: {
                messageStore.fillGaps(messageId)
                root.visible = false;
                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
            nextMessageIndex: root.nextMessageIndex
            nextMsgTimestamp: root.nextMsgTimestamp
            onTimerTriggered: {
                messageStore.requestMoreMessages();
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifierView {
            chatName: root.senderDisplayName
            chatId: root.messageStore.getChatId()
            chatType: root.messageStore.getChatType()
            chatColor: root.messageStore.getChatColor()
            chatEmoji: root.channelEmoji
            amIChatAdmin: root.messageStore.amIChatAdmin()
            chatIcon: root.senderIconToShow
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
        id: compactMessageComponent

        CompactMessageView {
            container: root
            store: root.store
            message: root.message
            messageStore: root.messageStore
            usersStore: root.usersStore
            contactsStore: root.contactsStore
            messageContextMenu: root.messageContextMenu
            contentType: root.messageContentType
            isChatBlocked: root.isChatBlocked
            isActiveChannel: root.isActiveChannel
            emojiPopup: root.emojiPopup
            senderTrustStatus: root.senderTrustStatus

            communityId: root.communityId
            stickersLoaded: root.stickersLoaded
            sticker: root.sticker
            stickerPack: root.stickerPack
            isMessageActive: root.isMessageActive
            senderIcon: root.senderIconToShow
            amISender: root.amISender
            isHovered: root.isHovered
            editModeOn: root.editModeOn
            linkUrls: root.linkUrls
            isInPinnedPopup: root.isInPinnedPopup
            pinnedMessage: root.pinnedMessage
            canPin: !!messageStore && messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins

            transactionParams: root.transactionParams

            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, isEmoji, hideEmojiPicker)
            }

            onClickMessage: {
                root.clickMessage(isProfileClick, isSticker, isImage, image, isEmoji, hideEmojiPicker, isReply, isRightClickOnImage, imageSource)
            }

            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }

            onReplyClicked: {
                root.showReplyArea(messageId, author)
            }

            onImageClicked: root.imageClicked(image)
        }
    }
}
