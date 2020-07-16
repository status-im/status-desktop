import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Rectangle {
    property int chatVerticalPadding: 12
    property int chatHorizontalPadding: 12
    property int imageWidth: 350

    id: imageChatBox
    height: {
        let h = chatVerticalPadding
        for (let i = 0; i < imageRepeater.count; i++) {
            h += imageRepeater.itemAt(i).height
        }
        return h + chatVerticalPadding * imageRepeater.count
    }
    color: isCurrentUser ? Style.current.blue : Style.current.lightBlue
    border.color: "transparent"
    width:  imageWidth + 2 * chatHorizontalPadding
    radius: 16

    Repeater {
        id: imageRepeater
        model: imageUrls.split(" ")

        Image {
            id: imageMessage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: (index == 0) ? parent.top: parent.children[index-1].bottom
            anchors.topMargin: imageChatBox.chatVerticalPadding
            sourceSize.width: imageChatBox.imageWidth
            source: modelData
            onStatusChanged: {
                if (imageMessage.status == Image.Error) {
                    imageMessage.height = 0
                    imageMessage.visible = false
                    imageChatBox.height = 0
                    imageChatBox.visible = false
                } else if (imageMessage.status == Image.Ready) {
                    messageItem.scrollToBottom(true, messageItem)
                }
            }
        }
    }

    RectangleCorner {}
}
