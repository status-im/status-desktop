import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1

import utils 1.0
import StatusQ.Popups 0.1

import shared.popups 1.0
import shared.controls.chat.menuItems 1.0
import AppLayouts.Communities.popups 1.0

StatusMenu {
    id: root

    property string currentFleet: ""
    property bool isCommunityChat: false
    property bool amIChatAdmin: false
    property string chatId: ""
    property string chatName: ""
    property string chatDescription: ""
    property string chatEmoji: ""
    property string chatColor: ""
    property string chatIcon: ""
    property int chatType: -1
    property bool chatMuted: false
    property int channelPosition: -1
    property string chatCategoryId: ""
    property var emojiPopup

    signal displayProfilePopup(string publicKey)
    signal requestAllHistoricMessages(string chatId)
    signal unmuteChat(string chatId)
    signal muteChat(string chatId, int interval)
    signal markAllMessagesRead(string chatId)
    signal clearChatHistory(string chatId)
    signal downloadMessages(string file)
    signal deleteCommunityChat(string chatId)
    signal leaveChat(string chatId)
    signal leaveGroup(string chatId)
    signal updateGroupChatDetails(string chatId, string groupName, string groupColor, string groupImage)

    signal createCommunityChannel(string chatId, string newName, string newDescription, string newEmoji, string newColor)
    signal editCommunityChannel(string chatId, string newName, string newDescription, string newEmoji, string newColor, string newCategory)
    signal fetchMoreMessages(int timeFrame)
    signal addRemoveGroupMember()

    width: root.amIChatAdmin && (root.chatType === Constants.chatType.privateGroupChat) ? 207 : implicitWidth

    ViewProfileMenuItem {
        enabled: root.chatType === Constants.chatType.oneToOne
        onTriggered: root.displayProfilePopup(root.chatId)
    }

    StatusAction {
        text: root.amIChatAdmin ? qsTr("Add / remove from group") : qsTr("Add to group")
        icon.name: "add-to-dm"
        enabled: (root.chatType === Constants.chatType.privateGroupChat)
        onTriggered: { root.addRemoveGroupMember() }
    }

    StatusMenuSeparator {
        visible: root.chatType === Constants.chatType.oneToOne || root.chatType === Constants.chatType.privateGroupChat
    }

    StatusAction {
        objectName: "editNameAndImageMenuItem"
        text: qsTr("Edit name and image")
        icon.name: "edit_pencil"
        enabled: root.chatType === Constants.chatType.privateGroupChat
        onTriggered: {
            Global.openPopup(renameGroupPopupComponent, {
                activeGroupName: root.chatName,
                activeGroupColor: root.chatColor,
                activeGroupImageData: root.chatIcon
            });
        }
    }

    Component {
        id: renameGroupPopupComponent
        RenameGroupPopup {
            onUpdateGroupChatDetails: {
                root.updateGroupChatDetails(root.chatId, groupName, groupColor, groupImage)
                close()
            }
        }
    }

    MuteChatMenuItem {
        enabled: !root.chatMuted
        isCommunityChat: root.isCommunityChat

        onMuteTriggered: {
            root.muteChat(root.chatId, interval)
        }
    }

    StatusAction {
        enabled: root.chatMuted
        text: root.isCommunityChat ? qsTr("Unmute Channel") : qsTr("Unmute Chat")
        icon.name: "notification"
        onTriggered: {
            root.unmuteChat(root.chatId)
        }
    }

    StatusAction {
        objectName: "chatMarkAsReadMenuItem"
        text: qsTr("Mark as Read")
        icon.name: "checkmark-circle"
        onTriggered: {
            root.markAllMessagesRead(root.chatId)
        }
    }

    //TODO uncomment when implemented
//    StatusMenu {
//        title: qsTr("Fetch messages")
//        enabled: (root.chatType === Constants.chatType.oneToOne ||
//                  root.chatType === Constants.chatType.privateGroupChat)
//        StatusAction {
//            text: "Last 24 hours"
//            onTriggered: {
//                root.fetchMoreMessages();
//            }
//        }

//        StatusAction {
//            text: "Last 2 days"
//            onTriggered: {

//            }
//        }

//        StatusAction {
//            text: "Last 3 days"
//            onTriggered: {

//            }
//        }

//        StatusAction {
//            text: "Last 7 days"
//            onTriggered: {

//            }
//        }
//    }

    StatusAction {
        objectName: "clearHistoryMenuItem"
        text: qsTr("Clear History")
        icon.name: "close-circle"
        onTriggered: {
            root.clearChatHistory(root.chatId)
        }
    }

    StatusAction {
        objectName: "editChannelMenuItem"
        text: qsTr("Edit Channel")
        icon.name: "edit"
        enabled: root.isCommunityChat && root.amIChatAdmin
        onTriggered: {
            Global.openPopup(editChannelPopup, {
                isEdit: true,
                channelName: root.chatName,
                channelDescription: root.chatDescription,
                channelEmoji: root.chatEmoji,
                channelColor: root.chatColor,
                categoryId: root.chatCategoryId
            });
        }
    }

    Component {
        id: editChannelPopup
        CreateChannelPopup {
            anchors.centerIn: parent
            isEdit: true
            isDeleteable: root.isCommunityChat
            emojiPopup: root.emojiPopup
            onCreateCommunityChannel: {
                root.createCommunityChannel(root.chatId, chName, chDescription, chEmoji, chColor);
            }
            onEditCommunityChannel: {
                root.editCommunityChannel(root.chatId, chName, chDescription, chEmoji, chColor,
                    chCategoryId);
            }
            onDeleteCommunityChannel: {
                Global.openPopup(deleteChatConfirmationDialogComponent)
                close()
            }
            onClosed: {
                destroy()
            }
        }
    }

    StatusAction {
        text: qsTr("Download")
        enabled: localAccountSensitiveSettings.downloadChannelMessagesEnabled
        icon.name: "download"
        onTriggered: downloadDialog.open()
    }

    StatusMenuSeparator {
        visible: deleteOrLeaveMenuItem.enabled
    }

    StatusAction {
        objectName: "deleteOrLeaveMenuItem"
        id: deleteOrLeaveMenuItem
        text: {
            if (root.isCommunityChat) {
                return qsTr("Delete Channel")
            }
            if (root.chatType === Constants.chatType.privateGroupChat) {
                return qsTr("Leave group")
            }
            return root.chatType === Constants.chatType.oneToOne ?
                        qsTr("Delete Chat") :
                        qsTr("Leave Chat")
        }
        icon.name: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? "delete" : "arrow-left"
        icon.width: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? 18 : 14

        type: StatusAction.Type.Danger
        onTriggered: {
            if (root.chatType === Constants.chatType.privateGroupChat) {
                root.leaveChat(root.chatId);
            } else {
                Global.openPopup(deleteChatConfirmationDialogComponent);
            }
        }

        enabled: !root.isCommunityChat || root.amIChatAdmin
    }

    FileDialog {
        id: downloadDialog
        acceptLabel: qsTr("Save")
        fileMode: FileDialog.SaveFile
        title: qsTr("Download messages")
        currentFile: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/messages.json"
        defaultSuffix: "json"

        onAccepted: {
            root.downloadMessages(downloadDialog.currentFile)
        }
    }

    Component {
        id: deleteChatConfirmationDialogComponent
        ConfirmationDialog {
            confirmButtonObjectName: "deleteChatConfirmationDialogDeleteButton"
            btnType: "warn"
            headerSettings.title: root.isCommunityChat ? qsTr("Delete #%1").arg(root.chatName) :
                                            root.chatType === Constants.chatType.oneToOne ?
                                            qsTr("Delete chat") :
                                            qsTr("Leave chat")
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
                    root.deleteCommunityChat(root.chatId)
                else
                    root.leaveChat(root.chatId)

                close()
            }
        }
    }
}
