import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Item {
    property string userName: "Jotaro Kujo"
    property string message: "That's right. We're friends...  Of justice, that is."
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool isCurrentUser: false
    property bool repeatMessageInfo: true
    property int timestamp: 1234567
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int contentType: 1 // constants don't work in default props

    width: parent.width
    height: contentType == Constants.stickerType ? stickerId.height : (isCurrentUser || (!isCurrentUser && !repeatMessageInfo) ? chatBox.height : 24 + chatBox.height)

    Image {
        id: chatImage
        width: 36
        height: 36
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.top: parent.top
        fillMode: Image.PreserveAspectFit
        source: identicon
        visible: repeatMessageInfo && !isCurrentUser
    }

    TextEdit {
        id: chatName
        text: userName
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
        font.bold: true
        font.pixelSize: 14
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
        visible: repeatMessageInfo && !isCurrentUser
    }

    Rectangle {
        property int chatVerticalPadding: 7
        property int chatHorizontalPadding: 12

        id: chatBox
        height: (2 * chatVerticalPadding) + (contentType == Constants.stickerType ? stickerId.height : chatText.height)
        color: isCurrentUser ? Theme.blue : Theme.lightBlue
        border.color: Theme.transparent
        width: contentType == Constants.stickerType ? (stickerId.width + (2 * chatHorizontalPadding)) : (message.length > 52 ? 380 : chatText.width + 2 * chatHorizontalPadding)
        radius: 16
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Theme.padding
        anchors.top: repeatMessageInfo && !isCurrentUser ? chatImage.top : parent.top
        anchors.topMargin: 0

        // Thi`s rectangle's only job is to mask the corner to make it less rounded... yep
        Rectangle {
            color: parent.color
            width: 18
            height: 18
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: !isCurrentUser ? parent.left : undefined
            anchors.leftMargin: 0
            anchors.right: !isCurrentUser ? undefined : parent.right
            anchors.rightMargin: 0
            radius: 4
            z: -1
        }

        TextEdit {
            id: chatText
            text: message
            anchors.left: parent.left
            anchors.leftMargin: parent.chatHorizontalPadding
            anchors.right: message.length > 52 ? parent.right : undefined
            anchors.rightMargin: message.length > 52 ? parent.chatHorizontalPadding : 0
            horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            font.family: "Inter"
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
            font.pixelSize: 15
            readOnly: true
            selectByMouse: true
            color: !isCurrentUser ? Theme.black : Theme.white
            visible: contentType == Constants.messageType
        }

        Image {
            id: stickerId
            horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            anchors.left: parent.left
            anchors.leftMargin: parent.chatHorizontalPadding
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
            width: 140
            height: 140
            source: contentType == Constants.stickerType ? ("https://ipfs.infura.io/ipfs/" + sticker) : ""
            visible: contentType == Constants.stickerType
        }

        TextEdit {
            id: chatTime
            color: Theme.darkGrey
            font.family: "Inter"
            text: timestamp
            anchors.top: contentType == Constants.stickerType ? stickerId.bottom : chatText.bottom
            anchors.bottomMargin: Theme.padding
            anchors.right: !isCurrentUser ? parent.right : undefined
            anchors.rightMargin: !isCurrentUser ? Theme.padding : 0
            anchors.left: !isCurrentUser ? undefined : parent.left
            anchors.leftMargin: !isCurrentUser ? 0 : Theme.padding
            font.pixelSize: 10
            readOnly: true
            selectByMouse: true
            // Probably only want to show this when clicking?
            visible: false
        }
    }
}

/*##^##
Designer {
    D{i:0;height:80;width:800}
}
##^##*/

