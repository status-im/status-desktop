import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Rectangle {
    property alias textField: lblReplyMessage
    property bool longReply: false

    id: chatReply
    color:  Style.current.lightBlue
    visible: responseTo != "" && replyMessageIndex > -1
    // childrenRect.height shows a binding loop for soem reason, so we use heights instead
    height: this.visible ? lblReplyAuthor.height + lblReplyMessage.height + 5 + 8 : 0

    StyledTextEdit {
        id: lblReplyAuthor
        text: "↳" + repliedMessageAuthor
        color: Style.current.darkGrey
        readOnly: true
        selectByMouse: true
        wrapMode: Text.Wrap
        anchors.left: parent.left
        anchors.right: parent.right
    }

    StyledTextEdit {
        id: lblReplyMessage
        anchors.top: lblReplyAuthor.bottom
        anchors.topMargin: 5
        text: Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), "26x26");
        textFormat: Text.RichText
        color: Style.current.darkGrey
        readOnly: true
        selectByMouse: true
        wrapMode: Text.Wrap
        anchors.left: parent.left
        anchors.right: chatReply.longReply ? parent.right : undefined
        z: 51
    }

    Separator {
        anchors.top: lblReplyMessage.bottom
        anchors.topMargin: 8
        anchors.left: lblReplyMessage.left
        anchors.right: lblReplyMessage.right
        anchors.rightMargin: chatTextItem.chatHorizontalPadding
        color: Style.current.darkGrey
    }
}
