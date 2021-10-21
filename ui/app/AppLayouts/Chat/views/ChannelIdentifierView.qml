import QtQuick 2.14
import "../../../../shared"
import "../../../../shared/panels"

import utils 1.0

Column {
    id: root
    spacing: Style.current.padding
    visible: authorCurrentMsg === ""
    anchors.horizontalCenter: parent.horizontalCenter
    topPadding: visible ? Style.current.bigPadding : 0
    bottomPadding: visible? 50 : 0

    property var store
    property string authorCurrentMsg: "authorCurrentMsg"
    property string profileImage

    Rectangle {
        id: circleId
        anchors.horizontalCenter: parent.horizontalCenter
        width: 120
        height: 120
        radius: 120
        border.width: root.store.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypeOneToOne ? 2 : 0
        border.color: Style.current.border
        color: {
            if (root.store.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypeOneToOne) {
                return Style.current.transparent
            }
            if (root.store.chatsModelInst.channelView.activeChannel.color) {
                return root.store.chatsModelInst.channelView.activeChannel.color
            }
            const color = root.store.chatsModelInst.channelView.getChannelColor(chatId)
            if (!color) {
                return Style.current.orange
            }
            return color
        }

        RoundedImage {
            visible: root.store.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypeOneToOne
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: 120
            source: root.profileImage || root.store.chatsModelInst.channelView.activeChannel.identicon
            smooth: false
            antialiasing: true
        }

        StyledText {
            visible: root.store.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne
            text: Utils.removeStatusEns((root.store.chatsModelInst.channelView.activeChannel.name.charAt(0) === "#" ?
                                         root.store.chatsModelInst.channelView.activeChannel.name.charAt(1) :
                                         root.store.chatsModelInst.channelView.activeChannel.name.charAt(0)).toUpperCase())
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
            switch(root.store.chatsModelInst.channelView.activeChannel.chatType) {
                case Constants.chatTypePublic: return "#" + root.store.chatsModelInst.channelView.activeChannel.name;
                case Constants.chatTypeOneToOne: return Utils.removeStatusEns(root.store.chatsModelInst.userNameOrAlias(chatsModel.channelView.activeChannel.id))
                default: return root.store.chatsModelInst.channelView.activeChannel.name
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
            switch(root.store.chatsModelInst.channelView.activeChannel.chatType) {
                //% "Welcome to the beginning of the <span style='color: %1'>%2</span> group!"
                case Constants.chatTypePrivateGroupChat: return qsTrId("welcome-to-the-beginning-of-the--span-style--color---1---2--span--group-").arg(Style.current.textColor).arg(root.store.chatsModelInst.channelView.activeChannel.name);
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
        visible: root.store.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat
                 && root.store.chatsModelInst.channelView.activeChannel.isMemberButNotJoined
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
                    root.store.chatsModelInst.groups.join()
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
                    root.store.chatsModelInst.channelView.leaveActiveChat()
                }
            }
        }
    }
}
