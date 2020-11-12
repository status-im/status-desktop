import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../imports"

Item {
    property int verticalPadding: 0
    property int imageWidth: 350
    property bool isCurrentUser: false
    property url source
    signal clicked(string source)

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
            //% "Error loading the image"
            //% "Loading image..."
            text: loadingImage.hasError ? qsTrId("error-loading-the-image") : qsTrId("loading-image---")
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

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: imageMessage.width
                height: imageMessage.height

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: imageMessage.width
                    height: imageMessage.height
                    radius: 16
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: 32
                    height: 32
                    radius: 4
                    visible: !imageContainer.isCurrentUser
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 32
                    height: 32
                    radius: 4
                    visible: imageContainer.isCurrentUser
                }
            }
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                imageContainer.clicked(imageContainer.source)
            }
        }
    }
}
