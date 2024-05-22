import QtQuick 2.15

import AppLayouts.Chat.stores 1.0

ConfirmationDialog {
    id: root

    property MessageStore messageStore
    property string messageId

    headerSettings.title: qsTr("Confirm deleting this message")
    confirmationText: qsTr("Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well.")
    height: 260
    checkbox.visible: true
    confirmButtonObjectName: "chatButtonsPanelConfirmDeleteMessageButton"

    executeConfirm: () => {
        if (checkbox.checked) {
            localAccountSensitiveSettings.showDeleteMessageWarning = false
        }
        close()
        messageStore.deleteMessage(messageId)
    }

    onClosed: {
        destroy()
    }
}
