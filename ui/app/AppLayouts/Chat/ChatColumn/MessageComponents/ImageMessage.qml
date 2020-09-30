import QtQuick 2.3
import "../../../../../imports"

Rectangle {
    property int chatVerticalPadding: 12
    property int chatHorizontalPadding: 12
    signal clicked(string source)

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
    width: {
        let w = 0
        for (let i = 0; i < imageRepeater.count; i++) {
            if (imageRepeater.itemAt(i).width > w) {
                w = imageRepeater.itemAt(i).width
            }
        }
        return w + 2 * chatHorizontalPadding
    }

    radius: 16

    Repeater {
        id: imageRepeater
        model: {
            if (!imageUrls) {
                return []
            }

            return imageUrls.split(" ")
        }

        ImageLoader {
            verticalPadding: imageChatBox.chatVerticalPadding
            anchors.top: (index === 0) ? parent.top: parent.children[index-1].bottom
            anchors.topMargin: verticalPadding
            anchors.horizontalCenter: parent.horizontalCenter
            source: modelData
            onClicked: {
                imageChatBox.clicked(source)
            }
        }
    }

    RectangleCorner {}
}
