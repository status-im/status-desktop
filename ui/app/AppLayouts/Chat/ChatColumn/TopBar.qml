import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

Rectangle {
    property int iconSize: 16
    id: chatTopBarContent
    color: Style.current.background
    height: 56
    Layout.fillWidth: true
    border.color: Style.current.border
    border.width: 1

    Loader {
      property bool isGroupChatOrOneToOne: (chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat || 
        chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne)
      anchors.left: parent.left
      anchors.leftMargin: this.isGroupChatOrOneToOne ? Style.current.padding : Style.current.padding + 4
      anchors.top: parent.top
      anchors.topMargin: 4
      sourceComponent:  this.isGroupChatOrOneToOne ? chatInfoButton : chatInfo
    }

    Component {
        id: chatInfoButton
        StatusChatInfoButton {
            chatId: chatsModel.activeChannel.id
            chatName: chatsModel.userNameOrAlias(chatsModel.activeChannel.id)
            chatType: chatsModel.activeChannel.chatType
            identicon: chatsModel.activeChannel.identicon
            muted: chatsModel.activeChannel.muted
            identiconSize: 36

            onClicked: {
                switch (chatsModel.activeChannel.chatType) {
                    case Constants.chatTypePrivateGroupChat: 
                        groupInfoPopup.openMenu(chatsModel.activeChannel, chatsModel.getActiveChannelIdx())
                        break;
                    case Constants.chatTypeOneToOne:
                        const profileImage = appMain.getProfileImage(chatsModel.activeChannel.id)
                        openProfilePopup(chatsModel.userNameOrAlias(chatsModel.activeChannel.id),
                                        chatsModel.activeChannel.id, profileImage || chatsModel.activeChannel.identicon,
                                        "", chatsModel.activeChannel.nickname)
                        break;
                }
            }
        }
    }

    Component {
        id: chatInfo
        StatusChatInfo {
            identiconSize: 36
            chatName: chatsModel.activeChannel.name
            chatType: chatsModel.activeChannel.chatType
            identicon: chatsModel.activeChannel.identicon
            muted: chatsModel.activeChannel.muted
        }
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
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                parent.color = Style.current.border
            }
            onExited: {
                parent.color = Style.current.transparent
            }

            onClicked: {
                var menu = chatContextMenu;
                var isPrivateGroupChat = chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat
                if(isPrivateGroupChat){
                    menu = groupContextMenu
                }

                if (menu.opened) {
                    return menu.close()
                }

                if (isPrivateGroupChat) {
                    menu.popup(moreActionsBtn.x, moreActionsBtn.height)
                } else {
                    menu.openMenu(chatsModel.activeChannel, chatsModel.getActiveChannelIdx(),
                                  moreActionsBtn.x - chatContextMenu.width + moreActionsBtn.width + 4,
                                  moreActionsBtn.height - 4)
                }
            }
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton


            ChannelContextMenu {
                id: chatContextMenu
                groupInfoPopup: groupInfoPopup
            }

            PopupMenu {
                id: groupContextMenu
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                Action {
                    icon.source: "../../../img/group_chat.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    //% "Group Information"
                    text: qsTrId("group-information")
                    onTriggered: groupInfoPopup.openMenu(chatsModel.activeChannel, chatsModel.getActiveChannelIdx())
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
                    onTriggered: {
                      //% "Leave group"
                      deleteChatConfirmationDialog.title = qsTrId("leave-group")
                      //% "Leave group"
                      deleteChatConfirmationDialog.confirmButtonLabel = qsTrId("leave-group")
                      //% "Are you sure you want to leave this chat?"
                      deleteChatConfirmationDialog.confirmationText = qsTrId("are-you-sure-you-want-to-leave-this-chat-")
                      deleteChatConfirmationDialog.open()
                    }
                }
            }

            GroupInfoPopup {
                id: groupInfoPopup
            }
        }
    }

    ConfirmationDialog {
        id: deleteChatConfirmationDialog
        btnType: "warn"
        onConfirmButtonClicked: {
            chatsModel.leaveActiveChat()
            deleteChatConfirmationDialog.close()
        }
    }
}
