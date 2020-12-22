import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../imports"
import "../../../../../shared/status"

Rectangle {
    id: root

    property var clickMessage: function () {}
    anchors.top: parent.top
    anchors.topMargin: 0
    height: (isImage ? chatImageContent.height : chatText.height) + chatName.height + 2* Style.current.padding + (emojiReactions !== "" ? 20 : 0)
    width: parent.width
    radius: Style.current.radius
    color: hovered ? Style.current.border : Style.current.background
    property bool hovered: false
    property var container

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
        formatDateTime: true
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
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                mouse.accepted = false
            }
            onEntered: {
                root.hovered = true
            }
            onExited: {
                root.hovered = false
            }
        }
    }

    Loader {
        id: chatImageContent
        active: isImage
        anchors.left: chatImage.right
        anchors.leftMargin: Style.current.halfPadding
        anchors.top: chatText.bottom
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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: {
            if (!root.hovered) {
                root.hovered = true
            }
        }
        onExited: {
            if (root.hovered) {
              root.hovered = false
            }
        }
    }

    StatusIconButton {
        id: emojiBtn
        visible: root.hovered
        highlighted: visible
        anchors.top: root.top
        anchors.topMargin: -height/2
        anchors.right: root.right
        anchors.rightMargin: Style.current.halfPadding
        highlightedIconColor: Style.current.secondaryText
        highlightedBackgroundColor: Style.current.background
        icon.name: "emoji"
        icon.width: 20
        icon.height: 20
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clickMessage(false, false, false, null, true)
            onEntered: {
                if (!root.hovered) {
                    root.hovered = true
                }
            }
            onExited: {
                if (root.hovered) {
                    root.hovered = false
                }
            }
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
        active: emojiReactions !== ""
        sourceComponent: emojiReactionsComponent
        anchors.left: chatImage.right
        anchors.leftMargin: Style.current.halfPadding
        anchors.top: isImage ? chatImageContent.bottom : chatText.bottom
        anchors.topMargin: Style.current.halfPadding
    }

    Component {
        id: emojiReactionsComponent
        EmojiReactions {}
    }

    Separator {
        anchors.bottom: parent.bottom
        visible: !root.hovered
    }
}
