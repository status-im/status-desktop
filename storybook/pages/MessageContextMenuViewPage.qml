import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import Storybook

import utils
import shared.views.chat

SplitView {
    id: root

    Logs { id: logs }

    ListModel {
        id: defaultEmojiReactionsModel
        ListElement {
            emoji: "❤️"
            filename: "emojiReactions/heart"
            didIReactWithThisEmoji: false
        }
        ListElement {
            emoji: "👍"
            filename: "emojiReactions/thumbsUp"
            didIReactWithThisEmoji: false
        }
        ListElement {
            emoji: "👎"
            filename: "emojiReactions/thumbsDown"
            didIReactWithThisEmoji: false
        }
        ListElement {
            emoji: "😂"
            filename: "emojiReactions/laughing"
            didIReactWithThisEmoji: false
        }
        ListElement {
            emoji: "😢"
            filename: "emojiReactions/sad"
            didIReactWithThisEmoji: false
        }
        ListElement {
            emoji: "😡"
            filename: "emojiReactions/angry"
            didIReactWithThisEmoji: false
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

            Button {
                anchors.centerIn: parent
                text: "Reopen"
                onClicked: messageContextMenuView.open()
            }

            MessageContextMenuView {
                id: messageContextMenuView
                anchors.centerIn: parent
                visible: false
                closePolicy: Popup.NoAutoClose

                messageId: "Oxdeadbeef"
                defaultEmojiReactionsModel: defaultEmojiReactionsModel
                messageContentType: Constants.messageContentType.messageType
                chatType: Constants.chatType.oneToOne
                isDebugEnabled: isDebugEnabledCheckBox.checked
                hideDisabledItems: ctrlHideDisabled.checked
                amIChatAdmin: ctrlChatAdmin.checked
                canPin: true
                pinnedMessage: ctrlPinned.checked

                onPinMessage: logs.logEvent(`onPinMessage: ${messageContextMenuView.messageId}`)
                onUnpinMessage: logs.logEvent(`onUnpinMessage: ${messageContextMenuView.messageId}`)
                onPinnedMessagesLimitReached: logs.logEvent(`onPinnedMessagesLimitReached: ${messageContextMenuView.messageId}`)
                onMarkMessageAsUnread: logs.logEvent(`onMarkMessageAsUnread: ${messageContextMenuView.messageId}`)
                onToggleReaction: (emoji) => logs.logEvent("onToggleReaction", ["emoji"], [emoji])
                onDeleteMessage: logs.logEvent(`onDeleteMessage: ${messageContextMenuView.messageId}`)
                onEditClicked: logs.logEvent(`onEditClicked: ${messageContextMenuView.messageId}`)
                onShowReplyArea: (senderId) => logs.logEvent("onShowReplyArea", ["senderId"], [senderId])
                onCopyToClipboard: (text) => logs.logEvent("onCopyToClipboard", ["text"], [text])
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        controls: ColumnLayout {
            spacing: 16

            CheckBox {
                id: isDebugEnabledCheckBox
                text: "Enable Debug"
            }

            CheckBox {
                id: ctrlHideDisabled
                text: "Hide disabled items"
                checked: true
            }

            CheckBox {
                id: ctrlChatAdmin
                text: "Chat Admin"
                checked: false
            }

            CheckBox {
                id: ctrlPinned
                text: "Pinned message?"
            }
        }
    }
}

// category: Views
