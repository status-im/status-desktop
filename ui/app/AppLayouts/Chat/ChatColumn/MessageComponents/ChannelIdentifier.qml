import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Column {
    property string authorCurrentMsg: "authorCurrentMsg"
    property int verticalMargin: 50

    property string profileImage

    id: channelIdentifier
    spacing: Style.current.padding
    visible: authorCurrentMsg === ""
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: this.visible ? verticalMargin : 0

    Rectangle {
        id: circleId
        anchors.horizontalCenter: parent.horizontalCenter
        width: 120 * scaleAction.factor
        height: 120 * scaleAction.factor
        radius: 120
        border.width: chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne ? 2 : 0
        border.color: Style.current.border
        color: {
            if (chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne) {
                return Style.current.transparent
            }
            if (chatsModel.activeChannel.color) {
                return chatsModel.activeChannel.color
            }
            const color = chatsModel.getChannelColor(chatId)
            if (!color) {
                return Style.current.orange
            }
            return color
        }

        RoundedImage {
            visible: chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 120 * scaleAction.factor
            height: 120 * scaleAction.factor
            source: channelIdentifier.profileImage || chatsModel.activeChannel.identicon
            smooth: false
            antialiasing: true
        }

        StyledText {
            visible: chatsModel.activeChannel.chatType !== Constants.chatTypeOneToOne
            text: Utils.removeStatusEns((chatsModel.activeChannel.name.charAt(0) === "#" ? chatsModel.activeChannel.name.charAt(1) : chatsModel.activeChannel.name.charAt(0)).toUpperCase())
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
            switch(chatsModel.activeChannel.chatType) {
                case Constants.chatTypePublic: return "#" + chatsModel.activeChannel.name;
                case Constants.chatTypeOneToOne: return Utils.removeStatusEns(chatsModel.userNameOrAlias(chatsModel.activeChannel.id))
                default: return chatsModel.activeChannel.name
            }
        }
        font.weight: Font.Bold
        font.pixelSize: 22 * scaleAction.factor
        color: Style.current.textColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
        id: channelDescription
        visible: descText.visible
        width: visible ? 330 * scaleAction.factor : 0
        height: visible ? childrenRect.height : 0
        anchors.horizontalCenter: parent.horizontalCenter

        StyledText {
            id: descText
            wrapMode: Text.Wrap
            text: {
                switch(chatsModel.activeChannel.chatType) {
                    //% "Welcome to the beginning of the <span style='color: %1'>%2</span> group!"
                    case Constants.chatTypePrivateGroupChat: return qsTrId("welcome-to-the-beginning-of-the--span-style--color---1---2--span--group-").arg(Style.current.textColor).arg(chatsModel.activeChannel.name);
                    //% "Any messages you send here are encrypted and can only be read by you and <span style='color: %1'>%2</span>"
                    case Constants.chatTypeOneToOne: return qsTrId("any-messages-you-send-here-are-encrypted-and-can-only-be-read-by-you-and--span-style--color---1---2--span-").arg(Style.current.textColor).arg(channelName.text)
                    default: return "";
                }
            }
            font.pixelSize: 14 * scaleAction.factor
            color: Style.current.secondaryText
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
        }
    }

    Item {
        visible: chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat && !chatsModel.activeChannel.isMember
        anchors.horizontalCenter: parent.horizontalCenter
        width: joinChat.width
        height: visible ? 100 * scaleAction.factor : 10 * scaleAction.factor
        id: joinOrDecline

        StyledText {
            id: joinChat
            //% "Join chat"
            text: qsTrId("join-chat")
            font.pixelSize: 20 * scaleAction.factor
            color: Style.current.blue
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    chatsModel.groups.join()
                    joinOrDecline.visible = false;
                }
            }
        }

        StyledText {
            //% "Decline invitation"
            text: qsTrId("group-chat-decline-invitation")
            font.pixelSize: 20 * scaleAction.factor
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

    Item {
        id: spacer
        visible: chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat && chatsModel.activeChannel.isMember
        width: parent.width
        height: Style.current.bigPadding

    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:480;width:640}
}
##^##*/
