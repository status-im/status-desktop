import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "./"
import "../../../../shared"
import "../../../../imports"

import StatusQ.Popups 0.1

StatusPopupMenu {

    property var chatItem

    StatusMenuItem {
        id: viewProfileMenuItem
        text: {
            if (chatItem) {
                switch (chatItem.chatType) {
                    case Constants.chatTypeOneToOne:
                      //% "View Profile"
                      return qsTrId("view-profile")
                      break;
                    case Constants.chatTypePrivateGroupChat:
                      //% "View Group"
                      return qsTrId("view-group")
                      break;
                }
            }
            return ""
        }
        icon.name: "group-chat"
        enabled: chatItem && 
            (chatItem.chatType === Constants.chatTypeOneToOne ||
            chatItem.chatType === Constants.chatTypePrivateGroupChat)
        onTriggered: {
            if (chatItem.chatType === Constants.chatTypeOneToOne) {
                const userProfileImage = appMain.getProfileImage(chatItem.id)
                return openProfilePopup(
                    chatItem.name,
                    chatItem.id,
                    userProfileImage || chatItem.identicon,
                    "",
                    chatItem.name
                )
            }
            if (chatItem.chatType === Constants.chatTypePrivateGroupChat) {
                return openPopup(groupInfoPopupComponent, {channelType: GroupInfoPopup.ChannelType.ContextChannel})
            }
        }
    }

    StatusMenuSeparator {
        visible: viewProfileMenuItem.enabled
    }


    Action {
        enabled: profileModel.fleets.fleet == Constants.waku_prod || profileModel.fleets.fleet == Constants.waku_test
        text: qsTr("Test WakuV2 - requestAllHistoricMessages")
        onTriggered: chatsModel.requestAllHistoricMessages()
    }

    StatusMenuItem {
        text: chatItem && chatItem.muted ? 
              //% "Unmute chat"
              qsTrId("unmute-chat") : 
              //% "Mute chat"
              qsTrId("mute-chat")
        icon.name: "notification"
        enabled: chatItem && chatItem.chatType !== Constants.chatTypePrivateGroupChat
        onTriggered: {
            if (chatItem && chatItem.muted) {
                return chatsModel.channelView.unmuteChatItem(chatItem.id)
            }
            chatsModel.channelView.muteChatItem(chatItem.id)
        }
    }

    StatusMenuItem {
        //% "Mark as Read"
        text: qsTrId("mark-as-read")
        icon.name: "checkmark-circle"
        enabled: chatItem && chatItem.chatType !== Constants.chatTypePrivateGroupChat
        onTriggered: chatsModel.channelView.markChatItemAsRead(chatItem.id)
    }

    StatusMenuItem {
        //% "Clear history"
        text: qsTrId("clear-history")
        icon.name: "close-circle"
        onTriggered: chatsModel.channelView.clearChatHistory(chatItem.id)
    }

    StatusMenuItem {
        //% "Edit Channel"
        text: qsTrId("edit-channel")
        icon.name: "edit"
        enabled: chatsModel.communities.activeCommunity.active &&
            chatsModel.communities.activeCommunity.admin
        onTriggered: openPopup(editChannelPopup, {
            communityId: chatsModel.communities.activeCommunity.id,
            channel: chatItem
        })
    }

    StatusMenuSeparator {
        visible: deleteOrLeaveMenuItem.enabled
    }

    StatusMenuItem {
        id: deleteOrLeaveMenuItem
        text: chatItem && chatItem.chatType === Constants.chatTypeOneToOne ? 
            //% "Delete chat"
            qsTrId("delete-chat") : 
            //% "Leave chat"
            qsTrId("leave-chat")
        icon.name: chatItem && chatItem.chatType === Constants.chatTypeOneToOne ? "delete" : "arrow-right"
        icon.width: chatItem && chatItem.chatType === Constants.chatTypeOneToOne ? 18 : 14
        iconRotation: chatItem && chatItem.chatType === Constants.chatTypeOneToOne ? 0 : 180

        type: StatusMenuItem.Type.Danger
        onTriggered: {
            let label = chatItem && chatItem.chatType === Constants.chatTypeOneToOne ? 
                //% "Delete chat"
                qsTrId("delete-chat") :
                //% "Leave chat"
                qsTrId("leave-chat")
            openPopup(deleteChatConfirmationDialogComponent, { 
                title: label,
                confirmButtonLabel: label,
                chatId: chatItem.id 
            })
        }

        enabled: !chatsModel.communities.activeCommunity.active
    }

    Component {
        id: deleteChatConfirmationDialogComponent
        ConfirmationDialog {
            property string chatId
            btnType: "warn"
            //% "Are you sure you want to leave this chat?"
            confirmationText: qsTrId("are-you-sure-you-want-to-leave-this-chat-")
            onClosed: {
                destroy()
            }
            onConfirmButtonClicked: {
                chatsModel.channelView.leaveChat(chatId)
                close();
            }
        }
    }
}
