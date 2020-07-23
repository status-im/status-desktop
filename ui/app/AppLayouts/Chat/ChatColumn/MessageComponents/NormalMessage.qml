import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property bool showImages: messageItem.appSettings.displayChatImages && imageUrls != ""

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
        text: userName
        anchors.leftMargin: 20
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
    }

    Rectangle {
        property int chatVerticalPadding: 7
        property int chatHorizontalPadding: 12
        property bool longReply: chatReply.visible && repliedMessageContent.length > 54
        property bool longChatText: plainText.length > 54

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
                default:
                    h += chatText.visible ? chatText.height : 0;
                    h += chatImageContent.visible ? chatImageContent.height: 0;
                    h += chatReply.visible ? chatReply.height : 0;
           }
           return h;
        }
        width: {
            switch(contentType){
                case Constants.stickerType:
                    return stickerId.width + (2 * chatBox.chatHorizontalPadding);
                case Constants.imageType:
                    return chatImageContent.width
                default:
                    if (longChatText || longReply) {
                        return 400;
                    }
                    let baseWidth = chatText.width;
                    if (chatReply.visible && chatText.width < chatReply.textField.width) {
                        baseWidth = chatReply.textField.width
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
        anchors.topMargin: dateGroupLbl.visible ? Style.current.padding : 0
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
            color:  isCurrentUser ? Style.current.blue : Style.current.lightBlue

        }

        ChatText {
            id: chatText
            anchors.top: chatReply.bottom
            anchors.topMargin: chatBox.chatVerticalPadding
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.right: chatBox.longChatText ? parent.right : undefined
            anchors.rightMargin: chatBox.longChatText ? chatBox.chatHorizontalPadding : 0
            horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            color: !isCurrentUser ? Style.current.textColor : Style.current.currentUserTextColor
        }

        Loader {
            id: chatImageContent
            active: isImage
            sourceComponent: chatImageComponent
        }

        Component {
            id: chatImageComponent
            ChatImage {
                imageSource: image
                imageWidth: 250
            }
        }
        
        Sticker {
            id: stickerId
            anchors.left: parent.left
            anchors.leftMargin: chatBox.chatHorizontalPadding
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
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
        ImageMessage {}
    }
}
