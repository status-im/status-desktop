import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1

import utils 1.0
import StatusQ.Popups 0.1

import shared.popups 1.0
import "../popups"

StatusPopupMenu {
    id: root
    property var chatItem
    property var store
    property bool communityActive: root.store.chatsModelInst.communities.activeCommunity.active

    StatusMenuItem {
        id: viewProfileMenuItem
        text: {
            if (chatItem) {
                switch (chatItem.chatType) {
                    case Constants.chatTypeOneToOne:
                      //% "View Profile"
                      return qsTrId("view-profile")
                    case Constants.chatTypePrivateGroupChat:
                      //% "View Group"
                      return qsTrId("view-group")
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
                return openPopup(groupInfoPopupComponent, {
                    channel: chatItem,
                    channelType: GroupInfoPopup.ChannelType.ContextChannel
                })
            }
        }
    }

    StatusMenuSeparator {
        visible: viewProfileMenuItem.enabled
    }


    Action {
        enabled: root.store.profileModelInst.fleets.fleet == Constants.waku_prod || root.store.profileModelInst.fleets.fleet === Constants.waku_test
        //% "Test WakuV2 - requestAllHistoricMessages"
        text: qsTrId("test-wakuv2---requestallhistoricmessages")
        onTriggered: root.store.chatsModelInst.requestAllHistoricMessages()
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
                return root.store.chatsModelInst.channelView.unmuteChatItem(chatItem.id)
            }
            root.store.chatsModelInst.channelView.muteChatItem(chatItem.id)
        }
    }

    StatusMenuItem {
        //% "Mark as Read"
        text: qsTrId("mark-as-read")
        icon.name: "checkmark-circle"
        enabled: chatItem && chatItem.chatType !== Constants.chatTypePrivateGroupChat
        onTriggered: root.store.chatsModelInst.channelView.markChatItemAsRead(chatItem.id)
    }

    StatusMenuItem {
        //% "Clear history"
        text: qsTrId("clear-history")
        icon.name: "close-circle"
        onTriggered: root.store.chatsModelInst.channelView.clearChatHistory(chatItem.id)
    }

    StatusMenuItem {
        //% "Edit Channel"
        text: qsTrId("edit-channel")
        icon.name: "edit"
        enabled: communityActive &&
            root.store.chatsModelInst.communities.activeCommunity.admin
        onTriggered: openPopup(editChannelPopup, {
            communityId: root.store.chatsModelInst.communities.activeCommunity.id,
            channel: chatItem
        })
    }

    StatusMenuItem {
        text: qsTr("Download")
        enabled: localAccountSensitiveSettings.downloadChannelMessagesEnabled
        icon.name: "download"
        onTriggered: downdloadDialog.open()
    }

    StatusMenuSeparator {
        visible: deleteOrLeaveMenuItem.enabled
    }

    StatusMenuItem {
        id: deleteOrLeaveMenuItem
        text: {
            if (communityActive) {
                return qsTr("Delete Channel")
            }
            return chatItem && chatItem.chatType === Constants.chatTypeOneToOne ?
                        //% "Delete chat"
                        qsTrId("delete-chat") :
                        //% "Leave chat"
                        qsTrId("leave-chat")
        }
        icon.name: chatItem && chatItem.chatType === Constants.chatTypeOneToOne || communityActive ? "delete" : "arrow-right"
        icon.width: chatItem && chatItem.chatType === Constants.chatTypeOneToOne || communityActive ? 18 : 14
        iconRotation: chatItem && chatItem.chatType === Constants.chatTypeOneToOne || communityActive ? 0 : 180

        type: StatusMenuItem.Type.Danger
        onTriggered: {
            openPopup(deleteChatConfirmationDialogComponent)
        }

        enabled: !communityActive || root.store.chatsModelInst.communities.activeCommunity.admin
    }

    FileDialog {
        id: downdloadDialog
        acceptLabel: qsTr("Save")
        fileMode: FileDialog.SaveFile
        title: qsTr("Download messages")
        currentFile: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/messages.json"
        defaultSuffix: "json"
        onAccepted: {
            root.store.chatsModelInst.messageView.downloadMessages(downdloadDialog.currentFile)
        }
    }

    Component {
        id: deleteChatConfirmationDialogComponent
        ConfirmationDialog {
            property string chatId: !!chatItem ? chatItem.id : ""
            btnType: "warn"
            header.title: communityActive ? qsTr("Delete #%1").arg(chatItem.name) :
                                            chatItem && chatItem.chatType === Constants.chatTypeOneToOne ?
                                            //% "Delete chat"
                                            qsTrId("delete-chat") :
                                            //% "Leave chat"
                                            qsTrId("leave-chat")
            confirmButtonLabel: communityActive ? qsTr("Delete") : header.title
            confirmationText: communityActive ? qsTr("Are you sure you want to delete #%1 channel?").arg(chatItem.name) :
                                                chatItem && chatItem.chatType === Constants.chatTypeOneToOne ?
                                                qsTr("Are you sure you want to delete this chat?"):
                                                qsTr("Are you sure you want to leave this chat?")
            showCancelButton: communityActive

            onClosed: {
                destroy()
            }
            onCancelButtonClicked: {
                close()
            }
            onConfirmButtonClicked: {
                if (communityActive) {
                    root.store.chatsModelInst.communities.deleteCommunityChat(root.store.chatsModelInst.communities.activeCommunity.id, chatId)
                } else {
                    root.store.chatsModelInst.channelView.leaveChat(chatId)
                }
                close();
            }
        }
    }
}
