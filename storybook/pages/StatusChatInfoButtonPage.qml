import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme

import Models
import Storybook

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusChatInfoButton {
            anchors.centerIn: parent

            title: ctrlTitle.text
            subTitle: ctrlSubTitle.text
            type: ctrlType.currentValue

            asset {
                color: Theme.palette.primaryColor1
                name: ctrlIcon.checked ? ModelsData.icons.cryptPunks : ""
                emoji: ctrlEmoji.checked ? "💩" : ""
            }

            muted: ctrlMuted.checked
            onUnmute: {
                logs.logEvent("onUnmute")
                ctrlMuted.checked = false
            }

            pinnedMessagesCount: ctrlPinnedMessagesCount.value
            onPinnedMessagesCountClicked: logs.logEvent("onPinnedMessagesCountClicked")

            requiresPermissions: ctrlRequiresPermissions.checked
            locked: ctrlLocked.checked

            onLinkActivated: logs.logEvent("onLinkActivated", ["link"], arguments)
            onClicked: logs.logEvent("onClicked")
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 300
        SplitView.preferredHeight: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            TextField {
                Layout.preferredWidth: 200
                id: ctrlTitle
                placeholderText: "Title"
                text: "Channel title"
            }

            TextField {
                Layout.preferredWidth: 200
                id: ctrlSubTitle
                placeholderText: "Subtitle"
                text: "This is a subtitle with a clickable <a href='https://status.app'>link</a>"
            }

            RowLayout {
                Label { text: "Type:" }
                ComboBox {
                    Layout.preferredWidth: 200
                    id: ctrlType
                    textRole: "text"
                    valueRole: "value"
                    displayText: currentText || ""
                    currentIndex: 0
                    model: [
                        { value: StatusChatInfoButton.Type.OneToOneChat, text: "OneToOneChat" },
                        { value: StatusChatInfoButton.Type.PublicChat, text: "PublicChat" },
                        { value: StatusChatInfoButton.Type.GroupChat, text: "GroupChat" },
                        { value: StatusChatInfoButton.Type.CommunityChat, text: "CommunityChat" },
                    ]
                }
                Switch {
                    id: ctrlRequiresPermissions
                    text: "Requires permissions"
                    enabled: ctrlType.currentValue === StatusChatInfoButton.Type.CommunityChat
                }
                Switch {
                    id: ctrlLocked
                    text: "Locked"
                    enabled: ctrlType.currentValue === StatusChatInfoButton.Type.CommunityChat
                }
            }

            RowLayout {
                Label { text: "Image" }
                RadioButton {
                    id: ctrlIcon
                    text: "Icon"
                    checked: true
                }
                RadioButton {
                    id: ctrlEmoji
                    text: "Emoji"
                }
                RadioButton {
                    id: ctrlNoImage
                    text: "None"
                }
            }

            RowLayout {
                Label { text: "Pinned messages:" }
                SpinBox {
                    id: ctrlPinnedMessagesCount
                    from: 0
                    to: 100
                }
            }
            Switch {
                id: ctrlMuted
                text: "Muted"
            }
        }
    }
}

// category: Controls
// status: good
