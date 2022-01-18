import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1

import utils 1.0
import StatusQ.Popups 0.1

import shared.popups 1.0
import "../popups"
import "../popups/community"

StatusPopupMenu {
    id: root

    property string currentFleet: ""
    property bool isCommunityChat: false
    property bool amIChatAdmin: false
    property string chatId: ""
    property string chatName: ""
    property string chatDescription: ""
    property string chatIcon: ""
    property int chatType: -1
    property bool chatMuted: false

    signal displayProfilePopup(string publicKey)
    signal displayGroupInfoPopup(string chatId)
    signal requestAllHistoricMessages(string chatId)
    signal unmuteChat(string chatId)
    signal muteChat(string chatId)
    signal markAllMessagesRead(string chatId)
    signal clearChatHistory(string chatId)
    signal downloadMessages(string file)
    signal deleteChat(string chatId)
    signal leaveChat(string chatId)

    signal openPinnedMessagesList(string chatId)
    signal createCommunityChannel(string chatId, string newName, string newDescription)
    signal editCommunityChannel(string chatId, string newName, string newDescription)

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
                root.displayProfilePopup(root.chatId)
            }
            if (root.chatType === Constants.chatType.privateGroupChat) {
                root.displayGroupInfoPopup(root.chatId)
            }
        }
    }

    StatusMenuSeparator {
        visible: viewProfileMenuItem.enabled
    }

    Action {
        enabled: root.currentFleet == Constants.waku_prod ||
                 root.currentFleet === Constants.waku_test

        //% "Test WakuV2 - requestAllHistoricMessages"
        text: qsTrId("test-wakuv2---requestallhistoricmessages")
        onTriggered: {
            root.requestAllHistoricMessages(root.chatId)
        }
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
    }

    StatusMenuItem {
        //% "Clear history"
        text: qsTrId("clear-history")
        icon.name: "close-circle"
        onTriggered: {
            root.clearChatHistory(root.chatId)
        }
    }

    StatusMenuItem {
        //% "Edit Channel"
        text: qsTrId("edit-channel")
        icon.name: "edit"
        enabled: root.isCommunityChat && root.amIChatAdmin
        onTriggered: {
            Global.openPopup(editChannelPopup, {
                isEdit: true,
                channelName: root.chatName,
                channelDescription: root.chatDescription
            });
        }
    }

    Component {
        id: editChannelPopup
        CreateChannelPopup {
            anchors.centerIn: parent
            isEdit: true
            onCreateCommunityChannel: {
                root.createCommunityChannel(root.chatId, chName, chDescription);
            }
            onEditCommunityChannel: {
                root.editCommunityChannel(root.chatId, chName, chDescription);
            }
            onOpenPinnedMessagesPopup: {
                root.openPinnedMessagesList(root.chatId, chName, chDescription);
            }
            onClosed: {
                destroy()
            }
        }
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
            if (root.isCommunityChat) {
                return qsTr("Delete Channel")
            }
            return root.chatType === Constants.chatType.oneToOne ?
                        //% "Delete chat"
                        qsTrId("delete-chat") :
                        //% "Leave chat"
                        qsTrId("leave-chat")
        }
        icon.name: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? "delete" : "arrow-right"
        icon.width: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? 18 : 14
        iconRotation: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? 0 : 180

        type: StatusMenuItem.Type.Danger
        onTriggered: {
            Global.openPopup(deleteChatConfirmationDialogComponent)
        }

        enabled: !root.isCommunityChat || root.amIChatAdmin
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
    }

    Component {
        id: deleteChatConfirmationDialogComponent
        ConfirmationDialog {
            btnType: "warn"
            header.title: root.isCommunityChat ? qsTr("Delete #%1").arg(root.chatName) :
                                            root.chatType === Constants.chatType.oneToOne ?
                                            //% "Delete chat"
                                            qsTrId("delete-chat") :
                                            //% "Leave chat"
                                            qsTrId("leave-chat")
            confirmButtonLabel: root.isCommunityChat ? qsTr("Delete") : header.title
            confirmationText: root.isCommunityChat ? qsTr("Are you sure you want to delete #%1 channel?").arg(root.chatName) :
                                                root.chatType === Constants.chatType.oneToOne ?
                                                qsTr("Are you sure you want to delete this chat?"):
                                                qsTr("Are you sure you want to leave this chat?")
            showCancelButton: root.isCommunityChat

            onClosed: {
                destroy()
            }
            onCancelButtonClicked: {
                close()
            }
            onConfirmButtonClicked: {
                if(root.isCommunityChat)
                    root.deleteChat(root.chatId)
                else
                    root.leaveChat(root.chatId)

                close()
            }
        }
    }
}
