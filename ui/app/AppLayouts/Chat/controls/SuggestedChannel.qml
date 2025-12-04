import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared
import shared.panels

Rectangle {
    id: root
    property string channel: "status"
    signal clicked(string channel)
    border.width: 1
    radius: 8
    width: children[0].width + 10
    height: 32
    border.color: Theme.palette.border
    color: StatusColors.transparent

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
        font.pixelSize: Theme.primaryTextFontSize
    }

    StatusMouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(channel);
        }
        cursorShape: Qt.PointingHandCursor
    }
}
