import QtQuick 2.13
import "../../../../imports"

Rectangle {
    property string channel: "status"

    border.width: 1
    radius: 8
    width: children[0].width + 10
    height: 32
    border.color: Theme.grey
    Text {
        id: suggestedChannelText
        text: "#" + channel
        font.weight: Font.Medium
        color: Theme.blue;
        anchors.top: parent.top;
        anchors.topMargin: 5;
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        horizontalAlignment: Text.AlignLeft;
        font.pixelSize: 15
    }

    MouseArea {
        anchors.fill: parent
        onClicked: chatsModel.joinChat(channel, Constants.chatTypePublic)
        cursorShape: Qt.PointingHandCursor
    }
}
