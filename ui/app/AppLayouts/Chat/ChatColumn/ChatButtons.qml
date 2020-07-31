import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../components"

Item {
    property int iconPadding: 6
    property var addToChat: function () {}

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
            if(chatColumn.isImage){
                chatsModel.sendImage(sendImageArea.image);
            }

            if(txtData.text.trim() > 0){
                chatsModel.sendMessage(txtData.text.trim(), chatColumn.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(txtData.text) ? Constants.emojiType : Constants.messageType)
                txtData.text = "";
            }

            chatColumn.hideExtendedArea();
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

    Rectangle {
        property bool hovered: false

        id: emojiIconContainer
        width: emojiIcon.width + chatButtonsContainer.iconPadding * 2
        height: emojiIcon.height + chatButtonsContainer.iconPadding * 2
        anchors.right: {
            if(stickerIconContainer.visible) return stickerIconContainer.left;
            if(imageIconContainer.visible) return imageIconContainer.left;
            return chatSendBtn.left;
        }
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.current.radius
        color: hovered ? Style.current.secondaryBackground : Style.current.transparent

        SVGImage {
            id: emojiIcon
            visible: txtData.length == 0
            width: 20
            height: 20
            // fillMode: Image.PreserveAspectFit
            source: "../../../img/emojiBtn.svg"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ColorOverlay {
            anchors.fill: emojiIcon
            source: emojiIcon
            color: emojiIconContainer.hovered || emojiPopup.opened ? Style.current.blue : Style.current.darkGrey
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
              emojiIconContainer.hovered = true
            }
            onExited: {
              emojiIconContainer.hovered = false
            }
            onClicked: {
                if (emojiPopup.opened) {
                    emojiPopup.close()
                } else {
                    emojiPopup.open()
                }
            }
        }
    }

    Rectangle {
        property bool hovered: false

        id: stickerIconContainer
        visible: !chatColumn.isExtendedInput && txtData.length == 0
        width: emojiIcon.width + chatButtonsContainer.iconPadding * 2
        height: emojiIcon.height + chatButtonsContainer.iconPadding * 2
        anchors.right: imageIconContainer.visible ? imageIconContainer.left : parent.right
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding * (imageIconContainer.visible ? 2 : 1)
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.current.radius
        color: hovered ? Style.current.secondaryBackground : Style.current.transparent

        Image {
            id: stickersIcon
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
            source: "../../../img/stickers_icon.svg"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

        }
        ColorOverlay {
            anchors.fill: stickersIcon
            source: stickersIcon
            color: stickerIconContainer.hovered || stickersPopup.opened ? Style.current.blue : Style.current.darkGrey
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
              stickerIconContainer.hovered = true
            }
            onExited: {
              stickerIconContainer.hovered = false
            }
            onClicked: {
                 if (stickersPopup.opened) {
                     stickersPopup.close()
                 } else {
                     stickersPopup.open()
                 }
            }
        }
    }

    Rectangle {
        property bool hovered: false
        visible: !chatColumn.isExtendedInput && (chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne)
        id: imageIconContainer
        width: emojiIcon.width + chatButtonsContainer.iconPadding * 2
        height: emojiIcon.height + chatButtonsContainer.iconPadding * 2
        anchors.right: chatSendBtn.visible ? chatSendBtn.left : parent.right
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.current.radius
        color: hovered ? Style.current.secondaryBackground : Style.current.transparent

        Image {
            id: imageIcon
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
            source: "../../../img/images_icon.svg"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

        }
        ColorOverlay {
            anchors.fill: imageIcon
            source: imageIcon
            color: imageIconContainer.hovered ? Style.current.blue : Style.current.darkGrey
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
              imageIconContainer.hovered = true
            }
            onExited: {
              imageIconContainer.hovered = false
            }
            onClicked: {
                imageDialog.open();
            }
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
