import QtQuick 2.14
import QtQuick.Layouts 1.14

import shared.views 1.0

import utils 1.0

import "../stores"

Item {
    id: root

    property KeypairImportStore store

    implicitHeight: layout.implicitHeight

    SyncingEnterCode {
        id: layout

        anchors.fill: parent
        anchors.margins: 24
        spacing: 32

        firstTabName: qsTr("Scan encrypted QR code")
        secondTabName: qsTr("Enter encrypted key")
        syncQrErrorMessage: qsTr("This does not look like the correct keypair QR code")
        syncCodeErrorMessage: qsTr("This does not look like an encrypted keypair code")
        firstInstructionButtonName: Constants.keypairImportPopup.instructionsLabelForQr
        secondInstructionButtonName: Constants.keypairImportPopup.instructionsLabelForEncryptedKey
        syncCodeLabel: qsTr("Paste encrypted key")

        validateConnectionString: function(connectionString) {
            const result = root.store.validateConnectionString(connectionString)
            return result === ""
        }

        onSyncViaQrChanged: {
            root.store.syncViaQr = syncViaQr
        }

        onProceed: {
            root.store.keypairImportModule.connectionString = connectionString
            if (!syncViaQr) {
                return
            }
            root.store.submitPopup()
        }

        onDisplayInstructions: {
            root.store.currentState.doSecondaryAction()
        }
    }
}
