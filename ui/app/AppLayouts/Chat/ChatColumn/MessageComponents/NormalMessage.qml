import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property bool showImages: appSettings.displayChatImages && imageUrls != ""

    id: chatTextItem
    anchors.top: parent.top
    anchors.topMargin: authorCurrentMsg != authorPrevMsg ? Style.current.smallPadding : 0
    height: childrenRect.height + this.anchors.topMargin + (dateGroupLbl.visible ? dateGroupLbl.height : 0)
    width: parent.width

    DateGroup {
        id: dateGroupLbl
    }

    UserImage {
        id: chatImage
        visible: chatsModel.activeChannel.chatType !== Constants.chatTypeOneToOne && isMessage && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top:  dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 20
    }

    UsernameLabel {
        id: chatName
        visible: chatsModel.activeChannel.chatType !== Constants.chatTypeOneToOne && isMessage && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        anchors.leftMargin: 20
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
    }

    Rectangle {
        property int chatVerticalPadding: 7
        property int chatHorizontalPadding: 12
        property bool longReply: chatReply.visible && repliedMessageContent.length > 54
        property bool longChatText: chatsModel.plainText(message).length > 54

        id: chatBox
        color: isSticker ? Style.current.background  : (isCurrentUser ? Style.current.blue : Style.current.secondaryBackground)
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
                        return 400;
                    }
                    let baseWidth = chatText.width;
                    if (chatReply.visible && chatText.width < chatReply.textFieldWidth) {
                        baseWidth = chatReply.textFieldWidth
                    }
                    return baseWidth + 2 * chatHorizontalPadding
            }
        }

        radius: 16
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Style.current.padding
        anchors.top: authorCurrentMsg != authorPrevMsg && !isCurrentUser ? chatImage.top : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.topMargin: 0
        visible: isMessage

        ChatReply {
            id: chatReply
            longReply: chatBox.longReply
            anchors.top: parent.top
            anchors.topMargin: chatReply.visible ? chatBox.chatVerticalPadding : 0
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: chatBox.chatHorizontalPadding
        }

        ChatText {
            id: chatText
            longChatText: chatBox.longChatText
            anchors.top: chatReply.bottom
            anchors.topMargin: chatReply.active ? chatBox.chatVerticalPadding : 0
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.right: chatBox.longChatText ? parent.right : undefined
            anchors.rightMargin: chatBox.longChatText ? chatBox.chatHorizontalPadding : 0
            textField.horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            textField.color: !isCurrentUser ? Style.current.textColor : Style.current.currentUserTextColor
        }

        Loader {
            id: chatImageContent
            active: isImage && !!image
            anchors.top: parent.top
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding

            sourceComponent: Component {
                Item {
                    width: chatImageComponent.width + 2 * chatBox.chatHorizontalPadding
                    height: chatImageComponent.height
                    ChatImage {
                        id: chatImageComponent
                        imageSource: image
                        imageWidth: 250
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
            AudioPlayer {
                audioSource: audio
            }
        }

        Sticker {
            id: stickerId
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
            color: Style.current.transparent
        }

        MessageMouseArea {
            anchors.fill: parent
        }

        RectangleCorner {
            // TODO find a way to show the corner for stickers since they have a border
            visible: isMessage
        }
    }

    ChatTime {
        id: chatTime
        anchors.top: showImages ? imageLoader.bottom : chatBox.bottom
        anchors.topMargin: 4
        anchors.bottomMargin: Style.current.padding
        anchors.right: showImages ? imageLoader.right : chatBox.right
        anchors.rightMargin: isCurrentUser ? 5 : Style.current.padding
    }

    SentMessage {
        id: sentMessage
        visible: isCurrentUser && !timeout && isMessage && outgoingStatus !== "sent"
        anchors.top: chatTime.top
        anchors.bottomMargin: Style.current.padding
        anchors.right: chatTime.left
        anchors.rightMargin: 5
    }

    Retry {
        id: retry
        anchors.top: chatTime.top
        anchors.right: chatTime.left
        anchors.rightMargin: 5
        anchors.bottomMargin: Style.current.padding
    }

    Loader {
        id: imageLoader
        active: showImages
        sourceComponent: imageComponent
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Style.current.padding
        anchors.top: chatBox.bottom
        anchors.topMargin: Style.current.smallPadding
    }

    Component {
        id: imageComponent
        ImageMessage {
            onClicked: {
              chatTextItem.clickMessage(false, false, true, source)
            }
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
        anchors.topMargin: Style.current.smallPadding

        sourceComponent: Component {
            LinksMessage {}
        }
    }

    Loader {
        id: emojiReactionLoader
        active: emojiReactions !== ""
        sourceComponent: emojiReactionsComponent
        anchors.left: !isCurrentUser ? chatBox.left : undefined
        anchors.right: !isCurrentUser ? undefined : chatBox.right
        anchors.top: chatBox.bottom
        anchors.topMargin: 2
    }

    Component {
        id: emojiReactionsComponent
        EmojiReactions {}
    }
}
