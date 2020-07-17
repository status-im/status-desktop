import QtQuick 2.3
import "../../../../shared"
import "../../../../imports"
import "./MessageComponents"
import "../components"

Item {
    property string fromAuthor: "0x0011223344556677889910"
    property string userName: "Jotaro Kujo"
    property string message: "That's right. We're friends...  Of justice, that is."
    property string plainText: "That's right. We're friends...  Of justice, that is."
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool isCurrentUser: false
    property string timestamp: "1234567"
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int contentType: 2 // constants don't work in default props
    property string chatId: "chatId"
    property string outgoingStatus: ""
    property string responseTo: ""
    property string messageId: ""
    property int prevMessageIndex: -1

    property string authorCurrentMsg: "authorCurrentMsg"
    property string authorPrevMsg: "authorPrevMsg"

    property bool isEmoji: contentType === Constants.emojiType
    property bool isImage: contentType === Constants.imageType
    property bool isMessage: contentType === Constants.messageType || contentType === Constants.stickerType
    property bool isStatusMessage: contentType === Constants.systemMessagePrivateGroupType
    property bool isSticker: contentType === Constants.stickerType

    property int replyMessageIndex: chatsModel.messageList.getMessageIndex(responseTo);
    property string repliedMessageAuthor: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "userName") : "";
    property string repliedMessageContent: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "message") : "";
    property int repliedMessageType: replyMessageIndex > -1 ? parseInt(chatsModel.messageList.getMessageData(replyMessageIndex, "contentType")) : 0;
    property string repliedMessageImage: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "image") : "";

    property var profileClick: function () {}
    property var scrollToBottom: function () {}
    property var appSettings

    id: messageItem
    width: parent.width
    anchors.right: !isCurrentUser ? undefined : parent.right
    height: {
        switch(contentType) {
            case Constants.chatIdentifier:
                return childrenRect.height + 50
            default: return childrenRect.height
        }
    }

    function clickMessage() {
        SelectedMessage.set(messageId, fromAuthor);
        profileClick(userName, fromAuthor, identicon);
        messageContextMenu.popup()
    }

    Loader {
        active :true
        width: parent.width
        sourceComponent: {
            switch(contentType) {
                case Constants.chatIdentifier:
                    return channelIdentifierComponent
                case Constants.systemMessagePrivateGroupType:
                    return channelIdentifierComponent
                default:
                    return appSettings.compactMode ? compactMessageComponent : messageComponent
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifier {
            authorCurrentMsg: messageItem.authorCurrentMsg
        }
    }

    // Private group Messages
    Component {
        id: privateGroupHeaderComponent
        StyledText {
            wrapMode: Text.Wrap
            text:  message
            visible: isStatusMessage
            font.pixelSize: 16
            color: Style.current.darkGrey
            width:  parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
        }
    }

    // Normal message
    Component {
        id: messageComponent
        NormalMessage {
            clickMessage: messageItem.clickMessage
        }
    }

    // Compact Messages
    Component {
        id: compactMessageComponent
        CompactMessage {
            clickMessage: messageItem.clickMessage
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75;height:80;width:800}
}
##^##*/
