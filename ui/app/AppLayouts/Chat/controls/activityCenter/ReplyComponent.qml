import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: replyComponent

    property int repliedMessageId: wrapper.repliedMessageId
    property string repliedMessageContent: wrapper.repliedMessageContent

    onRepliedMessageIdChanged: {
        wrapper.visible = (repliedMessageId.length > 0)
    }

    SVGImage {
        id: replyIcon
        width: Style.dp(16)
        height: width
        source: Style.svg("reply-small-arrow")
        anchors.left: parent.left
        anchors.verticalCenter:parent.verticalCenter
    }

    StyledTextEdit {
        text: Utils.getReplyMessageStyle(StatusQUtils.Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), StatusQUtils.Emoji.size.small), false)
        textFormat: Text.RichText
        height: Style.dp(18)
        width: implicitWidth > Style.dp(300) ? Style.dp(300) : implicitWidth
        clip: true
        anchors.left: replyIcon.right
        anchors.leftMargin: Style.dp(4)
        color: Style.current.secondaryText
        font.weight: Font.Medium
        font.pixelSize: Style.current.additionalTextSize
        anchors.verticalCenter: parent.verticalCenter
        selectByMouse: true
        readOnly: true
    }
}
