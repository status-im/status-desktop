import QtQuick 2.13
import utils 1.0
import shared 1.0
import shared.status 1.0
import shared.views.chat 1.0
import shared.panels.chat 1.0
import shared.controls.chat 1.0

Item {
    id: root
    anchors.top: parent.top
    anchors.topMargin: authorCurrentMsg !== authorPrevMsg ? Style.current.smallPadding : 0
    height: childrenRect.height + this.anchors.topMargin + (dateGroupLbl.visible ? dateGroupLbl.height : 0)
    width: parent.width

    property var store
    property var messageStore
    property string linkUrls: ""
    property bool isCurrentUser: false
    property bool isExpired: false
    property bool timeout: false
    property int contentType: 2
    property var container
    property bool headerRepeatCondition: (authorCurrentMsg !== authorPrevMsg
                                         || shouldRepeatHeader || dateGroupLbl.visible)

    DateGroup {
        id: dateGroupLbl
        previousMessageIndex: prevMessageIndex
        previousMessageTimestamp: prevMsgTimestamp
        messageTimestamp: timestamp
        isActivityCenterMessage: activityCenterMessage
    }

    UserImage {
        id: chatImage
        active: root.store.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne && isMessage && headerRepeatCondition && !root.isCurrentUser
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top:  dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 20
//        isCurrentUser: root.messageStore.isCurrentUser
//        profileImage: root.messageStore.profileImageSource
//        isMessage: root.messageStore.isMessage
//        identiconImageSource: root.messageStore.identicon
        onClickMessage: {
            root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
        }
    }

    UsernameLabel {
        id: chatName
        visible: root.store.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne && isMessage && headerRepeatCondition && !root.isCurrentUser
        anchors.leftMargin: 20
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
//        isCurrentUser: root.messageStore.isCurrentUser
//        userName: root.messageStore.userName
//        localName: root.messageStore.localName
//        displayUserName: root.messageStore.displayUserName
        onClickMessage: {
            root.parent.clickMessage(true, false, false, null, false, false, false);
        }
    }

    Rectangle {
        readonly property int defaultMessageWidth: 400
        readonly property int defaultMaxMessageChars: 54
        readonly property int messageWidth: Math.max(defaultMessageWidth, parent.width / 1.4)
        readonly property int maxMessageChars: (defaultMaxMessageChars * messageWidth) / defaultMessageWidth
        property int chatVerticalPadding: isImage ? 4 : 6
        property int chatHorizontalPadding: isImage ? 0 : 12
        property bool longReply: chatReply.active && repliedMessageContent.length > maxMessageChars
        property bool longChatText: root.store.chatsModelInst.plainText(root.messageStore.message).split('\n').some(function (messagePart) {
            return messagePart.length > maxMessageChars
        })

        id: chatBox
        color: {
            if (isSticker) {
                return Style.current.background 
            }
            if (isImage) {
                return "transparent"
            }
            return isCurrentUser ? Style.current.primary : Style.current.secondaryBackground
        }
        border.color: isSticker ? Style.current.border : Style.current.transparent
        border.width: 1
        height: {
           let h = (3 * chatVerticalPadding)
           switch(contentType){
                case Constants.stickerType:
                    h += stickerId.height;
                    break;
                case Constants.audioType:
                    h += audioPlayerLoader.height;
                    break;
                default:
                    if (!chatImageContent.active && !chatReply.active) {
                        h -= chatVerticalPadding
                    }

                    h += chatText.visible ? chatText.height : 0;
                    h += chatImageContent.active ? chatImageContent.height: 0;
                    h += chatReply.active ? chatReply.height : 0;
           }
           return h;
        }
        width: {
            switch(contentType) {
                case Constants.stickerType:
                    return stickerId.width + (2 * chatBox.chatHorizontalPadding);
                case Constants.imageType:
                    return chatImageContent.width
                default:
                    if (longChatText || longReply) {
                        return messageWidth;
                    }
                    let baseWidth = chatText.width;
                    if (chatReply.visible && chatText.width < chatReply.textFieldWidth) {
                        baseWidth = chatReply.textFieldWidth
                    }

                    if (chatReply.visible && chatText.width < chatReply.authorWidth) {
                        if(chatReply.authorWidth > baseWidth){
                            baseWidth = chatReply.authorWidth + 20
                        }
                    }

                    return baseWidth + 2 * chatHorizontalPadding
            }
        }

        radius: 16
        anchors.left: !root.isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !root.isCurrentUser ? 8 : 0
        anchors.right: !root.isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !root.isCurrentUser ? 0 : Style.current.padding
        anchors.top: headerRepeatCondition && !root.isCurrentUser ? chatImage.top : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.topMargin: 0
        visible: isMessage && contentType !== Constants.transactionType

        ChatReplyPanel {
            id: chatReply
            longReply: chatBox.longReply
            anchors.top: parent.top
            anchors.topMargin: chatReply.visible ? chatBox.chatVerticalPadding : 0
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: chatBox.chatHorizontalPadding
            container: root.container
            chatHorizontalPadding: chatBox.chatHorizontalPadding
            stickerData: root.store.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "sticker")
            active: responseTo !== "" && replyMessageIndex > -1 && !activityCenterMessage
//            To-Do move to store later?
//            isCurrentUser: root.messageStore.isCurrentUser
//            repliedMessageType: root.messageStore.repliedMessageType
//            repliedMessageImage: root.messageStore.repliedMessageImage
//            repliedMessageUserIdenticon: root.messageStore.repliedMessageUserIdenticon
//            repliedMessageIsEdited: root.messageStore.repliedMessageIsEdited
//            repliedMessageUserImage: root.messageStore.repliedMessageUserImage
//            repliedMessageAuthor: root.messageStore.repliedMessageAuthor
//            repliedMessageContent: root.messageStore.repliedMessageContent
//            responseTo: root.messageStore.responseTo
//            onScrollToBottom: {
//                root.messageStore.scrollToBottom(isit, container);
//            }
            onClickMessage: {
                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
        }


        Connections {
            target: root.store.chatsModelInst.messageView
            onMessageEdited: {
                if(chatReply.item)
                    chatReply.item.messageEdited(editedMessageId, editedMessageContent)
            }
        }

        ChatTextView {
            id: chatText
            longChatText: chatBox.longChatText
            anchors.top: chatReply.bottom
            anchors.topMargin: chatReply.active ? chatBox.chatVerticalPadding : 0
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.right: chatBox.longChatText ? parent.right : undefined
            anchors.rightMargin: chatBox.longChatText ? chatBox.chatHorizontalPadding : 0
            store: root.store
            messageStore: root.store.messageStore
            textField.color: !root.isCurrentUser ? Style.current.textColor : Style.current.currentUserTextColor
            Connections {
                target: localAccountSensitiveSettings.useCompactMode ? null : chatBox
                onLongChatTextChanged: {
                    chatText.setWidths()
                }
            }

            onLinkActivated: {
                if (root.messageStore.activityCenterMessage) {
                    clickMessage(false, root.messageStore.isSticker, false)
                }
            }
        }

        Loader {
            id: chatImageContent
            active: root.messageStore.isImage && !!image
            anchors.top: parent.top
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            z: 51

            sourceComponent: Component {
                Item {
                    width: chatImageComponent.width + 2 * chatBox.chatHorizontalPadding
                    height: chatImageComponent.height

                    StatusChatImage {
                        id: chatImageComponent
                        imageSource: image
                        imageWidth: 250
                        isCurrentUser: root.isCurrentUser
                        onClicked: imageClick(image)
                        container: root.container
                    }
                }
            }
        }

        Loader {
            id: audioPlayerLoader
            active: root.messageStore.isAudio
            sourceComponent: audioPlayer
            anchors.verticalCenter: parent.verticalCenter
        }

        Component {
            id: audioPlayer
            AudioPlayerPanel {
                audioSource: audio
            }
        }

        StatusSticker {
            id: stickerId
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
            color: Style.current.transparent
            contentType: root.contentType
            stickerData: root.messageStore.sticker
            onLoaded: {
                root.messageStore.scrollToBottom(true, root.container)
            }
        }

        MessageMouseArea {
            anchors.fill: parent
            enabled: !chatText.linkHovered
            isActivityCenterMessage: root.messageStore.activityCenterMessage
            onClickMessage: {
                root.parent.clickMessage(isProfileClick, root.messageStore.isSticker, root.messageStore.isImage)
            }
            onSetMessageActive: {
                root.messageStore.setMessageActive(root.messageStore.messageId, active);
            }
        }

        RectangleCorner {
            // TODO find a way to show the corner for stickers since they have a border
            visible: root.messageStore.isMessage
            isCurrentUser: root.isCurrentUser
        }
    }

    Loader {
        id: transactionBubbleLoader
        active: contentType === Constants.transactionType
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: isCurrentUser ? 0 : Style.current.halfPadding
        anchors.right: isCurrentUser ? parent.right : undefined
        anchors.rightMargin: Style.current.padding
        sourceComponent: Component {
            TransactionBubbleView {
                store: root.store
            }
        }
    }

    Rectangle {
        id: dateTimeBackground
        visible: isImage
        height: visible ? chatTime.height + Style.current.halfPadding : 0
        width: chatTime.width + 2 * chatTime.anchors.rightMargin +
               (retry.visible ? retry.width + retry.anchors.rightMargin : sentMessage.width + sentMessage.anchors.rightMargin)
        color: Utils.setColorAlpha(Style.current.black, 0.66)
        radius: Style.current.radius
        anchors.bottom: chatBox.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.right: chatBox.right
        anchors.rightMargin: 6
    }

    ChatTimePanel {
        id: chatTime
        visible: root.messageStore.isMessage && !emojiReactionLoader.active
        anchors.top: isImage ? undefined : (linksLoader.active ? linksLoader.bottom : chatBox.bottom)
        anchors.topMargin: isImage ? 0 : 4
        anchors.verticalCenter: isImage ? dateTimeBackground.verticalCenter : undefined
        anchors.right: isImage ? dateTimeBackground.right : (linksLoader.active ? linksLoader.right : chatBox.right)
        anchors.rightMargin: isImage ? 6 : (root.isCurrentUser ? 5 : Style.current.padding)
        //timestamp: root.messageStore.timestamp
    }

    SentMessage {
        id: sentMessage
        visible: root.isCurrentUser && !root.messageStore.timeout && !root.messageStore.isExpired
                 && root.messageStore.isMessage && root.messageStore.outgoingStatus === "sent"
        anchors.verticalCenter: chatTime.verticalCenter
        anchors.right: chatTime.left
        anchors.rightMargin: 5
    }

    Retry {
        id: retry
        anchors.verticalCenter: chatTime.verticalCenter
        anchors.right: chatTime.left
        anchors.rightMargin: 5
        isCurrentUser: root.isCurrentUser
        isExpired: root.isExpired
        timeout: root.timeout
        onClicked: {
            root.store.chatsModelInst.messageView.resendMessage(chatId, messageId)
        }
    }

    Loader {
        id: linksLoader
        active: !!root.linkUrls
        anchors.left: !root.isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !root.isCurrentUser ? 8 : 0
        anchors.right: !root.isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !root.isCurrentUser ? 0 : Style.current.padding
        anchors.top: chatBox.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottomMargin: Style.current.halfPadding

        sourceComponent: Component {
            LinksMessageView {
                store: root.store
                linkUrls: root.linkUrls
                container: root.container
                isCurrentUser: root.isCurrentUser
            }
        }
    }

    Loader {
        id: emojiReactionLoader
        active: emojiReactions !== ""
        sourceComponent: emojiReactionsComponent
        anchors.left: root.isCurrentUser ? undefined : chatBox.left
        anchors.right: root.isCurrentUser ? chatBox.right : undefined
        anchors.leftMargin: root.isCurrentUser ? Style.current.halfPadding : 1
        anchors.top: chatBox.bottom
        anchors.topMargin: 2
    }

    Component {
        id: emojiReactionsComponent
        EmojiReactionsPanel {
//            isMessageActive: root.store.messageStore.isMessageActive
//            emojiReactionsModel: root.store.messageStore.emojiReactionsModel
            onSetMessageActive: {
                root.store.messageStore.setMessageActive(messageId, active);;
            }
            onToggleReaction: root.store.chatsModelInst.toggleReaction(messageId, emojiID)
        }
    }
}
