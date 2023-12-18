import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0

StatusMenu {
    id: root

    property var store
    property var reactionModel: []

    property string myPublicKey: ""
    property bool amIChatAdmin: false
    property bool disabledForChat: false

    property int chatType: Constants.chatType.unknown
    property string messageId: ""
    property string unparsedText: ""
    property string messageSenderId: ""
    property int messageContentType: Constants.messageContentType.unknownContentType

    property bool pinMessageAllowedForMembers: false
    property bool isDebugEnabled: store && store.isDebugEnabled
    property bool editRestricted: false
    property bool pinnedMessage: false
    property bool canPin: false

    readonly property bool isMyMessage: {
        return root.messageSenderId !== "" && root.messageSenderId === root.myPublicKey;
    }

    signal pinMessage(string messageId)
    signal unpinMessage(string messageId)
    signal pinnedMessagesLimitReached(string messageId)
    signal showReplyArea(string messageId, string messageSenderId)
    signal toggleReaction(string messageId, int emojiId)
    signal deleteMessage(string messageId)
    signal editClicked(string messageId)
    signal markMessageAsUnread(string messageId)

    width: Math.max(emojiContainer.visible ? emojiContainer.width : 0, 230)

    Item {
        id: emojiContainer
        width: emojiRow.width
        height: visible ? emojiRow.height : 0
        visible: !root.disabledForChat

        MessageReactionsRow {
            id: emojiRow
            reactionsModel: root.reactionModel
            bottomPadding: Style.current.padding
            onToggleReaction: {
                root.toggleReaction(root.messageId, emojiId)
                close()
            }
        }
    }

    StatusMenuSeparator {
        visible: emojiContainer.visible
    }

    StatusAction {
        id: replyToMenuItem
        text: qsTr("Reply to")
        icon.name: "chat"
        onTriggered: {
            root.showReplyArea(root.messageId, root.messageSenderId)
            root.close()
        }
        enabled: !root.disabledForChat
    }

    StatusAction {
        id: editMessageAction
        text: qsTr("Edit message")
        onTriggered: {
            editClicked(messageId)
        }
        icon.name: "edit"
        enabled: root.isMyMessage &&
                 !root.editRestricted &&
                 !root.disabledForChat
    }

    StatusAction {
        id: copyMessageMenuItem
        text: qsTr("Copy message")
        icon.name: "copy"
        onTriggered: {
            root.store.copyToClipboard(root.unparsedText)
            close()
        }
        enabled: root.messageContentType === Constants.messageContentType.messageType && replyToMenuItem.enabled
    }

    StatusAction {
        id: copyMessageIdAction
        text: qsTr("Copy Message Id")
        icon.name: "copy"
        enabled: root.isDebugEnabled && replyToMenuItem.enabled
        onTriggered: {
            root.store.copyToClipboard(root.messageId)
            close()
        }
    }

    StatusAction {
        id: pinAction
        text: root.pinnedMessage ? qsTr("Unpin") : qsTr("Pin")
        icon.name: root.pinnedMessage ? "unpin" : "pin"
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
        enabled: {
            if (root.disabledForChat)
                return false

            switch (root.chatType) {
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

    StatusAction {
        id: markMessageAsUnreadAction
        text: qsTr("Mark as unread")
        icon.name: "hide"
        enabled: !root.disabledForChat
        onTriggered: {
            root.markMessageAsUnread(root.messageId)
            root.close()
        }
    }

    StatusMenuSeparator {
        visible: deleteMessageAction.enabled &&
                 (replyToMenuItem.enabled ||
                  copyMessageMenuItem.enabled ||
                  copyMessageIdAction ||
                  editMessageAction.enabled ||
                  pinAction.enabled)
    }

    StatusAction {
        id: deleteMessageAction
        enabled: (root.isMyMessage || root.amIChatAdmin) &&
                 !root.disabledForChat &&
                 (root.messageContentType === Constants.messageContentType.messageType ||
                  root.messageContentType === Constants.messageContentType.stickerType ||
                  root.messageContentType === Constants.messageContentType.emojiType ||
                  root.messageContentType === Constants.messageContentType.imageType ||
                  root.messageContentType === Constants.messageContentType.audioType)
        text: qsTr("Delete message")
        icon.name: "delete"
        type: StatusAction.Type.Danger
        onTriggered: {
            root.deleteMessage(messageId)
        }
    }
}
