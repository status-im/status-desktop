import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property bool showImages: messageItem.appSettings.displayChatImages && imageUrls != ""

    id: chatTextItem
    anchors.top: parent.top
    anchors.topMargin: authorCurrentMsg != authorPrevMsg ? Style.current.smallPadding : 0
    height: childrenRect.height + this.anchors.topMargin
    width: parent.width

    DateGroup {
        id: dateGroupLbl
    }

    UserImage {
        id: chatImage
        visible: (isMessage || isEmoji) && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top:  dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 20
    }

    UsernameLabel {
        id: chatName
        visible: (isMessage || isEmoji) && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        text: userName
        anchors.leftMargin: 20
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
    }

    Rectangle {
        property int chatVerticalPadding: 7
        property int chatHorizontalPadding: 12

        id: chatBox
        color: isSticker ? Style.current.background  : (isCurrentUser ? Style.current.blue : Style.current.secondaryBackground)
        border.color: isSticker ? Style.current.border : Style.current.transparent
        border.width: 1
        height: (3 * chatVerticalPadding) + (contentType == Constants.stickerType ? stickerId.height : (chatText.height + chatReply.height))
        width: {
            switch(contentType){
                case Constants.stickerType:
                    return stickerId.width + (2 * chatBox.chatHorizontalPadding);
                default:
                    return plainText.length > 54 ? 400 : chatText.width + 2 * chatHorizontalPadding
            }
        }

        radius: 16
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Style.current.padding
        anchors.top: authorCurrentMsg != authorPrevMsg && !isCurrentUser ? chatImage.top : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.topMargin: 0
        visible: isMessage || isEmoji

        ChatReply {
            id: chatReply
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
            anchors.leftMargin: parent.chatHorizontalPadding
            anchors.right: plainText.length > 52 ? parent.right : undefined
            anchors.rightMargin: plainText.length > 52 ? parent.chatHorizontalPadding : 0
            horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            color: !isCurrentUser ? Style.current.textColor : Style.current.currentUserTextColor
        }

        Sticker {
            id: stickerId
            anchors.left: parent.left
            anchors.leftMargin: parent.chatHorizontalPadding
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
        }

        MessageMouseArea {
            anchors.fill: parent
        }

        RectangleCorner {
            // TODO find a way to show the corner for stickers since they have a border
            visible: isMessage || isEmoji
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
