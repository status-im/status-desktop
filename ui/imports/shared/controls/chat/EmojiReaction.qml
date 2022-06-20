import QtQuick 2.13

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
    width: reactionImage.width + Style.current.halfPadding
    height: width
    color: reactedByUser ? Style.current.secondaryBackground :
                           (isHovered ? Style.current.backgroundHover : Style.current.transparent)
    border.width: reactedByUser ? Style.dp(1) : 0
    border.color: Style.current.borderTertiary
    radius: Style.current.radius

    SVGImage {
        id: reactionImage
        width: Style.dp(32)
        height: Style.dp(32)
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
    }

    MouseArea {
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
