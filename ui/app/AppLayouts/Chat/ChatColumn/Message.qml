import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../shared/xss.js" as XSS
import "../../../../imports"
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
    property bool isMessage: contentType === Constants.messageType || contentType === Constants.stickerType 
    property bool isStatusMessage: contentType === Constants.systemMessagePrivateGroupType
    property bool isSticker: contentType === Constants.stickerType

    property int replyMessageIndex: chatsModel.messageList.getMessageIndex(responseTo);
    property string repliedMessageAuthor: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "userName") : "";
    property string repliedMessageContent: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "message") : "";

    property var profileClick: function () {}

    width: parent.width
    height: {
        switch(contentType){
            case Constants.chatIdentifier:
                return parent.parent.height - 100
            case Constants.stickerType:
                return stickerId.height + 50 + (dateGroupLbl.visible ? 50 : 0)
            default:
                return childrenRect.height
        }
    }

    function linkify(inputText) {
        //URLs starting with http://, https://, or ftp://
        var replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
        var replacedText = inputText.replace(replacePattern1, "<a href='$1'>$1</a>");

        //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
        var replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
        replacedText = replacedText.replace(replacePattern2, "$1<a href='http://$2'>$2</a>");

        replacedText = XSS.filterXSS(replacedText)
        return replacedText;
    }

    ProfilePopup {
      id: profilePopup
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
            border.color: Style.current.grey
            color: {
                if (chatsModel.activeChannel.chatType == Constants.chatTypeOneToOne) {
                    return Style.current.transparent
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
            color: Style.current.black
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
                //% "Join chat"
                text: qsTrId("join-chat")
                font.pixelSize: 20
                color: Style.current.blue
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
                //% "Decline invitation"
                text: qsTrId("group-chat-decline-invitation")
                font.pixelSize: 20
                color: Style.current.blue
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: joinChat.bottom
                anchors.topMargin: Style.current.padding
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
        color: Style.current.darkGrey
        width:  parent.width - 120
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.RichText
    }

    StyledText {
        id: dateGroupLbl
        font.pixelSize: 13
        color: Style.current.darkGrey
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: {
            if (prevMessageIndex == -1) return ""; // identifier

            let now = new Date()
            let yesterday = new Date()
            yesterday.setDate(now.getDate()-1)

            let prevMsgTimestamp = chatsModel.messageList.getMessageData(prevMessageIndex, "timestamp")
            var currentMsgDate = new Date(parseInt(timestamp, 10));
            var prevMsgDate = prevMsgTimestamp === "" ? new Date(0) : new Date(parseInt(prevMsgTimestamp, 10));
            if(currentMsgDate.getDay() !== prevMsgDate.getDay()){
                if (now.toDateString() === currentMsgDate.toDateString()) {
                    return qsTr("Today")
                } else if (yesterday.toDateString() === currentMsgDate.toDateString()) {
                    //% "Yesterday"
                    return qsTrId("yesterday")
                } else {
                    const monthNames = [
                        qsTr("January"),
                        qsTr("February"),
                        qsTr("March"), 
                        qsTr("April"),
                        qsTr("May"),
                        qsTr("June"),
                        qsTr("July"),
                        qsTr("August"),
                        qsTr("September"),
                        qsTr("October"),
                        qsTr("November"),
                        qsTr("December")
                    ];
                    return monthNames[currentMsgDate.getMonth()] + ", " + currentMsgDate.getDay()
                }
            } else {
                return "";
            }

        }
        anchors.top: parent.top
        anchors.topMargin: 20
        visible: text !== ""
    }

    // Messages
    Image {
        id: chatImage
        width: 36
        height: 36
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 20
        fillMode: Image.PreserveAspectFit
        source: identicon
        visible: (isMessage || isEmoji) && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        mipmap: true
        smooth: false
        antialiasing: true

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                SelectedMessage.set(messageId, fromAuthor);
                profileClick(userName, fromAuthor, identicon);
                messageContextMenu.popup()
            }
        }
    }

    StyledTextEdit {
        id: chatName
        text: userName
        anchors.leftMargin: 20
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
        font.bold: true
        font.pixelSize: 14
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
        visible: (isMessage || isEmoji) && authorCurrentMsg != authorPrevMsg && !isCurrentUser
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                SelectedMessage.set(messageId, fromAuthor);
                profileClick(userName, fromAuthor, identicon)
                messageContextMenu.popup()
            }
        }
    }

    Rectangle {
        property int chatVerticalPadding: 7
        property int chatHorizontalPadding: 12

        id: chatBox
        color: isSticker ? Style.current.white : (isCurrentUser ? Style.current.blue : Style.current.lightBlue)
        border.color: isSticker ? Style.current.grey : Style.current.transparent
        border.width: 1
        height: (3 * chatVerticalPadding) + (contentType == Constants.stickerType ? stickerId.height : (chatText.height + chatReply.height))
        width: {
            switch(contentType){
                case Constants.stickerType:
                    return stickerId.width + (2 * chatBox.chatHorizontalPadding);
                default:
                    return plainText.length > 54 ? 400 : chatText.width + 2 * chatHorizontalPadding
            }
        }

        radius: 16
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: !isCurrentUser ? 8 : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Style.current.padding
        anchors.top: authorCurrentMsg != authorPrevMsg && !isCurrentUser ? chatImage.top : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
        anchors.topMargin: 0
        visible: isMessage || isEmoji

        Rectangle {
            id: chatReply
            color:  isCurrentUser ? Style.current.blue : Style.current.lightBlue
            visible: responseTo != "" && replyMessageIndex > -1
            height: chatReply.visible ? childrenRect.height : 0
            anchors.top: parent.top
            anchors.topMargin: chatReply.visible ? chatBox.chatVerticalPadding : 0
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: chatBox.chatHorizontalPadding

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
                text: Emoji.parse(linkify(repliedMessageContent), "26x26");
                textFormat: Text.RichText
                color: Style.current.darkGrey
                readOnly: true
                selectByMouse: true
                wrapMode: Text.Wrap
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Separator {
                anchors.top: lblReplyMessage.bottom
                anchors.topMargin: 8
                anchors.left: lblReplyMessage.left
                anchors.right: lblReplyMessage.right
                anchors.rightMargin: chatBox.chatHorizontalPadding
                color: Style.current.darkGrey
            }
        }

        StyledTextEdit {
            id: chatText
            textFormat: TextEdit.RichText
            text: {
                if(contentType === Constants.stickerType) return "";
                if(isEmoji){
                    return Emoji.parse(linkify(message), "72x72");
                } else {
                    return Emoji.parse(linkify(message), "26x26");
                }

            }
            anchors.left: parent.left
            anchors.leftMargin: parent.chatHorizontalPadding
            anchors.right: plainText.length > 52 ? parent.right : undefined
            anchors.rightMargin: plainText.length > 52 ? parent.chatHorizontalPadding : 0
            horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
            wrapMode: Text.Wrap
            anchors.top: chatReply.bottom
            anchors.topMargin: chatBox.chatVerticalPadding
            font.pixelSize: 15
            readOnly: true
            selectByMouse: true
            color: !isCurrentUser ? Style.current.black : Style.current.white
            visible: contentType == Constants.messageType || isEmoji
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
            source: contentType === Constants.stickerType ? ("https://ipfs.infura.io/ipfs/" + sticker) : ""
            visible: contentType === Constants.stickerType
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: chatText.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if(mouse.button & Qt.RightButton) {
                    SelectedMessage.set(messageId, fromAuthor);
                    profileClick(userName, fromAuthor, identicon);
                    messageContextMenu.popup()
                    return;
                }

                let link = chatText.hoveredLink;
                if(link.startsWith("#")){
                    chatsModel.joinChat(link.substring(1), Constants.chatTypePublic);
                    return;
                }

                if (link.startsWith('//')) {
                  let pk = link.replace("//", "");
                  profileClick(chatsModel.userNameOrAlias(pk), pk, chatsModel.generateIdenticon(pk))
                  return;
                }

                Qt.openUrlExternally(link)
            }
        }
    }

    StyledTextEdit {
        id: chatTime
        color: Style.current.darkGrey
        text: {
            let messageDate = new Date(Math.floor(timestamp))
            let minutes = messageDate.getMinutes();
            let hours = messageDate.getHours();
            return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes)
        }
        anchors.top: chatBox.bottom
        anchors.topMargin: 4
        anchors.bottomMargin: Style.current.padding
        anchors.right: chatBox.right
        anchors.rightMargin: isCurrentUser ? 5 : Style.current.padding
        font.pixelSize: 10
        readOnly: true
        selectByMouse: true
        visible:  (isEmoji || isMessage || isSticker)
    }

    
    StyledTextEdit {
        id: sentMessage
        color: Style.current.darkGrey
        text: outgoingStatus == "sent" ?
        //% "Sent"
        qsTrId("status-sent") :
        //% "Sending..."
        qsTrId("sending")
        anchors.top: chatTime.top
        anchors.bottomMargin: Style.current.padding
        anchors.right: chatTime.left
        anchors.rightMargin: 5
        font.pixelSize: 10
        readOnly: true
        visible: isCurrentUser && (isEmoji || isMessage || isSticker)
    }
   
    // This rectangle's only job is to mask the corner to make it less rounded... yep
    Rectangle {
        // TODO find a way to show the corner for stickers since they have a border
        visible: isMessage || isEmoji
        color: chatBox.color
        width: 18
        height: 18
        anchors.bottom: chatBox.bottom
        anchors.bottomMargin: 0
        anchors.left: !isCurrentUser ? chatBox.left : undefined
        anchors.leftMargin: 0
        anchors.right: !isCurrentUser ? undefined : chatBox.right
        anchors.rightMargin: 0
        radius: 4
        z: -1
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75;height:80;width:800}
}
##^##*/
