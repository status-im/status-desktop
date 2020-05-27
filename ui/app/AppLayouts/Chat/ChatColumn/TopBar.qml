import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Rectangle {
    property string channelNameStr: "#" + chatsModel.activeChannel

    id: chatTopBarContent
    color: "white"
    height: 56
    Layout.fillWidth: true
    border.color: Theme.grey
    border.width: 1

    // TODO this should be the Identicon if it's a private chat
    Rectangle {
        id: channelIcon
        width: 36
        height: 36
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        color: {
            if (!chatsModel.activeChannel) {
                return Theme.transparent
            }
            const color = chatsModel.getChannelColor(chatsModel.activeChannel)
            if (!color) {
                return Theme.transparent
            }
            return color
        }
        radius: 50

        Text {
            id: channelIconText
            color: "white"
            opacity: 0.7
            text: chatTopBarContent.channelNameStr.substring(1, 2).toUpperCase()
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Bold
            font.pixelSize: 18
        }
    }

    TextEdit {
        id: channelName
        width: 80
        height: 20
        text: chatTopBarContent.channelNameStr
        anchors.left: channelIcon.right
        anchors.leftMargin: Theme.smallPadding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        font.weight: Font.Medium
        font.pixelSize: 15
        selectByMouse: true
        readOnly: true
    }

    Text {
        id: channelIdentifier
        color: Theme.darkGrey
        // TODO change this in case of private message
        text: "Public chat"
        font.pixelSize: 12
        anchors.left: channelIcon.right
        anchors.leftMargin: Theme.smallPadding
        anchors.top: channelName.bottom
        anchors.topMargin: 0
    }

    Text {
        id: moreActionsBtn
        text: "..."
        font.letterSpacing: 0.5
        font.bold: true
        lineHeight: 1.4
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.pixelSize: 25

        MouseArea {
            id: mouseArea
            // The negative margins are for the mouse area to be a bit more wide around the button and have more space for the click
            anchors.topMargin: -10
            anchors.bottomMargin: -10
            anchors.rightMargin: -15
            anchors.leftMargin: -15
            anchors.fill: parent
            onClicked: {
                contextMenu.arrowX = contextMenu.width - 40
                contextMenu.popup(moreActionsBtn.x, moreActionsBtn.height + 10)
            }
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            PopupMenu {
                id: contextMenu
                QQC2.Action { 
                    text: qsTr("Leave Chat")
                    onTriggered: chatsModel.leaveActiveChat()
                }
            }
        }
    }
}