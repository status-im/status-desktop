import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

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
        anchors.verticalCenter:parent.verticalCenter
        width: 16
        height: width
        source: Style.svg("reply-small-arrow")
    }

    StyledTextEdit {
        id: communityNameText
        width: implicitWidth > 300 ? 300 : implicitWidth
        height: 18
        anchors.left: replyIcon.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: Utils.getReplyMessageStyle(StatusQUtils.Emoji.parse(StatusQUtils.Utils.linkifyAndXSS(repliedMessageContent), 
                                         StatusQUtils.Emoji.size.small), false)
        readOnly: true
        textFormat: Text.RichText
        clip: true
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