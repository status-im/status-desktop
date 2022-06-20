import QtQuick 2.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

Rectangle {
    id: root
    property string channel: "status"
    signal clicked(string channel)
    border.width: 1
    radius: Style.dp(8)
    width: children[0].width + Style.dp(10)
    height: Style.dp(32)
    border.color: Style.current.border
    color: Style.current.transparent

    StyledText {
        id: suggestedChannelText
        text: "#" + channel
        font.weight: Font.Medium
        color: Style.current.blue
        anchors.top: parent.top
        anchors.topMargin: Style.dp(5)
        anchors.left: parent.left
        anchors.leftMargin: Style.dp(5)
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: Style.current.primaryTextFontSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(channel);
        }
        cursorShape: Qt.PointingHandCursor
    }
}
