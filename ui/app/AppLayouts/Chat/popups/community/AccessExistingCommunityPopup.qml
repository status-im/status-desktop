import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import "../../../../../shared"
import "../../../../../shared/popups"
import "../../../../../shared/controls"
import "../../../../../shared/panels"
import "../../../../../shared/status"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    width: 400
    height: 400

    property string keyValidationError: ""
    
    function validate() {
        keyValidationError = ""

        if (keyInput.text.trim() === "") {
            //% "You need to enter a key"
            keyValidationError = qsTrId("you-need-to-enter-a-key")
        }

        return !keyValidationError
    }

    //% "Access existing community"
    title: qsTrId("access-existing-community")

    onClosed: {
        popup.destroy();
    }

    Item {
        anchors.fill: parent

        StyledTextArea {
            id: keyInput
            //% "Community private key"
            label: qsTrId("community-key")
            placeholderText: "0x0..."
            customHeight: 110
        }

        StyledText {
            id: infoText1
            //% "Entering a community key will grant you the ownership of that community. Please be responsible with it and don’t share the key with people you don’t trust."
            text: qsTrId("entering-a-community-key-will-grant-you-the-ownership-of-that-community--please-be-responsible-with-it-and-don-t-share-the-key-with-people-you-don-t-trust-")
            anchors.top: keyInput.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            font.pixelSize: 13
            color: Style.current.secondaryText
        }
    }

    footer: StatusButton {
        id: btnBack
        //% "Import"
        text: qsTrId("import")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                return
            }

            let communityKey = keyInput.text.trim()
            if (!communityKey.startsWith("0x")) {
                communityKey = "0x" + communityKey
            }

            const error = chatsModel.communities.importCommunity(communityKey, Utils.uuid())

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
