import QtQuick 2.14
import "../../../../../shared"
import "../../../../../imports"

Column {
    property string authorCurrentMsg: "authorCurrentMsg"

    property string profileImage

    id: channelIdentifier
    spacing: Style.current.padding
    visible: authorCurrentMsg === ""
    anchors.horizontalCenter: parent.horizontalCenter
    topPadding: visible ? Style.current.bigPadding : 0
    bottomPadding: visible? 50 : 0

    Rectangle {
        id: circleId
        anchors.horizontalCenter: parent.horizontalCenter
        width: 120
        height: 120
        radius: 120
        border.width: chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne ? 2 : 0
        border.color: Style.current.border
        color: {
            if (chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne) {
                return Style.current.transparent
            }
            if (chatsModel.channelView.activeChannel.color) {
                return chatsModel.channelView.activeChannel.color
            }
            const color = chatsModel.channelView.getChannelColor(chatId)
            if (!color) {
                return Style.current.orange
            }
            return color
        }

        RoundedImage {
            visible: chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: 120
            source: channelIdentifier.profileImage || chatsModel.channelView.activeChannel.identicon
            smooth: false
            antialiasing: true
        }

        StyledText {
            visible: chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne
            text: Utils.removeStatusEns((chatsModel.channelView.activeChannel.name.charAt(0) === "#" ? chatsModel.channelView.activeChannel.name.charAt(1) : chatsModel.channelView.activeChannel.name.charAt(0)).toUpperCase())
            opacity: 0.7
            font.weight: Font.Bold
            font.pixelSize: 51
            color: Style.current.white
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StyledText {
        id: channelName
        wrapMode: Text.Wrap
        text: {
            switch(chatsModel.channelView.activeChannel.chatType) {
                case Constants.chatTypePublic: return "#" + chatsModel.channelView.activeChannel.name;
                case Constants.chatTypeOneToOne: return Utils.removeStatusEns(chatsModel.userNameOrAlias(chatsModel.channelView.activeChannel.id))
                default: return chatsModel.channelView.activeChannel.name
            }
        }
        font.weight: Font.Bold
        font.pixelSize: 22
        color: Style.current.textColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StyledText {
        id: descText
        wrapMode: Text.Wrap
        anchors.horizontalCenter: parent.horizontalCenter
        width: 310
        text: {
            switch(chatsModel.channelView.activeChannel.chatType) {
                //% "Welcome to the beginning of the <span style='color: %1'>%2</span> group!"
                case Constants.chatTypePrivateGroupChat: return qsTrId("welcome-to-the-beginning-of-the--span-style--color---1---2--span--group-").arg(Style.current.textColor).arg(chatsModel.channelView.activeChannel.name);
                //% "Any messages you send here are encrypted and can only be read by you and <span style='color: %1'>%2</span>"
                case Constants.chatTypeOneToOne: return qsTrId("any-messages-you-send-here-are-encrypted-and-can-only-be-read-by-you-and--span-style--color---1---2--span-").arg(Style.current.textColor).arg(channelName.text)
                default: return "";
            }
        }
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.RichText
    }

    Item {
        visible: chatsModel.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat && chatsModel.channelView.activeChannel.isMemberButNotJoined
        anchors.horizontalCenter: parent.horizontalCenter
        width: visible ? joinChat.width : 0
        height: visible ? 100 : 0
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
                    chatsModel.groups.join()
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
                    chatsModel.channelView.leaveActiveChat()
                }
            }
        }
    }
}
