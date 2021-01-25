import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"

Item {
    property var clickMessage: function () {}
    property int chatHorizontalPadding: 8
    property int chatVerticalPadding: 7
    property string linkUrls: ""
    property int contentType: 2
    property var container
    property bool isCurrentUser: false
    property bool isHovered: false
    property bool isMessageActive: false

    id: root

    width: parent.width
    height: messageContainer.height

    MouseArea {
        anchors.fill: messageContainer
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked:  messageMouseArea.clicked(mouse)
    }

    ChatButtons {
        parentIsHovered: root.isHovered
        onHoverChanged: root.isHovered = hovered
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        // This is not exactly like the design because the hover becomes messed up with the buttons on top of another Message
        anchors.topMargin: -Style.current.halfPadding
    }

    Loader {
        active: typeof messageContextMenu !== "undefined"
        sourceComponent: Component {
            Connections {
                enabled: root.isMessageActive
                target: messageContextMenu
                onClosed: root.isMessageActive = false
            }
        }
    }

    Rectangle {
        property alias chatText: chatText

        id: messageContainer
        height: childrenRect.height + (chatName.visible || emojiReactionLoader.active ? Style.current.smallPadding : 0)
                + (emojiReactionLoader.active ? emojiReactionLoader.height + Style.current.halfPadding : 0)
        width: parent.width

        color: root.isHovered || isMessageActive ? Style.current.backgroundHover : Style.current.transparent

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
            anchors.topMargin: Style.current.smallPadding
        }

        UsernameLabel {
            id: chatName
            anchors.leftMargin: root.chatHorizontalPadding
            //        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
            anchors.top: chatImage.top
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
            anchors.top: chatReply.active ? chatReply.bottom : chatName.visible ? chatName.bottom : parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            // using a padding instead of a margin let's us select text more easily
            textField.leftPadding: chatImage.anchors.leftMargin + chatImage.width + root.chatHorizontalPadding
            textField.rightPadding: Style.current.bigPadding
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
            id: messageMouseArea
            anchors.fill: stickerLoader.active ? stickerLoader : chatText
        }

        ChatTime {
            id: chatTime
            visible: authorCurrentMsg != authorPrevMsg
            anchors.verticalCenter: chatName.verticalCenter
            anchors.left: chatName.right
            anchors.leftMargin: 4
        }

        SentMessage {
            id: sentMessage
            visible: isCurrentUser && !timeout && !isExpired && isMessage && outgoingStatus !== "sent"
            anchors.verticalCenter: chatTime.verticalCenter
            anchors.left: chatTime.right
            anchors.leftMargin: Style.current.halfPadding
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
    }

    // TODO find a way for this to not eat link hovers
    MouseArea {
        anchors.fill: root
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onEntered: {
            root.isHovered = true
        }
        onExited: {
            if (chatLogView.chatButtonsHovered) {
                return
            }
            root.isHovered = false
        }
    }

    Loader {
        id: emojiReactionLoader
        active: emojiReactions !== ""
        anchors.bottom: messageContainer.bottom
        anchors.bottomMargin: Style.current.smallPadding
        anchors.left: messageContainer.left
        anchors.leftMargin: messageContainer.chatText.textField.leftPadding

        sourceComponent: Component {
            EmojiReactions {
                onHoverChanged: root.isHovered = hovered
            }
        }
    }
}
