import QtQuick 2.13
import "../../../../../shared"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property int chatHorizontalPadding: 12
    property int chatVerticalPadding: 7
    property string linkUrls: ""
    property int contentType: 2
    property var container
    property bool isCurrentUser: false

    id: root
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
        anchors.leftMargin: root.chatHorizontalPadding
//        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.top: parent.top
        anchors.left: chatImage.right
    }

    ChatReply {
        id: chatReply
//        anchors.top: chatName.visible ? chatName.bottom : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.topMargin: chatName.visible && this.visible ? root.chatVerticalPadding : 0
        anchors.left: chatImage.right
        anchors.leftMargin: root.chatHorizontalPadding
        anchors.right: parent.right
        anchors.rightMargin: root.chatHorizontalPadding
        container: root.container
	chatHorizontalPadding: root.chatHorizontalPadding
    }

    ChatText {
        id: chatText
        anchors.top: chatReply.bottom
        anchors.topMargin: chatName.visible && this.visible ? root.chatVerticalPadding : 0
        anchors.left: chatImage.right
        anchors.leftMargin: root.chatHorizontalPadding
        anchors.right: parent.right
        anchors.rightMargin: root.chatHorizontalPadding
    }

    Loader {
        id: chatImageContent
        active: isImage
        anchors.left: chatText.left
        anchors.leftMargin: 8
        anchors.top: chatReply.bottom
        z: 51

        sourceComponent: Component {
            ChatImage {
                imageSource: image
                imageWidth: 200
                onClicked: root.clickMessage(false, false, true, image)
                container: root.container
            }
        }
    }

    Loader {
        id: stickerLoader
        active: contentType === Constants.stickerType
        anchors.left: chatText.left
        anchors.top: chatName.visible ? chatName.bottom : parent.top
        anchors.topMargin: this.visible && chatName.visible ? root.chatVerticalPadding : 0

        sourceComponent: Component {
            Rectangle {
                id: stickerContainer
                color: Style.current.transparent
                border.color: Style.current.grey
                border.width: 1
                radius: 16
                width: stickerId.width + 2 * root.chatVerticalPadding
                height: stickerId.height + 2 * root.chatVerticalPadding

                Sticker {
                    id: stickerId
                    anchors.top: parent.top
                    anchors.topMargin: root.chatVerticalPadding
                    anchors.left: parent.left
                    anchors.leftMargin: root.chatVerticalPadding
                    contentType: root.contentType
                    container: root.container
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
        visible: isCurrentUser && !timeout && !isExpired && isMessage && outgoingStatus !== "sent"
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
        id: linksLoader
        active: !!root.linkUrls
        anchors.left: chatText.left
        anchors.leftMargin: 8
        anchors.top: chatText.bottom

        sourceComponent: Component {
            LinksMessage {
                linkUrls: root.linkUrls
                container: root.container
                isCurrentUser: root.isCurrentUser
            }
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
