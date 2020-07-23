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
        model: {
            if (!imageUrls) {
                return []
            }

            return imageUrls.split(" ")
        }

        Item {
            id: imageContainer
            width: loadingImage.visible ? loadingImage.width : imageMessage.width
            height: loadingImage.visible ? loadingImage.height : imageMessage.paintedHeight
            anchors.top: (index == 0) ? parent.top: parent.children[index-1].bottom
            anchors.topMargin: imageChatBox.chatVerticalPadding

            Rectangle {
                id: loadingImage
                property bool hasError: false
                width: hasError ? 200 : 400
                height: hasError ? 75 : 400
                border.width: 1
                border.color: Style.current.border
                radius: Style.current.radius

                StyledText {
                    text: loadingImage.hasError ? qsTr("Error loading the image") : qsTr("Loading image...")
                    color: loadingImage.hasError ? Style.current.red : Style.current.textColor
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Image {
                id: imageMessage
                sourceSize.width: imageChatBox.imageWidth
                source: modelData
                onStatusChanged: {
                    if (imageMessage.status === Image.Error) {
                        loadingImage.hasError = true
                        imageMessage.height = 0
                        imageMessage.source = ""
                        imageMessage.visible = false
                    } else if (imageMessage.status === Image.Ready) {
                        loadingImage.visible = false
                        scrollToBottom(true, messageItem)
                    }
                }
            }
        }
    }

    RectangleCorner {}
}
