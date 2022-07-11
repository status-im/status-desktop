import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQuick.Dialogs 1.0

import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0

StatusPopupMenu {
    id: root

    property var store
    property var reactionModel
    property alias emojiContainer: emojiContainer

    property string myPublicKey: ""
    property bool amIChatAdmin: false
    property bool pinMessageAllowedForMembers: false

    property int chatType: Constants.chatType.publicChat
    property string messageId: ""
    property string messageSenderId: ""
    property int messageContentType: Constants.messageContentType.unknownContentType
    property string selectedUserPublicKey: ""
    property string selectedUserDisplayName: ""
    property string selectedUserIcon: ""
    property string imageSource: ""

    property bool isProfile: false
    property bool isRightClickOnImage: false
    property bool pinnedPopup: false
    property bool isDebugEnabled: false
    property bool isEmoji: false
    property bool isSticker: false
    property bool hideEmojiPicker: true
    property bool pinnedMessage: false
    property bool canPin: false

    readonly property bool isMyMessage: {
        return root.messageSenderId !== "" && root.messageSenderId == root.myPublicKey;
    }
    readonly property bool isMe: {
        return root.selectedUserPublicKey == root.store.contactsStore.myPublicKey;
    }
    readonly property bool isMyMutualContact: {
        return root.selectedUserPublicKey !== "" && root.store.contactsStore.isMyMutualContact(root.selectedUserPublicKey);
    }
    readonly property bool isBlockedContact: {
        return root.selectedUserPublicKey !== "" && root.store.contactsStore.isBlockedContact(root.selectedUserPublicKey);
    }
    readonly property bool hasPendingContactRequest: {
        return root.selectedUserPublicKey !== "" && root.store.contactsStore.hasPendingContactRequest(root.selectedUserPublicKey);
    }

    property var setXPosition: function() {return 0}
    property var setYPosition: function() {return 0}

    property var emojiReactionsReactedByUser: []

    signal openProfileClicked(string publicKey, string state)
    signal pinMessage(string messageId)
    signal unpinMessage(string messageId)
    signal pinnedMessagesLimitReached(string messageId)
    signal jumpToMessage(string messageId)
    signal shouldCloseParentPopup()
    signal createOneToOneChat(string communityId, string chatId, string ensName)
    signal showReplyArea()
    signal toggleReaction(string messageId, int emojiId)
    signal deleteMessage(string messageId)
    signal editClicked(string messageId)

    function show(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, emojiReactionsModel) {
        let newEmojiReactions = []
        if (!!emojiReactionsModel) {
            emojiReactionsModel.forEach(function (emojiReaction) {
                newEmojiReactions[emojiReaction.emojiId] = emojiReaction.currentUserReacted
            })
        }
        root.emojiReactionsReactedByUser = newEmojiReactions;

        /* // copy link feature not ready yet
        const numLinkUrls = root.linkUrls.split(" ").length
        copyLinkMenu.enabled = numLinkUrls > 1
        copyLinkAction.enabled = !!root.linkUrls && numLinkUrls === 1 && !isEmoji && !root.isProfile
        */
        popup()
    }

    onClosed: {
        // Reset selectedUserPublicKey so that associated properties get recalculated on re-open
        selectedUserPublicKey = ""
    }

    onHeightChanged: { root.y = setYPosition(); }
    onWidthChanged: { root.x = setXPosition(); }
    onOpened: {
        // Trigger x and y position:
        x = setXPosition()
        y = setYPosition()
    }

    width: Math.max(emojiContainer.visible ? emojiContainer.width : 0, 200)

    Item {
        id: emojiContainer
        width: emojiRow.width
        height: visible ? emojiRow.height : 0
        visible: !root.hideEmojiPicker && (root.isEmoji || !root.isProfile) && !root.pinnedPopup
        Row {
            id: emojiRow
            spacing: Style.current.halfPadding
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
            bottomPadding: root.isEmoji ? 0 : Style.current.padding

            Repeater {
                model: root.reactionModel
                delegate: EmojiReaction {
                    source: Style.svg(filename)
                    emojiId: model.emojiId
                    reactedByUser: !!root.emojiReactionsReactedByUser[model.emojiId]
                    onCloseModal: {
                        root.toggleReaction(root.messageId, emojiId)
                        root.close()
                    }
                }
            }
        }
    }

    ProfileHeader {
        width: parent.width
        visible: root.isProfile

        displayName: root.selectedUserDisplayName
        pubkey: root.selectedUserPublicKey
        icon: root.selectedUserIcon
    }

    Item {
        visible: root.isProfile
        height: root.topPadding
    }

    Separator {
        anchors.bottom: viewProfileAction.top
        visible: !root.isEmoji && !root.hideEmojiPicker && !pinnedPopup
    }

    StatusMenuItem {
        id: copyImageAction
        text: qsTr("Copy image")
        onTriggered: {
            if (root.imageSource) {
                root.store.copyImageToClipboardByUrl(root.imageSource)
            }
            root.close()
        }
        icon.name: "copy"
        enabled: root.isRightClickOnImage && !root.pinnedPopup
    }

    StatusMenuItem {
        id: downloadImageAction
        text: qsTr("Download image")
        onTriggered: {
            fileDialog.open()
            root.close()
        }
        icon.name: "download"
        enabled: root.isRightClickOnImage && !root.pinnedPopup
    }

    ViewProfileMenuItem {
        id: viewProfileAction
        enabled: root.isProfile && !root.pinnedPopup
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey, "")
            root.close()
        }
    }

    SendMessageMenuItem {
        id: sendMessageMenuItem
        enabled: root.isProfile && root.isMyMutualContact && !root.isBlockedContact
        onTriggered: {
            root.createOneToOneChat("", root.selectedUserPublicKey, "")
            root.close()
        }
    }

    SendContactRequestMenuItem {
        enabled: root.isProfile && !root.isMe && !root.isMyMutualContact
                                && !root.isBlockedContact && !root.hasPendingContactRequest
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey, "contactRequest")
            root.close()
        }
    }

    StatusMenuItem {
        text: qsTr("Block User")
        icon.name: "cancel"
        icon.color: Style.current.danger
        enabled: root.isProfile && !root.isMe && !root.isBlockedContact
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey, "blockUser")
            root.close()
        }
    }

    StatusMenuItem {
        text: qsTr("Unblock User")
        icon.name: "remove"
        enabled: root.isProfile && !root.isMe && root.isBlockedContact
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey, "unblockUser")
            root.close()
        }
    }

    StatusMenuItem {
        text: qsTr("Rename")
        icon.name: "edit_pencil"
        enabled: root.isProfile && !root.isMe
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey, "openNickname")
            root.close()
        }
    }

    StatusMenuItem {
        id: replyToMenuItem
        text: qsTr("Reply to")
        icon.name: "chat"
        onTriggered: {
            root.showReplyArea()
            root.close()
        }
        enabled: (!root.hideEmojiPicker &&
                  !root.isEmoji &&
                  !root.isProfile &&
                  !root.pinnedPopup &&
                  !root.isRightClickOnImage)
    }

    StatusMenuItem {
        id: editMessageAction
        text: qsTr("Edit message")
        onTriggered: {
            editClicked(messageId)
        }
        icon.name: "edit"
        enabled: root.isMyMessage &&
                 !root.hideEmojiPicker &&
                 !root.isEmoji &&
                 !root.isSticker &&
                 !root.isProfile &&
                 !root.pinnedPopup &&
                 !root.isRightClickOnImage
    }

    StatusMenuItem {
        id: copyMessageIdAction
        text: qsTr("Copy Message Id")
        icon.name: "chat"
        enabled: root.isDebugEnabled && !pinnedPopup
        onTriggered: {
            root.store.copyToClipboard(SelectedMessage.messageId)
            close()
        }
    }

    StatusMenuItem {
        id: pinAction
        text: {
            if (root.pinnedMessage) {
                return qsTr("Unpin")
            }
            return qsTr("Pin")

        }
        onTriggered: {
            if (root.pinnedMessage) {
                root.unpinMessage(root.messageId)
                return
            }

            if (!root.canPin) {
                root.pinnedMessagesLimitReached(root.messageId)
                return
            }

            root.pinMessage(root.messageId)
            root.close()
        }
        icon.name: "pin"
        enabled: {
            if(root.isProfile || root.isEmoji || root.isRightClickOnImage)
                return false

            switch (root.chatType) {
            case Constants.chatType.publicChat:
                return false
            case Constants.chatType.profile:
                return false
            case Constants.chatType.oneToOne:
                return true
            case Constants.chatType.privateGroupChat:
                return root.amIChatAdmin
            case Constants.chatType.communityChat:
                return root.amIChatAdmin || root.pinMessageAllowedForMembers
            default:
                return false
            }
        }
    }

    StatusMenuSeparator {
        visible: deleteMessageAction.enabled &&
                 (viewProfileAction.enabled ||
                  sendMessageMenuItem.enabled ||
                  replyToMenuItem.enabled ||
                  editMessageAction.enabled ||
                  pinAction.enabled)
    }

    StatusMenuItem {
        id: deleteMessageAction
        enabled: root.isMyMessage &&
                 !root.isProfile &&
                 !root.isEmoji &&
                 !root.pinnedPopup &&
                 !root.isRightClickOnImage &&
                 (root.messageContentType === Constants.messageContentType.messageType ||
                  root.messageContentType === Constants.messageContentType.stickerType ||
                  root.messageContentType === Constants.messageContentType.emojiType ||
                  root.messageContentType === Constants.messageContentType.imageType ||
                  root.messageContentType === Constants.messageContentType.audioType)
        text: qsTr("Delete message")
        onTriggered: {
            if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                deleteMessage(messageId)
            }
            else {
                Global.openPopup(deleteMessageConfirmationDialogComponent)
            }
        }
        icon.name: "delete"
        type: StatusMenuItem.Type.Danger
    }

    StatusMenuItem {
        id: jumpToAction
        enabled: root.pinnedPopup
        text: qsTr("Jump to")
        onTriggered: {
            root.jumpToMessage(root.messageId)
            root.close()
            root.shouldCloseParentPopup()
        }
        icon.name: "arrow-up"
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a directory")
        selectFolder: true
        modality: Qt.NonModal
        onAccepted: {
            if (root.imageSource) {
                root.store.downloadImageByUrl(root.imageSource, fileDialog.fileUrls)
            }
            fileDialog.close()
        }
        onRejected: {
            fileDialog.close()
        }
    }

    Component {
        id: deleteMessageConfirmationDialogComponent
        ConfirmationDialog {
            header.title: qsTr("Confirm deleting this message")
            confirmationText: qsTr("Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well.")
            height: 260
            checkbox.visible: true
            executeConfirm: function () {
                if (checkbox.checked) {
                    localAccountSensitiveSettings.showDeleteMessageWarning = false
                }

                close()
                root.deleteMessage(messageId)
            }
            onClosed: {
                destroy()
            }
        }
    }
}
