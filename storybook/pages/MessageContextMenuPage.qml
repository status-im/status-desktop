import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.views.chat 1.0
import shared.status 1.0

SplitView {

    QtObject {
        id: d
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                RowLayout {
                    Button {
                        text: "Message context menu"
                        onClicked: {
                            menu1.createObject(this).popup()
                        }
                    }
                    Button {
                        text: "Message context menu (hide disabled items)"
                        onClicked: {
                            menu2.createObject(this).popup()
                        }
                    }
                }
            }

            Component {
                id: menu1
                MessageContextMenuView {
                    id: messageContextMenuView
                    anchors.centerIn: parent
                    hideDisabledItems: false
                    isDebugEnabled: isDebugEnabledCheckBox.checked
                    onClosed: {
                        destroy()
                    }
                    onPinMessage: () => {
                        logs.logEvent("Pin message:", messageContextMenuView.messageId)
                    }
                    onUnpinMessage: () => {
                        logs.logEvent("Unpin message:", messageContextMenuView.messageId)
                    }
                    onPinnedMessagesLimitReached: () => {
                        logs.logEvent("Pinned messages limit reached:", messageContextMenuView.messageId)
                    }
                    onMarkMessageAsUnread: () => {
                        logs.logEvent("Mark message as unread:", messageContextMenuView.messageId)
                    }
                    onToggleReaction: (emojiId) => {
                        logs.logEvent("Toggle reaction:", messageContextMenuView.messageId, emojiId)
                    }
                    onDeleteMessage: () => {
                        logs.logEvent("Delete message:", messageContextMenuView.messageId)
                    }
                    onEditClicked: () => {
                        logs.logEvent("Edit message:", messageContextMenuView.messageId)
                    }
                    onShowReplyArea: (senderId) => {
                        logs.logEvent("Show reply area:", messageContextMenuView.messageId, senderId)
                    }
                    onCopyToClipboard: (text) => {
                        logs.logEvent("Copy to clipboard:", text)
                    }
                }
            }

            Component {
                id: menu2
                MessageContextMenuView {
                    id: messageContextMenuView
                    anchors.centerIn: parent
                    hideDisabledItems: true
                    isDebugEnabled: isDebugEnabledCheckBox.checked
                    onClosed: {
                        destroy()
                    }
                    onPinMessage: () => {
                        logs.logEvent("Pin message:", messageContextMenuView.messageId)
                    }
                    onUnpinMessage: () => {
                        logs.logEvent("Unpin message:", messageContextMenuView.messageId)
                    }
                    onPinnedMessagesLimitReached: () => {
                        logs.logEvent("Pinned messages limit reached:", messageContextMenuView.messageId)
                    }
                    onMarkMessageAsUnread: () => {
                        logs.logEvent("Mark message as unread:", messageContextMenuView.messageId)
                    }
                    onToggleReaction: (emojiId) => {
                        logs.logEvent("Toggle reaction:", messageContextMenuView.messageId, emojiId)
                    }
                    onDeleteMessage: () => {
                        logs.logEvent("Delete message:", messageContextMenuView.messageId)
                    }
                    onEditClicked: () => {
                        logs.logEvent("Edit message:", messageContextMenuView.messageId)
                    }
                    onShowReplyArea: (senderId) => {
                        logs.logEvent("Show reply area:", messageContextMenuView.messageId, senderId)
                    }
                    onCopyToClipboard: (text) => {
                        logs.logEvent("Copy to clipboard:", text)
                    }
                }
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
                checked: false
            }
        }
    }

}

// category: Views
