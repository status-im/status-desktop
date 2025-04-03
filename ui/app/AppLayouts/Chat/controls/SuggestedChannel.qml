import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

Rectangle {
    id: root
    property string channel: "status"
    signal clicked(string channel)
    border.width: 1
    radius: 8
    width: children[0].width + 10
    height: 32
    border.color: Theme.palette.border
    color: Theme.palette.transparent

    StyledText {
        id: suggestedChannelText
        text: "#" + channel
        font.weight: Font.Medium
        color: Theme.palette.primaryColor1;
        anchors.top: parent.top;
        anchors.topMargin: 5;
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        horizontalAlignment: Text.AlignLeft;
        font.pixelSize: 15
    }

    StatusMouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(channel);
        }
        cursorShape: Qt.PointingHandCursor
    }
}
