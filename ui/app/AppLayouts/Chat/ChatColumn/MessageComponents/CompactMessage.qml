import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property int chatHorizontalPadding: 12
    property int chatVerticalPadding: 7
    property bool showImages: messageItem.appSettings.displayChatImages && imageUrls != ""

    id: chatTextItem
    anchors.top: parent.top
    anchors.topMargin: authorCurrentMsg != authorPrevMsg ? Style.current.smallPadding : 0
    height: childrenRect.height + this.anchors.topMargin
    width: parent.width


    // FIXME @jonathanr: Adding this breaks the first line. Need to fix the height somehow
//    DateGroup {
//        id: dateGroupLbl
//    }

    UserImage {
        id: chatImage
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
//        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.top: parent.top
    }

    UsernameLabel {
        id: chatName
        anchors.leftMargin: chatTextItem.chatHorizontalPadding
//        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.top: parent.top
        anchors.left: chatImage.right
    }

    ChatReply {
        id: chatReply
//        anchors.top: chatName.visible ? chatName.bottom : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.topMargin: chatName.visible && this.visible ? chatTextItem.chatVerticalPadding : 0
        anchors.left: chatImage.right
        anchors.leftMargin: chatTextItem.chatHorizontalPadding
        anchors.right: parent.right
        anchors.rightMargin: chatTextItem.chatHorizontalPadding
    }

    ChatText {
        id: chatText
        anchors.top: chatReply.bottom
        anchors.topMargin: chatName.visible && this.visible ? chatTextItem.chatVerticalPadding : 0
        anchors.left: chatImage.right
        anchors.leftMargin: chatTextItem.chatHorizontalPadding
        anchors.right: parent.right
        anchors.rightMargin: chatTextItem.chatHorizontalPadding
    }

    Loader {
        id: chatImageContent
        active: isImage
        sourceComponent: chatImageComponent
        anchors.left: chatImage.right
        anchors.leftMargin: 8
        anchors.top: chatReply.bottom
    }

    Component {
        id: chatImageComponent
        ChatImage {
            imageSource: image
            imageWidth: 200
        }
    }

    Rectangle {
        id: stickerContainer
        visible: contentType === Constants.stickerType
        color: Style.current.transparent
        border.color: Style.current.lightGrey
        border.width: 1
        radius: 16
        width: stickerId.width
        height: stickerId.height
        anchors.left: chatText.left
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.topMargin: this.visible && chatName.visible ? chatTextItem.chatVerticalPadding : 0

        Sticker {
            id: stickerId
            visible: stickerContainer.visible
        }
    }

    MessageMouseArea {
        anchors.fill: stickerContainer.visible ? stickerContainer : chatText
    }

    // TODO show date for not the first messsage (on hover maybe)
    ChatTime {
        id: chatTime
        visible: authorCurrentMsg != authorPrevMsg
        anchors.verticalCenter: chatName.verticalCenter
        anchors.left: chatName.right
        anchors.leftMargin: Style.current.padding
    }

    SentMessage {
        id: sentMessage
        visible: isCurrentUser && !timeout && isMessage && outgoingStatus !== "sent"
        anchors.verticalCenter: chatTime.verticalCenter
        anchors.left: chatTime.right
        anchors.leftMargin: 8
    }

    Retry {
        id: retry
        anchors.right: chatTime.right
        anchors.rightMargin: 5
    }

    Loader {
        id: imageLoader
        active: showImages
        sourceComponent: imageComponent
        anchors.left: chatImage.right
        anchors.leftMargin: 8
        anchors.top: chatText.bottom
    }

    Component {
        id: imageComponent
        ImageMessage {
            color: Style.current.transparent
            chatHorizontalPadding: 0
        }
    }

    Loader {
        id: audioPlayerLoader
        active: isAudio
        sourceComponent: audioPlayer
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.left: chatImage.right
    }

    Component {
        id: audioPlayer
        AudioPlayer {
            audioSource: audio
        }
    }
}
