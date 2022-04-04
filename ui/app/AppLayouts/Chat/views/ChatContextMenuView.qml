import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.platform 1.1

import utils 1.0
import StatusQ.Popups 0.1

import shared.popups 1.0
import shared.controls.chat.menuItems 1.0
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
    property string chatEmoji: ""
    property string chatColor: ""
    property string chatIcon: ""
    property int chatType: -1
    property bool chatMuted: false
    property int channelPosition: -1
    property string chatCategoryId: ""
    property var emojiPopup

    signal displayProfilePopup(string publicKey)
    signal displayGroupInfoPopup(string chatId)
    signal requestAllHistoricMessages(string chatId)
    signal unmuteChat(string chatId)
    signal muteChat(string chatId)
    signal markAllMessagesRead(string chatId)
    signal clearChatHistory(string chatId)
    signal downloadMessages(string file)
    signal deleteCommunityChat(string chatId)
    signal leaveChat(string chatId)
    signal leaveGroup(string chatId)
    signal renameGroupChat(string chatId, string groupName)

    signal createCommunityChannel(string chatId, string newName, string newDescription, string newEmoji, string newColor)
    signal editCommunityChannel(string chatId, string newName, string newDescription, string newEmoji, string newColor, string newCategory)
    signal fetchMoreMessages(int timeFrame)
    signal addRemoveGroupMember()

    width: root.amIChatAdmin && (root.chatType === Constants.chatType.privateGroupChat) ? 207 : implicitWidth

    ViewProfileMenuItem {
        enabled: root.chatType === Constants.chatType.oneToOne
        onTriggered: root.displayProfilePopup(root.chatId)
    }

    StatusMenuItem {
        text: qsTr("View Members")
        icon.name: "group-chat"
        enabled: root.chatType === Constants.chatType.privateGroupChat
        onTriggered: root.displayGroupInfoPopup(root.chatId)
    }

    StatusMenuItem {
        text: qsTr("Add / remove from group")
        icon.name: "add-to-dm"
        enabled: root.amIChatAdmin && (root.chatType === Constants.chatType.privateGroupChat)
        onTriggered: { root.addRemoveGroupMember() }
    }

    StatusMenuSeparator {
        visible: root.chatType === Constants.chatType.oneToOne || root.chatType === Constants.chatType.privateGroupChat
    }

    Action {
        enabled: root.currentFleet === Constants.waku_prod   ||
                 root.currentFleet === Constants.waku_test   ||
                 root.currentFleet === Constants.status_test ||
                 root.currentFleet === Constants.status_prod

        text: qsTr("Test WakuV2 - requestAllHistoricMessages")
        onTriggered: {
            root.requestAllHistoricMessages(root.chatId)
        }
    }

    StatusMenuItem {
        text: qsTr("Edit name")
        icon.name: "edit"
        enabled: root.chatType === Constants.chatType.privateGroupChat
                 && root.amIChatAdmin
        onTriggered: {
            Global.openPopup(renameGroupPopupComponent, {
                activeChannelName: root.chatName,
            });
        }
    }

    Component {
        id: renameGroupPopupComponent
        RenameGroupPopup {
            onDoRename: {
                root.renameGroupChat(root.chatId, groupName)
                close()
            }
        }
    }

    MuteChatMenuItem {
        muted: root.chatMuted
        onTriggered: {
            if(root.chatMuted)
                root.unmuteChat(root.chatId)
            else
                root.muteChat(root.chatId)
        }
    }

    StatusMenuItem {
        text: qsTr("Mark as Read")
        icon.name: "checkmark-circle"
        onTriggered: {
            root.markAllMessagesRead(root.chatId)
        }
    }

    //TODO uncomment when implemented
//    StatusPopupMenu {
//        title: qsTr("Fetch messages")
//        enabled: (root.chatType === Constants.chatType.oneToOne ||
//                  root.chatType === Constants.chatType.privateGroupChat)
//        StatusMenuItem {
//            text: "Last 24 hours"
//            onTriggered: {
//                root.fetchMoreMessages();
//            }
//        }

//        StatusMenuItem {
//            text: "Last 2 days"
//            onTriggered: {

//            }
//        }

//        StatusMenuItem {
//            text: "Last 3 days"
//            onTriggered: {

//            }
//        }

//        StatusMenuItem {
//            text: "Last 7 days"
//            onTriggered: {

//            }
//        }
//    }

    StatusMenuItem {
        text: qsTr("Clear history")
        icon.name: "close-circle"
        onTriggered: {
            root.clearChatHistory(root.chatId)
        }
    }

    StatusMenuItem {
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
            emojiPopup: root.emojiPopup
            onCreateCommunityChannel: {
                root.createCommunityChannel(root.chatId, chName, chDescription, chEmoji, chColor);
            }
            onEditCommunityChannel: {
                root.editCommunityChannel(root.chatId, chName, chDescription, chEmoji, chColor,
                    chCategoryId);
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
            if (root.chatType === Constants.chatType.privateGroupChat) {
                return qsTr("Leave group")
            }
            return root.chatType === Constants.chatType.oneToOne ?
                        qsTr("Delete chat") :
                        qsTr("Leave chat")
        }
        icon.name: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? "delete" : "arrow-right"
        icon.width: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? 18 : 14
        iconRotation: root.chatType === Constants.chatType.oneToOne || root.isCommunityChat ? 0 : 180

        type: StatusMenuItem.Type.Danger
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
