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
        //active: rootStore.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatType.oneToOne && isMessage && headerRepeatCondition && !root.isCurrentUser
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top:  dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 20
        icon: senderIcon
        isIdenticon: isSenderIconIdenticon
        onClickMessage: {
            root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
        }
    }

    UsernameLabel {
        id: chatName
        //visible: rootStore.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatType.oneToOne && isMessage && headerRepeatCondition && !root.isCurrentUser
        anchors.leftMargin: 20
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
        displayName: senderDisplayName
        localName: senderLocalName
        amISender: amISender
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
        property bool longChatText: false
        // Not Refactored Yet
//        property bool longChatText: rootStore.chatsModelInst.plainText(messageStore.message).split('\n').some(function (messagePart) {
//            return messagePart.length > maxMessageChars
//        })

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
                case Constants.messageContentType.stickerType:
                    h += stickerId.height;
                    break;
                case Constants.messageContentType.audioType:
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
                case Constants.messageContentType.stickerType:
                    return stickerId.width + (2 * chatBox.chatHorizontalPadding);
                case Constants.messageContentType.imageType:
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
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Style.current.padding
        anchors.top: headerRepeatCondition && !isCurrentUser ? chatImage.top : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.topMargin: 0
        visible: isMessage && contentType !== Constants.messageContentType.transactionType

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
            // Not Refactored Yet
            //stickerData: rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "sticker")
            active: responseTo !== "" && !activityCenterMessage

            Component.onCompleted: {
                let obj = messageStore.getMessageByIdAsJson(messageId)
                if(!obj)
                    return

                amISenderOfTheRepliedMessage = obj.amISender
                repliedMessageContentType = obj.contentType
                repliedMessageSenderIcon = obj.senderIcon
                repliedMessageSenderIconIsIdenticon = obj.isSenderIconIdenticon
                // TODO: not sure about is edited at the moment
                repliedMessageIsEdited = false
                repliedMessageSender = obj.senderDisplayName
                repliedMessageContent = obj.messageText
                repliedMessageImage = obj.messageImage
            }

            onScrollToBottom: {
                // Not Refactored Yet
//                messageStore.scrollToBottom(isit, root.container);
            }
            onClickMessage: {
                // Not Refactored Yet
//                root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
        }


//        Connections {
//            target: rootStore.chatsModelInst.messageView
//            onMessageEdited: {
//                if(chatReply.item)
//                    chatReply.item.messageEdited(editedMessageId, editedMessageContent)
//            }
//        }

        ChatTextView {
            id: chatText
            longChatText: chatBox.longChatText
            anchors.top: chatReply.bottom
            anchors.topMargin: chatReply.active ? chatBox.chatVerticalPadding : 0
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.right: chatBox.longChatText ? parent.right : undefined
            anchors.rightMargin: chatBox.longChatText ? chatBox.chatHorizontalPadding : 0
            store: rootStore
            textField.color: !isCurrentUser ? Style.current.textColor : Style.current.currentUserTextColor
            Connections {
                target: localAccountSensitiveSettings.useCompactMode ? null : chatBox
                onLongChatTextChanged: {
                    chatText.setWidths()
                }
            }

            onLinkActivated: {
                // Not Refactored Yet
//                if (activityCenterMessage) {
//                    clickMessage(false, isSticker, false)
//                }
            }
        }

        Loader {
            id: chatImageContent
            active: isImage && !!image
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
                        isCurrentUser: isCurrentUser
                        onClicked: imageClick(image)
                        container: root.container
                    }
                }
            }
        }

        Loader {
            id: audioPlayerLoader
            active: isAudio
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
            contentType: contentType
            stickerData: sticker
            onLoaded: {
                // Not Refactored Yet
                //messageStore.scrollToBottom(true, root.container)
            }
        }

        MessageMouseArea {
            anchors.fill: parent
            enabled: !chatText.linkHovered
            isActivityCenterMessage: activityCenterMessage
            onClickMessage: {
                // Not Refactored Yet
                //root.parent.clickMessage(isProfileClick, isSticker, isImage)
            }
            onSetMessageActive: {
                setMessageActive(messageId, active);
            }
        }

        RectangleCorner {
            // TODO find a way to show the corner for stickers since they have a border
            visible: isMessage
            isCurrentUser: isCurrentUser
        }
    }

    Loader {
        id: transactionBubbleLoader
        active: contentType === Constants.messageContentType.transactionType
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: isCurrentUser ? 0 : Style.current.halfPadding
        anchors.right: isCurrentUser ? parent.right : undefined
        anchors.rightMargin: Style.current.padding
        sourceComponent: Component {
            TransactionBubbleView {
                store: rootStore
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
        visible: isMessage && !emojiReactionLoader.active
        anchors.top: isImage ? undefined : (linksLoader.active ? linksLoader.bottom : chatBox.bottom)
        anchors.topMargin: isImage ? 0 : 4
        anchors.verticalCenter: isImage ? dateTimeBackground.verticalCenter : undefined
        anchors.right: isImage ? dateTimeBackground.right : (linksLoader.active ? linksLoader.right : chatBox.right)
        anchors.rightMargin: isImage ? 6 : (isCurrentUser ? 5 : Style.current.padding)
        timestamp: timestamp
    }

    SentMessage {
        id: sentMessage
        visible: isCurrentUser && !timeout && !isExpired && isMessage && outgoingStatus === "sent"
        anchors.verticalCenter: chatTime.verticalCenter
        anchors.right: chatTime.left
        anchors.rightMargin: 5
    }

    Retry {
        id: retry
        anchors.verticalCenter: chatTime.verticalCenter
        anchors.right: chatTime.left
        anchors.rightMargin: 5
        isCurrentUser: isCurrentUser
        isExpired: isExpired
        timeout: timeout
        onClicked: {
            // Not Refactored Yet
//            rootStore.chatsModelInst.messageView.resendMessage(chatId, messageId)
        }
    }

    Loader {
        id: linksLoader
        active: !!linkUrls
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Style.current.padding
        anchors.top: chatBox.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottomMargin: Style.current.halfPadding

        sourceComponent: Component {
            LinksMessageView {
                store: rootStore
                linkUrls: linkUrls
                container: root.container
                isCurrentUser: isCurrentUser
            }
        }
    }

    Loader {
        id: emojiReactionLoader
        active: emojiReactions !== ""
        sourceComponent: emojiReactionsComponent
        anchors.left: isCurrentUser ? undefined : chatBox.left
        anchors.right: isCurrentUser ? chatBox.right : undefined
        anchors.leftMargin: isCurrentUser ? Style.current.halfPadding : 1
        anchors.top: chatBox.bottom
        anchors.topMargin: 2
    }

    Component {
        id: emojiReactionsComponent
        EmojiReactionsPanel {
            isMessageActive: isMessageActive
            emojiReactionsModel: emojiReactionsModel
            onSetMessageActive: {
                setMessageActive(messageId, active);;
            }
            // Not Refactored Yet
            //onToggleReaction: rootStore.chatsModelInst.toggleReaction(messageId, emojiID)
        }
    }
}
