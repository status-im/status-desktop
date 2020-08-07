import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property string authorCurrentMsg: "authorCurrentMsg"
    property int verticalMargin: 50

    id: channelIdentifier
    visible: authorCurrentMsg == ""
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: this.visible ? verticalMargin : 0
    height: this.visible ? childrenRect.height + verticalMargin : 0

    Rectangle {
        id: circleId
        anchors.horizontalCenter: parent.horizontalCenter
        width: 120
        height: 120
        radius: 120
        border.width: chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne ? 2 : 0
        border.color: Style.current.border
        color: {
            if (chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne) {
                return Style.current.transparent
            }
            return chatsModel.activeChannel.color
        }

        Image {
            visible: chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne
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
                case Constants.chatTypeOneToOne: return Utils.removeStatusEns(chatsModel.activeChannel.name)
                default: return chatsModel.activeChannel.name
            }
        }
        font.weight: Font.Bold
        font.pixelSize: 22
        color: Style.current.textColor
        anchors.top: circleId.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: channelDescription
        width: 330
        height: childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: channelName.bottom
        anchors.topMargin: 16

        StyledText {
            wrapMode: Text.Wrap
            text: {
                switch(chatsModel.activeChannel.chatType) {
                    case Constants.chatTypePrivateGroupChat: return qsTr(`Welcome to the beginning of the <span style="color: ${Style.current.textColor}">%1</span> group!`).arg(chatsModel.activeChannel.name);
                    case Constants.chatTypeOneToOne: return qsTr(`Any messages you send here are encrypted and can only be read by you and <span style="color: ${Style.current.textColor}">%1</span>`).arg(Utils.removeStatusEns(chatsModel.activeChannel.name))
                    default: return "";
                }
            }
            font.pixelSize: 14
            color: Style.current.darkGrey
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
        }
    }

    Item {
        visible: chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat && !chatsModel.activeChannel.isMember(profileModel.profile.pubKey)
        anchors.top: channelDescription.bottom
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

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:480;width:640}
}
##^##*/
