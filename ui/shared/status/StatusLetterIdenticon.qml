import QtQuick 2.13
import "../../imports"
import "../../shared"

Rectangle {
    id: root

    property string chatName

    width: 40
    height: 40
    radius: width / 2

    color: {
        const color = chatsModel.getChannelColor(root.chatName.startsWith("#") ? root.chatName.substr(1) : root.chatName)
        if (!color) {
            return Style.current.orange
        }
        return color
    }

    StyledText {
        text: (root.chatName.charAt(0) == "#" ? root.chatName.charAt(1) : root.chatName.charAt(0)).toUpperCase()
        opacity: 0.7
        font.weight: Font.Bold
        font.pixelSize: root.isCompact ? 14 : 21
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
