import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

Rectangle {
    property string channel: "status"
    property var onJoin: function() {}

    border.width: 1
    radius: 8
    width: children[0].width + 10
    height: 32
    border.color: Style.current.border
    color: Style.current.background

    StyledText {
        id: suggestedChannelText
        text: "#" + channel
        font.weight: Font.Medium
        color: Style.current.blue;
        anchors.top: parent.top;
        anchors.topMargin: 5;
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        horizontalAlignment: Text.AlignLeft;
        font.pixelSize: 15
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            chatsModel.joinChat(channel, Constants.chatTypePublic)
            onJoin()
        }
        cursorShape: Qt.PointingHandCursor
    }
}
