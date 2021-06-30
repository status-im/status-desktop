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
        property bool isGroupChatOrOneToOne: (chatsModel.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat ||
                                              chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne)
        anchors.left: parent.left
        anchors.leftMargin: this.isGroupChatOrOneToOne ? Style.current.padding : Style.current.padding + 4
        anchors.top: parent.top
        anchors.topMargin: 4
        sourceComponent:  this.isGroupChatOrOneToOne ? chatInfoButton : chatInfo
    }

    Component {
        id: chatInfoButton
        StatusChatInfoButton {
            chatId: chatsModel.channelView.activeChannel.id
            chatName: {
                if (chatsModel.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat) {
                    return chatsModel.channelView.activeChannel.name
                }
                chatsModel.userNameOrAlias(chatsModel.channelView.activeChannel.id)
            }
            chatType: chatsModel.channelView.activeChannel.chatType
            identicon: chatsModel.channelView.activeChannel.identicon
            muted: chatsModel.channelView.activeChannel.muted
            identiconSize: 36

            onClicked: {
                switch (chatsModel.channelView.activeChannel.chatType) {
                case Constants.chatTypePrivateGroupChat:
                    openPopup(groupInfoPopupComponent, {channelType: GroupInfoPopup.ChannelType.ActiveChannel})
                    break;
                case Constants.chatTypeOneToOne:
                    const profileImage = appMain.getProfileImage(chatsModel.channelView.activeChannel.id)
                    openProfilePopup(chatsModel.userNameOrAlias(chatsModel.channelView.activeChannel.id),
                                     chatsModel.channelView.activeChannel.id, profileImage || chatsModel.channelView.activeChannel.identicon,
                                     "", chatsModel.channelView.activeChannel.nickname)
                    break;
                }
            }
        }
    }

    Component {
        id: chatInfo
        StatusChatInfo {
            identiconSize: 36
            chatId: chatsModel.channelView.activeChannel.id
            chatName: chatsModel.channelView.activeChannel.name
            chatType: chatsModel.channelView.activeChannel.chatType
            identicon: chatsModel.channelView.activeChannel.identicon
            muted: chatsModel.channelView.activeChannel.muted
        }
    }

    Row {
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        spacing: 12

        StatusIconButton {
            id: showUsersBtn
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "channel-icon-group"
            iconColor: showUsers ? Style.current.contextMenuButtonForegroundColor : Style.current.contextMenuButtonBackgroundHoverColor
            hoveredIconColor: Style.current.contextMenuButtonForegroundColor
            highlightedBackgroundColor: Style.current.contextMenuButtonBackgroundHoverColor
            onClicked: {
                showUsers = !showUsers
            }
            visible: appSettings.showOnlineUsers && chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne
        }

        StatusContextMenuButton {
            id: moreActionsBtn
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                var menu = chatContextMenu;
                var isPrivateGroupChat = chatsModel.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat
                if(isPrivateGroupChat){
                    menu = groupContextMenu
                }

                if (menu.opened) {
                    return menu.close()
                }

                if (isPrivateGroupChat) {
                    menu.popup(moreActionsBtn.x, moreActionsBtn.height)
                } else {
                    menu.openMenu(chatsModel.channelView.activeChannel, chatsModel.channelView.getActiveChannelIdx(),
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
                    onTriggered: openPopup(groupInfoPopupComponent, {channelType: GroupInfoPopup.ChannelType.ActiveChannel })
                }
                Action {
                    icon.source: "../../../img/close.svg"
                    icon.width: chatTopBarContent.iconSize
                    icon.height: chatTopBarContent.iconSize
                    //% "Clear History"
                    text: qsTrId("clear-history")
                    onTriggered: chatsModel.channelView.clearChatHistory(chatsModel.channelView.activeChannel.id)
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

        Rectangle {
            id: separator
            visible: activityCenterBtn.visible
            width: 1
            height: 24
            color: Style.current.separator
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusIconButton {
            id: activityCenterBtn
            visible: appSettings.isActivityCenterEnabled
            icon.name: "bell"
            iconColor: Style.current.contextMenuButtonForegroundColor
            hoveredIconColor: Style.current.contextMenuButtonForegroundColor
            highlightedBackgroundColor: Style.current.contextMenuButtonBackgroundHoverColor
            anchors.verticalCenter: parent.verticalCenter

            onClicked: activityCenter.open()

            Rectangle {
                property int nbUnseenNotifs: chatsModel.activityNotificationList.unreadCount

                id: badge
                visible: nbUnseenNotifs > 0
                anchors.top: parent.top
                anchors.topMargin: -2
                anchors.left: parent.right
                anchors.leftMargin: -17
                radius: height / 2
                color: Style.current.blue
                border.color: activityCenterBtn.hovered ? Style.current.secondaryBackground : Style.current.background
                border.width: 2
                width: badge.nbUnseenNotifs < 10 ? 18 : badgeText.width + 14
                height: 18

                Text {
                    id: badgeText
                    font.pixelSize: 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: badge.nbUnseenNotifs
                }
            }
        }
    }

    ActivityCenter {
        id: activityCenter
    }

    ConfirmationDialog {
        id: deleteChatConfirmationDialog
        btnType: "warn"
        onConfirmButtonClicked: {
            chatsModel.channelView.leaveActiveChat()
            deleteChatConfirmationDialog.close()
        }
    }
}
