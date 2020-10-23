import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property int chatHorizontalPadding: 12
    property int chatVerticalPadding: 7
    property bool showImages: appSettings.displayChatImages && imageUrls != ""

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
        anchors.left: chatText.left
        anchors.leftMargin: 8
        anchors.top: chatReply.bottom

        sourceComponent: Component {
            ChatImage {
                imageSource: image
                imageWidth: 200
            }
        }
    }

    Loader {
        id: stickerLoader
        active: contentType === Constants.stickerType
        anchors.left: chatText.left
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.topMargin: this.visible && chatName.visible ? chatTextItem.chatVerticalPadding : 0

        sourceComponent: Component {
            Rectangle {
                id: stickerContainer
                color: Style.current.transparent
                border.color: Style.current.grey
                border.width: 1
                radius: 16
                width: stickerId.width + 2 * chatTextItem.chatVerticalPadding
                height: stickerId.height + 2 * chatTextItem.chatVerticalPadding

                Sticker {
                    id: stickerId
                    anchors.top: parent.top
                    anchors.topMargin: chatTextItem.chatVerticalPadding
                    anchors.left: parent.left
                    anchors.leftMargin: chatTextItem.chatVerticalPadding
                }
            }
        }
    }

    MessageMouseArea {
        anchors.fill: stickerLoader.active ? stickerLoader : chatText
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
        anchors.left: chatText.left
        anchors.leftMargin: 8
        anchors.top: chatText.bottom

        sourceComponent: Component {
            ImageMessage {
                color: Style.current.transparent
                chatHorizontalPadding: 0
            }
        }
    }

    Loader {
        id: linksLoader
        active: !!linkUrls
        anchors.left: chatText.left
        anchors.leftMargin: 8
        anchors.top: chatText.bottom

        sourceComponent: Component {
            LinksMessage {}
        }
    }

    Loader {
        id: audioPlayerLoader
        active: isAudio
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.left: chatImage.right

        sourceComponent: Component {
            AudioPlayer {
                audioSource: audio
            }
        }
    }

    Loader {
        id: emojiReactionLoader
        active: emojiReactions !== ""
        anchors.top: chatText.bottom
        anchors.left: chatText.left
        anchors.topMargin: active ? 2 : 0

        sourceComponent: Component {
            EmojiReactions {}
        }
    }
}
