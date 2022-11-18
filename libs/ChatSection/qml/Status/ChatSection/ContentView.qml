import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.ChatSection

Item {
    id: root

    required property var selectedChat
    required property var chatSectionController

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Label {
            text: "selected chat: %1".arg(root.selectedChat.name)
        }

        Label {
            text: "chat id: %1".arg(root.selectedChat.id)
        }

        Label {
            text: "description: %1".arg(root.selectedChat.description)
        }

        Label {
            text: "chat color"
            color: root.selectedChat.color
        }

        Label {
            text: "is active: %1".arg(root.selectedChat.active)
        }

        Label {
            text: "is muted: %1".arg(root.selectedChat.muted)
        }

        Row {
            TextField {
                id: chatInput
                width: root.width / 2
            }

            Button {
                id: sendMessageButton
                text: "Send"
                onClicked: chatSectionController.sendMessage(chatInput.text)
            }
        }
    }
}
