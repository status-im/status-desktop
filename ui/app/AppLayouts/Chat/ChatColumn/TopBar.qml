import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

Item {
    property int iconSize: 16
    id: chatTopBarContent
    height: 56

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
            chatName: {
                if (chatsModel.activeChannel.chatType === Constants.chatTypePrivateGroupChat) {
                    return chatsModel.activeChannel.name
                }
                chatsModel.userNameOrAlias(chatsModel.activeChannel.id)
            }
            chatType: chatsModel.activeChannel.chatType
            identicon: chatsModel.activeChannel.identicon
            muted: chatsModel.activeChannel.muted
            identiconSize: 36

            onClicked: {
                switch (chatsModel.activeChannel.chatType) {
                    case Constants.chatTypePrivateGroupChat:
                        openPopup(groupInfoPopupComponent, {channel: chatsModel.activeChannel})
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
            chatId: chatsModel.activeChannel.id
            chatName: chatsModel.activeChannel.name
            chatType: chatsModel.activeChannel.chatType
            identicon: chatsModel.activeChannel.identicon
            muted: chatsModel.activeChannel.muted
        }
    }

    StatusContextMenuButton {
        id: moreActionsBtn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding

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

        ChannelContextMenu {
            id: chatContextMenu
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
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
                onTriggered: openPopup(groupInfoPopupComponent, {channel: chatsModel.activeChannel})
            }
            Action {
                icon.source: "../../../img/close.svg"
                icon.width: chatTopBarContent.iconSize
                icon.height: chatTopBarContent.iconSize
                //% "Clear History"
                text: qsTrId("clear-history")
                onTriggered: chatsModel.clearChatHistory(chatsModel.activeChannel.id)
            }
            Action {
                icon.source: "../../../img/leave_chat.svg"
                icon.width: chatTopBarContent.iconSize
                icon.height: chatTopBarContent.iconSize
                //% "Leave group"
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
