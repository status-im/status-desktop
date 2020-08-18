import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../components"
import "./ChatComponents"

Row {
    property int iconPadding: 6
    property var addToChat: function () {}
    property var onSend: function () {}

    id: chatButtonsContainer

    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    spacing: 0

    // ChildrenRect doesn't work with the width being able to change
    width: chatSendBtn.width + emojiIconButton.width +
           stickerIconButton.width + imageIconButton.width + commandIconButton.width

    Button {
        id: chatSendBtn
        visible: txtData.length > 0 || chatColumn.isImage
        width: this.visible ? 30 : 0
        height: this.width
        text: ""
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            onSend();
        }
        background: Rectangle {
            color: parent.enabled ? Style.current.blue : Style.current.grey
            radius: 50
        }
        SVGImage {
            source: "../../../img/arrowUp.svg"
            width: 13
            height: 17
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ChatInputButton {
        id: emojiIconButton
        source: "../../../img/emojiBtn.svg"
        opened: emojiPopup.opened
        close: function () {
            emojiPopup.close()
        }
        open: function () {
            emojiPopup.open()
        }
    }

    ChatInputButton {
        id: stickerIconButton
        visible: !chatColumn.isExtendedInput && txtData.length == 0
        source: "../../../img/stickers_icon.svg"
        opened: stickersPopup.opened
        close: function () {
            stickersPopup.close()
        }
        open: function () {
            stickersPopup.open()
        }
    }

    ChatInputButton {
        id: imageIconButton
        visible: !chatColumn.isExtendedInput && (chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne)
        source: "../../../img/images_icon.svg"
        opened: imageDialog.visible
        close: function () {
            imageDialog.close()
        }
        open: function () {
            imageDialog.open()
        }
    }

    ChatInputButton {
        id: commandIconButton
        visible: !chatColumn.isExtendedInput && chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne
        source: "../../../img/chat-commands.svg"
        opened: chatCommandsPopup.opened
        close: function () {
            chatCommandsPopup.close()
        }
        open: function () {
            chatCommandsPopup.open()
        }
    }

    StickersPopup {
        id: stickersPopup
        width: 360
        height: 440
        x: parent.width - width - Style.current.halfPadding
        y: parent.height - sendBtns.height - height - Style.current.halfPadding
        recentStickers: chatsModel.recentStickers
        stickerPackList: chatsModel.stickerPacks
    }

    EmojiPopup {
        id: emojiPopup
        width: 360
        height: 440
        x: parent.width - width - Style.current.halfPadding
        y: parent.height - sendBtns.height - height - Style.current.halfPadding
        addToChat: chatButtonsContainer.addToChat
    }

    ChatCommandsPopup {
        id: chatCommandsPopup
        x: parent.width - width - Style.current.halfPadding
        y: parent.height - sendBtns.height - height - Style.current.halfPadding
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75}
}
##^##*/
