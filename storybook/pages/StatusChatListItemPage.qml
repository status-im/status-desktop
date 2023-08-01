import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1

import Storybook 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusChatListItem {
            anchors.centerIn: parent
            name: ctrlName.text
            hasUnreadMessages: ctrlHasUnreadMessages.checked
            notificationsCount: ctrlNotificationsCount.value
            muted: ctrlMuted.checked
            onlineStatus: ctrlOnlineStatus.currentIndex
            type: ctrlType.currentIndex
            highlighted: ctrlHighlighted.checked
            highlightWhenCreated: ctrlHighlighWhenCreated.checked
            dragged: ctrlDragged.checked
            requiresPermissions: ctrlRequiresPermission.checked
            locked: ctrlLocked.checked
            onClicked: logs.logEvent("StatusChatListItem::clicked", ["mouse"], arguments)
            onUnmute: logs.logEvent("StatusChatListItem::unmute", [], arguments)
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400

        logsView.logText: logs.logText

        ColumnLayout {
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Name:" }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlName
                    text: "Example channel"
                    placeholderText: "name"
                }
            }
            CheckBox {
                id: ctrlHasUnreadMessages
                text: "Has unread messages"
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Unread msg count:" }
                ToolButton { text: "min"; onClicked: ctrlNotificationsCount.value = ctrlNotificationsCount.from }
                SpinBox {
                    Layout.fillWidth: true
                    id: ctrlNotificationsCount
                    from: 0
                    to: 1000
                }
                ToolButton { text: "max"; onClicked: ctrlNotificationsCount.value = ctrlNotificationsCount.to }
            }
            CheckBox {
                id: ctrlMuted
                text: "Muted"
            }
            RowLayout {
                Label { text: "Online status:" }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlOnlineStatus
                    model: [
                        "Inactive",
                        "Online"
                    ]
                }
            }
            RowLayout {
                Label { text: "Type:" }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlType
                    currentIndex: 6
                    model: [
                        "SCLI.Type.Unknown0", // 0
                        "SCLI.Type.OneToOneChat", // 1
                        "SCLI.Type.PublicChat", // 2
                        "SCLI.Type.GroupChat", // 3
                        "SCLI.Type.Unknown1", // 4
                        "SCLI.Type.Unknown2", // 5
                        "SCLI.Type.CommunityChat" // 6
                    ]
                }
            }
            CheckBox {
                id: ctrlHighlighted
                text: "Highlighted"
            }
            CheckBox {
                id: ctrlHighlighWhenCreated
                text: "Highlight when created"
            }
            CheckBox {
                id: ctrlDragged
                text: "Dragged"
            }
            CheckBox {
                id: ctrlRequiresPermission
                text: "Requires permission"
                enabled: ctrlType.currentIndex === StatusChatListItem.Type.CommunityChat
            }
            CheckBox {
                Layout.leftMargin: 16
                id: ctrlLocked
                text: "Locked"
                enabled: ctrlRequiresPermission.enabled && ctrlRequiresPermission.checked
            }
        }
    }
}

// category: Components
