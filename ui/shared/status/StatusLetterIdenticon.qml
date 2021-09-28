import QtQuick 2.13

import utils 1.0
import "../../shared"

Rectangle {
    id: root

    property string chatId
    property string chatName
    property int letterSize: 15

    width: 40
    height: 40
    radius: width / 2

    color: {
        const color = chatsModel.channelView.getChannelColor(chatId)
        if (!color) {
            return Style.current.orange
        }
        return color
    }

    StyledText {
        text: (root.chatName.charAt(0) == "#" ? root.chatName.charAt(1) : root.chatName.charAt(0)).toUpperCase()
        opacity: 0.7
        font.weight: Font.Bold
        font.pixelSize: root.letterSize
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: -1
        anchors.bottomMargin: -2
    }
}
