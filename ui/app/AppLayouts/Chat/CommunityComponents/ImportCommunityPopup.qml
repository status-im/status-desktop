import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string keyValidationError: ""

    id: popup
    height: 300

    onOpened: {
        keyInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function validate() {
        keyValidationError = ""

        if (keyInput.text === "") {
            keyValidationError = qsTr("You need to enter a key")
        }

        return !keyValidationError
    }

    title: qsTr("Import a community")


    Input {
        id: keyInput
        label: qsTr("Community key")
        placeholderText: qsTr("0x...")
        validationError: popup.keyValidationError
        pasteFromClipboard: true
    }

    footer: StatusButton {
        text: qsTr("Import")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                return
            }

            let communityKey = keyInput.text
            if (!communityKey.startsWith("0x")) {
                communityKey = "0x" + communityKey
            }

            const error = chatsModel.importCommunity(communityKey)

            if (error) {
                creatingError.text = error
                return creatingError.open()
            }

            popup.close()
        }

        MessageDialog {
            id: creatingError
            title: qsTr("Error importing the community")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}

