import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

Rectangle {
    property alias source: reactionImage.source
    property int emojiId
    property bool reactedByUser: false
    property bool isHovered: false
    signal closeModal()

    id: root
    width: reactionImage.width + Theme.halfPadding
    height: width
    color: reactedByUser ? Theme.palette.secondaryBackground :
                           (isHovered ? Theme.palette.backgroundHover : Theme.palette.transparent)
    border.width: reactedByUser ? 1 : 0
    border.color: Theme.palette.primaryColor1
    radius: Theme.radius

    SVGImage {
        id: reactionImage
        width: 32
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
    }

    StatusMouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: !reactedByUser
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            root.closeModal();
        }
    }
}
