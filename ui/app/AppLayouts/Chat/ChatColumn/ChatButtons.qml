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

    width: chatSendBtn.width + emojiIconContainer.width + 2 * iconPadding

    Button {
        id: chatSendBtn
        visible: txtData.length > 0
        width: 30
        height: 30
        text: ""
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        onClicked: {
            chatsModel.sendMessage(txtData.text, SelectedMessage.messageId)
            txtData.text = ""
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
        anchors.right: txtData.length == 0 ? stickerIconContainer.left : chatSendBtn.left
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.current.radius
        color: hovered ? Style.current.lightBlue : Style.current.transparent

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
            color: emojiIconContainer.hovered || emojiPopup.opened ? Style.current.blue : Style.current.transparent
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
        visible: txtData.length == 0
        width: emojiIcon.width + chatButtonsContainer.iconPadding * 2
        height: emojiIcon.height + chatButtonsContainer.iconPadding * 2
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding - chatButtonsContainer.iconPadding
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.current.radius
        color: hovered ? Style.current.lightBlue : Style.current.transparent

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
            color: stickerIconContainer.hovered || stickersPopup.opened ? Style.current.blue : Style.current.transparent
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

    StickersPopup {
        id: stickersPopup
        width: 360
        height: 440
        x: parent.width - width - 8
        y: parent.height - sendBtns.height - height - 8
        stickerList: chatsModel.stickers
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
