import QtQuick 2.4

import StatusQ.Core 0.1

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

Badge {
    id: root

    property string repliedMessageContent

    signal replyClicked()

    SVGImage {
        id: replyIcon
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: width
        source: Style.svg("reply-small-arrow")
    }

    StatusBaseText {
        anchors.left: replyIcon.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 300)
        text: repliedMessageContent
        maximumLineCount: 1
        elide: Text.ElideRight
        font.pixelSize: 13

        MouseArea {
            id: replyArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.replyClicked()
        }
    }
}
