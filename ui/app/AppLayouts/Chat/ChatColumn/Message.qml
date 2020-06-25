import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"

Item {
    property string fromAuthor: "0x0011223344556677889910"
    property string userName: "Jotaro Kujo"
    property string message: "That's right. We're friends...  Of justice, that is."
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool isCurrentUser: false
    property string timestamp: "1234567"
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int contentType: 1 // constants don't work in default props
    property string chatId: "chatId"

    property string authorCurrentMsg: "authorCurrentMsg"
    property string authorPrevMsg: "authorPrevMsg"

    property bool isMessage: contentType == Constants.messageType || contentType == Constants.stickerType || contentType == Constants.emojiType 
    property bool isStatusMessage: contentType == Constants.systemMessagePrivateGroupType

    property var profileClick: function () {}

    width: parent.width
    height: {
        switch(contentType){
            case Constants.chatIdentifier:
                return parent.parent.height - 100
            case Constants.stickerType:
                return stickerId.height + 50
            default:
                return (isCurrentUser || (!isCurrentUser && authorCurrentMsg == authorPrevMsg) ? chatBox.height : 24 + chatBox.height)
        }
    }

    Item {
        id: channelIdentifier
        visible: authorCurrentMsg == ""
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        
        Rectangle {
            id: circleId
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120
            height: 120
            radius: 120
            border.width: chatsModel.activeChannel.chatType == Constants.chatTypeOneToOne ? 2 : 0
            border.color: Theme.grey
            color: {
                if (chatsModel.activeChannel.chatType == Constants.chatTypeOneToOne) {
                    return Theme.transparent
                }
                return chatsModel.activeChannel.color
            }

            Image {
                visible: chatsModel.activeChannel.chatType == Constants.chatTypeOneToOne
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: 120
                height: 120
                fillMode: Image.PreserveAspectFit
                source: chatsModel.activeChannel.identicon
                mipmap: true
                smooth: false
                antialiasing: true
            }

            StyledText {
                visible: chatsModel.activeChannel.chatType != Constants.chatTypeOneToOne
                text: (chatsModel.activeChannel.name.charAt(0) == "#" ? chatsModel.activeChannel.name.charAt(1) : chatsModel.activeChannel.name.charAt(0)).toUpperCase()
                opacity: 0.7
                font.weight: Font.Bold
                font.pixelSize: 51
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        StyledText {
            id: channelName
            wrapMode: Text.Wrap
            text: {
                    if (chatsModel.activeChannel.chatType != Constants.chatTypePublic) {
                        return chatsModel.activeChannel.name;
                    } else {
                        return "#" + chatsModel.activeChannel.name;
                    }
                }
            font.weight: Font.Bold
            font.pixelSize: 22
            color: Theme.black
            anchors.top: circleId.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            visible: chatsModel.activeChannel.chatType == Constants.chatTypePrivateGroupChat && !chatsModel.activeChannel.isMember(profileModel.profile.pubKey)
            anchors.top: channelName.bottom
            anchors.topMargin: 16
            id: joinOrDecline

            StyledText {
                id: joinChat
                text: qsTr("Join chat")
                font.pixelSize: 20
                color: Theme.blue
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        chatsModel.joinGroup()
                    }
                }
            } 

            StyledText {
                text: qsTr("Decline invitation")
                font.pixelSize: 20
                color: Theme.blue
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: joinChat.bottom
                anchors.topMargin: Theme.padding
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        chatsModel.leaveActiveChat()
                    }
                }
            }            
        }

    }

    // Private group Messages
    StyledText {
        wrapMode: Text.Wrap
        text:  message
        visible: isStatusMessage
        font.pixelSize: 16
        color: Theme.darkGrey
        width:  parent.width - 120
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.RichText
    }

    // Messages
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
        visible: isMessage && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        mipmap: true
        smooth: false
        antialiasing: true

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
              profileClick(userName, fromAuthor, identicon)
            }
        }
    }

    StyledTextEdit {
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
        visible: isMessage && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
              profileClick(userName, fromAuthor, identicon)
            }
        }
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
        anchors.top: authorCurrentMsg != authorPrevMsg && !isCurrentUser ? chatImage.top : parent.top
        anchors.topMargin: 0
        visible: isMessage

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

        StyledTextEdit {
            id: chatText
            text: message
            anchors.left: parent.left
            anchors.leftMargin: parent.chatHorizontalPadding
            anchors.right: message.length > 52 ? parent.right : undefined
            anchors.rightMargin: message.length > 52 ? parent.chatHorizontalPadding : 0
            horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            wrapMode: Text.Wrap
            anchors.top: parent.top
            anchors.topMargin: chatBox.chatVerticalPadding
            font.pixelSize: 15
            readOnly: true
            selectByMouse: true
            color: !isCurrentUser ? Theme.black : Theme.white
            visible: contentType == Constants.messageType
            textFormat: TextEdit.RichText
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

        StyledTextEdit {
            id: chatTime
            color: Theme.darkGrey
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
