import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"

Rectangle {
    property string channelNameStr: "#" + chatsModel.activeChannel.id

    id: chatTopBarContent
    color: "white"
    height: 56
    Layout.fillWidth: true
    border.color: Theme.grey
    border.width: 1


    ChannelIcon {
      id: channelIcon
      channelName: chatsModel.activeChannel.name
      channelType: chatsModel.activeChannel.chatType
      channelIdenticon: chatsModel.activeChannel.identicon
    }

    TextEdit {
        id: channelName
        width: 80
        height: 20
        text: chatsModel.activeChannel.chatType != Constants.chatTypePublic ? chatsModel.activeChannel.name : channelNameStr
        anchors.left: channelIcon.right
        anchors.leftMargin: Theme.smallPadding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        font.weight: Font.Medium
        font.pixelSize: 15
        selectByMouse: true
        readOnly: true
    }

    StyledText {
        id: channelIdentifier
        color: Theme.darkGrey
        text: {
            switch(chatsModel.activeChannel.chatType){
                case Constants.chatTypePublic: return qsTr("Public chat")
                case Constants.chatTypeOneToOne: return qsTr("TODO: Contact/Not a contact")
                case Constants.chatTypePrivateGroupChat: 
                    let cnt = chatsModel.activeChannel.members.rowCount();
                    if(cnt > 1) return qsTr("%1 members").arg(cnt);
                    return qsTr("1 member");
                default: return "...";
            }
        }
        font.pixelSize: 12
        anchors.left: channelIcon.right
        anchors.leftMargin: Theme.smallPadding
        anchors.top: channelName.bottom
        anchors.topMargin: 0
    }

    StyledText {
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
                var menu = chatContextMenu;
                if(chatsModel.activeChannel.chatType == Constants.chatTypePrivateGroupChat){
                    menu = groupContextMenu
                }

                menu.arrowX = menu.width - 40
                menu.popup(moreActionsBtn.x, moreActionsBtn.height + 10)
                
            }
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            PopupMenu {
                id: chatContextMenu
                Action {
                    icon.source: "../../../img/close.svg"
                    text: qsTr("Clear history")
                    onTriggered: chatsModel.clearChatHistory(chatsModel.activeChannel.id)
                }
                Action {
                    icon.source: "../../../img/leave_chat.svg"
                    text: qsTr("Leave Chat")
                    onTriggered: chatsModel.leaveActiveChat()
                }
            }

            PopupMenu {
                id: groupContextMenu
                Action {
                    icon.source: "../../../img/group_chat.svg"
                    text: qsTr("Group Information")
                    onTriggered: groupInfoPopup.open()
                }
                Action {
                    icon.source: "../../../img/close.svg"
                    text: qsTr("Clear history")
                    onTriggered: chatsModel.clearChatHistory(chatsModel.activeChannel.id)
                }
                Action {
                    icon.source: "../../../img/leave_chat.svg"
                    text: qsTr("Leave Group")
                    onTriggered: chatsModel.leaveActiveChat()
                }
            }

            GroupInfoPopup {
                id: groupInfoPopup
            }
        }
    }
}
