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

    property string currentFleet: ""
    property bool isCommunityChat: false
    property bool isCommunityAdmin: false
    property string chatId: ""
    property string chatName: ""
    property string chatIcon: ""
    property int chatType: -1
    property bool chatMuted: false

    signal viewGroupOrProfile(string id)
    signal requestAllHistoricMessages(string id)
    signal unmuteChat(string id)
    signal muteChat(string id)
    signal markAllMessagesRead(string id)
    signal clearChatHistory(string id)
    signal editChannel(string id)
    signal downloadMessages(string file)
    signal deleteChat(string id)

    StatusMenuItem {
        id: viewProfileMenuItem
        text: {
            switch (root.chatType) {
            case Constants.chatType.oneToOne:
                //% "View Profile"
                return qsTrId("view-profile")
            case Constants.chatType.privateGroupChat:
                //% "View Group"
                return qsTrId("view-group")
            default:
                return ""
            }
        }
        icon.name: "group-chat"
        enabled: root.chatType === Constants.chatType.oneToOne ||
            root.chatType === Constants.chatType.privateGroupChat
        onTriggered: {
            if (root.chatType === Constants.chatType.oneToOne) {
                const userProfileImage = appMain.getProfileImage(root.chatId)
                return openProfilePopup(
                    root.chatName,
                    root.chatId,
                    root.chatIcon,
                    "",
                    root.chatName
                )
            }
            // Not Refactored Yet
//            if (root.chatType === Constants.chatType.privateGroupChat) {
//                return Global.openPopup(groupInfoPopupComponent, {
//                    channel: chatItem,
//                    channelType: GroupInfoPopup.ChannelType.ContextChannel
//                })
//            }
        }
    }

    StatusMenuSeparator {
        visible: viewProfileMenuItem.enabled
    }

    Action {
        enabled: root.currentFleet

        // Will be deleted later
//        enabled: root.store.profileModelInst.fleets.fleet == Constants.waku_prod ||
//                 root.store.profileModelInst.fleets.fleet === Constants.waku_test

        //% "Test WakuV2 - requestAllHistoricMessages"
        text: qsTrId("test-wakuv2---requestallhistoricmessages")
        onTriggered: {
            root.requestAllHistoricMessages(root.chatId)
        }

        // Will be deleted later
        //onTriggered: root.store.chatsModelInst.requestAllHistoricMessages()
    }

    StatusMenuItem {
        text: root.chatMuted ?
              //% "Unmute chat"
              qsTrId("unmute-chat") : 
              //% "Mute chat"
              qsTrId("mute-chat")
        icon.name: "notification"
        enabled: root.chatType !== Constants.chatType.privateGroupChat
        onTriggered: {
            if(root.chatMuted)
                root.unmuteChat(root.chatId)
            else
                root.muteChat(root.chatId)
        }
    }

    StatusMenuItem {
        //% "Mark as Read"
        text: qsTrId("mark-as-read")
        icon.name: "checkmark-circle"
        enabled: root.chatType !== Constants.chatType.privateGroupChat
        onTriggered: {
            root.markAllMessagesRead(root.chatId)
        }

        // Will be deleted later
        //onTriggered: root.store.chatsModelInst.channelView.markChatItemAsRead(chatItem.id)
    }

    StatusMenuItem {
        //% "Clear history"
        text: qsTrId("clear-history")
        icon.name: "close-circle"
        onTriggered: {
            root.clearChatHistory(root.chatId)
        }

        // Will be deleted later
        //onTriggered: root.store.chatsModelInst.channelView.clearChatHistory(chatItem.id)
    }

    StatusMenuItem {
        //% "Edit Channel"
        text: qsTrId("edit-channel")
        icon.name: "edit"
        // Not Refactored Yet
//        enabled: communityActive &&
//            root.store.chatsModelInst.communities.activeCommunity.admin
        // Not Refactored Yet
//        onTriggered: Global.openPopup(editChannelPopup, {
//            store: root.store,
//            communityId: root.store.chatsModelInst.communities.activeCommunity.id,
//            channel: chatItem
//        })
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
            if (isCommunityChat) {
                return qsTr("Delete Channel")
            }
            return root.chatType === Constants.chatType.oneToOne ?
                        //% "Delete chat"
                        qsTrId("delete-chat") :
                        //% "Leave chat"
                        qsTrId("leave-chat")
        }
        icon.name: root.chatType === Constants.chatType.oneToOne || isCommunityChat ? "delete" : "arrow-right"
        icon.width: root.chatType === Constants.chatType.oneToOne || isCommunityChat ? 18 : 14
        iconRotation: root.chatType === Constants.chatType.oneToOne || isCommunityChat ? 0 : 180

        type: StatusMenuItem.Type.Danger
        onTriggered: {
            Global.openPopup(deleteChatConfirmationDialogComponent)
        }

        enabled: !isCommunityChat || isCommunityAdmin

        // Will be deleted later
//        enabled: !communityActive || root.store.chatsModelInst.communities.activeCommunity.admin
    }

    FileDialog {
        id: downdloadDialog
        acceptLabel: qsTr("Save")
        fileMode: FileDialog.SaveFile
        title: qsTr("Download messages")
        currentFile: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/messages.json"
        defaultSuffix: "json"

        onAccepted: {
            root.downloadMessages(downdloadDialog.currentFile)
        }

        // Will be deleted later
//        onAccepted: {
//            root.store.chatsModelInst.messageView.downloadMessages(downdloadDialog.currentFile)
//        }
    }

    Component {
        id: deleteChatConfirmationDialogComponent
        ConfirmationDialog {
            btnType: "warn"
            header.title: isCommunityChat ? qsTr("Delete #%1").arg(root.chatName) :
                                            root.chatType === Constants.chatType.oneToOne ?
                                            //% "Delete chat"
                                            qsTrId("delete-chat") :
                                            //% "Leave chat"
                                            qsTrId("leave-chat")
            confirmButtonLabel: isCommunityChat ? qsTr("Delete") : header.title
            confirmationText: isCommunityChat ? qsTr("Are you sure you want to delete #%1 channel?").arg(root.chatName) :
                                                root.chatType === Constants.chatType.oneToOne ?
                                                qsTr("Are you sure you want to delete this chat?"):
                                                qsTr("Are you sure you want to leave this chat?")
            showCancelButton: isCommunityChat

            onClosed: {
                destroy()
            }
            onCancelButtonClicked: {
                close()
            }
            onConfirmButtonClicked: {
                root.deleteChat(root.chatId)
            }

            // Will be deleted later
//            onConfirmButtonClicked: {
//                if (communityActive) {
//                    root.store.chatsModelInst.communities.deleteCommunityChat(root.store.chatsModelInst.communities.activeCommunity.id, chatId)
//                } else {
//                    root.store.chatsModelInst.channelView.leaveChat(chatId)
//                }
//                close();
//            }
        }
    }
}
