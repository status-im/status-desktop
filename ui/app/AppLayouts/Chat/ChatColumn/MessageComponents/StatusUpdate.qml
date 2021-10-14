import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../shared/panels"

import utils 1.0
import "../../../../../shared/status"

MouseArea {
    id: root

    property var clickMessage: function () {}
    property bool hovered: containsMouse
    property var container
    property int statusAgeEpoch: 0
    property var messageContextMenu

    anchors.top: parent.top
    anchors.topMargin: 0
    height: (isImage ? chatImageContent.height : chatText.height) + chatName.height + 2* Style.current.padding + (emojiReactionsModel.length ? 20 : 0)
    width: parent.width
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    propagateComposedEvents: true

    signal addEmoji(bool isProfileClick, bool isSticker, bool isImage , var image, bool emojiOnly, bool hideEmojiPicker)

    onClicked: {
        mouse.accepted = false
    }

    Rectangle {
        id: rootRect
        anchors.fill: parent
        radius: Style.current.radius
        color: root.hovered ? Style.current.border : Style.current.background

        UserImage {
            id: chatImage
            active: isMessage || isImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
        }

        UsernameLabel {
            id: chatName
            visible: chatImage.visible
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: chatImage.top
            anchors.left: chatImage.right
            label.font.pixelSize: Style.current.primaryTextFontSize
            z: 51
        }

        ChatTime {
            id: chatTime
            // statusAgeEpoch is used to trigger Qt property update
            // since the returned string will be the same in 99% cases, this should not trigger ChatTime re-rendering
            text: Utils.formatAgeFromTime(timestamp, statusAgeEpoch)
            visible: chatName.visible
            anchors.verticalCenter: chatName.verticalCenter
            anchors.left: chatName.right
            anchors.leftMargin: Style.current.halfPadding
        }

        ChatText {
            id: chatText
            anchors.top: chatName.visible ? chatName.bottom : chatImage.top
            anchors.topMargin: chatName.visible ? 6 : 0
            anchors.left: chatImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
        }

        Loader {
            id: chatImageContent
            active: isImage
            anchors.left: chatImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: chatText.bottom
            z: 51

            sourceComponent: Component {
                StatusChatImage {
                    imageSource: image
                    imageWidth: 200
                    onClicked: imageClick(image)
                    container: root.container
                }
            }
        }

        StatusIconButton {
            id: emojiBtn
            visible: root.hovered
            highlighted: visible
            anchors.top: rootRect.top
            anchors.topMargin: -height / 4
            anchors.right: rootRect.right
            anchors.rightMargin: Style.current.halfPadding
            highlightedIconColor: Style.current.secondaryText
            highlightedBackgroundColor: Style.current.background
            icon.name: "emoji"
            icon.width: 20
            icon.height: 20
            onClicked: {
                // Set parent, X & Y positions for the messageContextMenu
                messageContextMenu.parent = emojiBtn
                messageContextMenu.setXPosition = function() { return -messageContextMenu.width + emojiBtn.width}
                messageContextMenu.setYPosition = function() { return -messageContextMenu.height - 4}
                root.clickMessage(false, false, false, null, true)
            }
        }

        DropShadow {
            anchors.fill: emojiBtn
            horizontalOffset: 0
            verticalOffset: 2
            radius: 10
            samples: 12
            color: "#22000000"
            source: emojiBtn
        }

        Loader {
            id: emojiReactionLoader
            active: emojiReactionsModel.length
            sourceComponent: emojiReactionsComponent
            anchors.left: chatImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: isImage ? chatImageContent.bottom : chatText.bottom
            anchors.topMargin: Style.current.halfPadding
        }

        Component {
            id: emojiReactionsComponent
            EmojiReactions {
                onAddEmojiClicked: {
                    root.addEmoji(false, false, false, null, true, false);
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = emojiReactionLoader
                    messageContextMenu.setXPosition = function() { return (messageContextMenu.parent.x + 4)}
                    messageContextMenu.setYPosition = function() { return (-messageContextMenu.height - 4)}
                }
            }
        }

        Separator {
            anchors.bottom: parent.bottom
            visible: !root.hovered
        }
    }
}
