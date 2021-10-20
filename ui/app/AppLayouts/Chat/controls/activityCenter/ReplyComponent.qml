import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

Item {
    id: replyComponent

    property int replyMessageIndex: wrapper.replyMessageIndex
    property string repliedMessageContent: wrapper.repliedMessageContent

    onReplyMessageIndexChanged: {
        wrapper.visible = replyMessageIndex > -1
    }

    SVGImage {
        id: replyIcon
        width: 16
        height: 16
        source: Style.svg("reply-small-arrow")
        anchors.left: parent.left
        anchors.verticalCenter:parent.verticalCenter
    }

    StyledTextEdit {
        text: Utils.getReplyMessageStyle(Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), Emoji.size.small), false, localAccountSensitiveSettings.useCompactMode)
        textFormat: Text.RichText
        height: 18
        width: implicitWidth > 300 ? 300 : implicitWidth
        clip: true
        anchors.left: replyIcon.right
        anchors.leftMargin: 4
        color: Style.current.secondaryText
        font.weight: Font.Medium
        font.pixelSize: 13
        anchors.verticalCenter: parent.verticalCenter
        selectByMouse: true
        readOnly: true
    }
}
