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
            //% "You need to enter a key"
            keyValidationError = qsTrId("you-need-to-enter-a-key")
        }

        return !keyValidationError
    }

    //% "Import a community"
    title: qsTrId("import-community")


    Input {
        id: keyInput
        //% "Community key"
        label: qsTrId("community-key")
        //% "0x..."
        placeholderText: qsTrId("0x---")
        validationError: popup.keyValidationError
        pasteFromClipboard: true
    }

    footer: StatusButton {
        //% "Import"
        text: qsTrId("import")
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
            //% "Error importing the community"
            title: qsTrId("error-importing-the-community")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}

