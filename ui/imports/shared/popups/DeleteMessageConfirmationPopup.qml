import QtQuick 2.15

ConfirmationDialog {
    id: root

    property var messageStore
    property string messageId

    header.title: qsTr("Confirm deleting this message")
    confirmationText: qsTr("Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well.")
    height: 260
    checkbox.visible: true

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
