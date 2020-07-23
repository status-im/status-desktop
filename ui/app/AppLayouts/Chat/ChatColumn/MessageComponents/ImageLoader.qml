import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property int verticalPadding: 0
    property int imageWidth: 350
    property url source

    id: imageContainer
    width: loadingImage.visible ? loadingImage.width : imageMessage.width
    height: loadingImage.visible ? loadingImage.height : imageMessage.paintedHeight

    Rectangle {
        id: loadingImage
        property bool hasError: false
        width: hasError ? 200 : imageContainer.imageWidth
        height: hasError ? 75 : imageContainer.imageWidth
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
        width: sourceSize.width > imageWidth ? imageWidth : sourceSize.width
        fillMode: Image.PreserveAspectFit
        source: imageContainer.source
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
