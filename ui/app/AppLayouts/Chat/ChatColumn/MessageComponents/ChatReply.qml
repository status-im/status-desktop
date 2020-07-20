import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Rectangle {
    id: chatReply
    color:  Style.current.lightBlue
    visible: responseTo != "" && replyMessageIndex > -1
    // childrenRect.height shows a binding loop for soem reason, so we use heights instead
    height: this.visible ? lblReplyAuthor.height + ((repliedMessageType === Constants.imageType ? imgReplyImage.height : lblReplyMessage.height) + 5 + 8) : 0

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

    ChatImage {
        id: imgReplyImage
        visible: repliedMessageType == Constants.imageType
        imageWidth: 50
        imageSource: repliedMessageImage
        anchors.top: lblReplyAuthor.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        chatHorizontalPadding: 0
    }

    StyledTextEdit {
        id: lblReplyMessage
        visible: repliedMessageType != Constants.imageType
        anchors.top: lblReplyAuthor.bottom
        anchors.topMargin: 5
        text: Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), "26x26");
        textFormat: Text.RichText
        color: Style.current.darkGrey
        readOnly: true
        selectByMouse: true
        wrapMode: Text.Wrap
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Separator {
        anchors.top: repliedMessageType == Constants.imageType ? imgReplyImage.bottom : lblReplyMessage.bottom
        anchors.topMargin: repliedMessageType == Constants.imageType ? 15 : 8
        anchors.left: lblReplyMessage.left
        anchors.right: lblReplyMessage.right
        anchors.rightMargin: chatTextItem.chatHorizontalPadding
        color: Style.current.darkGrey
    }
}
