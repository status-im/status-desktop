import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../components"
import "./ChatComponents"

Item {
    property int iconPadding: 6
    property var addToChat: function () {}
    property var onSend: function () {}

    id: chatButtonsContainer

    width: {
        var w = chatSendBtn.width + emojiIconContainer.width + 2 * iconPadding
        if(stickerIconContainer.visible) {
            w += stickerIconContainer.width + 2 * iconPadding;
        }
        if(imageIconContainer.visible) {
            w += imageIconContainer.width + 2 * iconPadding;
        }
        return w;
    }

    Button {
        id: chatSendBtn
        visible: txtData.length > 0 || chatColumn.isImage
        width: 30
        height: 30
        text: ""
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
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
        id: emojiIconContainer
        source: "../../../img/emojiBtn.svg"
        anchors.right: {
            if(stickerIconContainer.visible) return stickerIconContainer.left;
            if(imageIconContainer.visible) return imageIconContainer.left;
            return chatSendBtn.left;
        }
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding * 2
        anchors.verticalCenter: parent.verticalCenter
        opened: emojiPopup.opened
        close: function () {
            emojiPopup.close()
        }
        open: function () {
            emojiPopup.open()
        }
    }

    ChatInputButton {
        id: stickerIconContainer
        visible: !chatColumn.isExtendedInput && txtData.length == 0
        source: "../../../img/stickers_icon.svg"
        anchors.right: imageIconContainer.visible ? imageIconContainer.left : parent.right
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding * (imageIconContainer.visible ? 2 : 1)
        anchors.verticalCenter: parent.verticalCenter
        opened: stickersPopup.opened
        close: function () {
            stickersPopup.close()
        }
        open: function () {
            stickersPopup.open()
        }
    }

    ChatInputButton {
        id: imageIconContainer
        visible: !chatColumn.isExtendedInput && (chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne)
        source: "../../../img/images_icon.svg"
        anchors.right: chatSendBtn.visible ? chatSendBtn.left : parent.right
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding
        anchors.verticalCenter: parent.verticalCenter
        opened: imageDialog.visible
        close: function () {
            imageDialog.close()
        }
        open: function () {
            imageDialog.open()
        }
    }

    StickersPopup {
        id: stickersPopup
        width: 360
        height: 440
        x: parent.width - width - 8
        y: parent.height - sendBtns.height - height - 8
        recentStickers: chatsModel.recentStickers
        stickerPackList: chatsModel.stickerPacks
    }

    EmojiPopup {
        id: emojiPopup
        width: 360
        height: 440
        x: parent.width - width - 8
        y: parent.height - sendBtns.height - height - 8
        addToChat: chatButtonsContainer.addToChat
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75}
}
##^##*/
