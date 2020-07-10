import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"

Rectangle {
    property string channelNameStr: "#" + chatsModel.activeChannel.id
    property int iconSize: 13

    id: chatTopBarContent
    color: "white"
    height: 56
    Layout.fillWidth: true
    border.color: Style.current.grey
    border.width: 1

    ChannelIcon {
      id: channelIcon
      channelName: chatsModel.activeChannel.name
      channelType: chatsModel.activeChannel.chatType
      channelIdenticon: chatsModel.activeChannel.identicon
    }

    StyledTextEdit {
        id: channelName
        width: 80
        height: 20
        text: chatsModel.activeChannel.chatType != Constants.chatTypePublic ? chatsModel.activeChannel.name : channelNameStr
        anchors.left: channelIcon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        font.weight: Font.Medium
        font.pixelSize: 15
        selectByMouse: true
        readOnly: true
    }

    StyledText {
        id: channelIdentifier
        color: Style.current.darkGrey
        text: {
            switch(chatsModel.activeChannel.chatType){
                //% "Public chat"
                case Constants.chatTypePublic: return qsTrId("public-chat")
                case Constants.chatTypeOneToOne: return (profileModel.isAdded(chatsModel.activeChannel.id) ?
                //% "Contact"
                qsTrId("chat-is-a-contact") :
                //% "Not a contact"
                qsTrId("chat-is-not-a-contact"))
                case Constants.chatTypePrivateGroupChat: 
                    let cnt = chatsModel.activeChannel.members.rowCount();
                    //% "%1 members"
                    if(cnt > 1) return qsTrId("%1-members").arg(cnt);
                    //% "1 member"
                    return qsTrId("1-member");
                default: return "...";
            }
        }
        font.pixelSize: 12
        anchors.left: channelIcon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: channelName.bottom
        anchors.topMargin: 0
    }

    Rectangle {
        id: moreActionsBtnContainer
        width: 40
        height: 40
        radius: Style.current.radius
        color: Style.current.transparent
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding

        StyledText {
            id: moreActionsBtn
            text: "..."
            font.letterSpacing: 0.5
            font.bold: true
            lineHeight: 1.4
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 25
        }

        MouseArea {
            property bool menuOpened: false

            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                parent.color = Style.current.grey
            }
            onExited: {
                parent.color = Style.current.transparent
            }

            onClicked: {
                var menu = chatContextMenu;
                if(chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat){
                    menu = groupContextMenu
                }

                if (!menuOpened) {
                    menu.arrowX = menu.width - 40
                    menu.popup(moreActionsBtn.x, moreActionsBtn.height)
                    menuOpened = true
                } else {
                    menu.dismiss()
                    menuOpened = false
                }
            }
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            PopupMenu {
                id: chatContextMenu
                onClosed: {
                    mouseArea.menuOpened = false
                }
                Action {
                    icon.source: "../../../img/close.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    //% "Clear history"
                    text: qsTrId("clear-history")
                    onTriggered: chatsModel.clearChatHistory(chatsModel.activeChannel.id)
                }
                Action {
                    icon.source: "../../../img/delete.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    icon.color: Style.current.red
                    text: qsTr("Delete Chat")
                    onTriggered: chatsModel.leaveActiveChat()
                }
            }

            PopupMenu {
                id: groupContextMenu
                onClosed: {
                    mouseArea.menuOpened = false
                }
                Action {
                    icon.source: "../../../img/group_chat.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    //% "Group Information"
                    text: qsTrId("group-information")
                    onTriggered: groupInfoPopup.open()
                }
                Action {
                    icon.source: "../../../img/close.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    //% "Clear history"
                    text: qsTrId("clear-history")
                    onTriggered: chatsModel.clearChatHistory(chatsModel.activeChannel.id)
                }
                Action {
                    icon.source: "../../../img/leave_chat.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    //% "Leave Group"
                    text: qsTrId("leave-group")
                    onTriggered: chatsModel.leaveActiveChat()
                }
            }

            GroupInfoPopup {
                id: groupInfoPopup
                onClosed: {
                    mouseArea.menuOpened = false
                }
            }
        }
    }
}
