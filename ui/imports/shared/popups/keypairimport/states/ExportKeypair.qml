import QtQuick 2.14
import QtQuick.Layouts 1.14

import shared.views 1.0

import "../stores"

Item {
    id: root

    property KeypairImportStore store

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16

        SyncingDisplayCode {
            Layout.fillWidth: true
            Layout.margins: 16
            visible: !!root.store.keypairImportModule.connectionString

            connectionStringLabel: qsTr("Encrypted keypairs code")
            connectionString: root.store.keypairImportModule.connectionString
            importCodeInstructions: qsTr("On your other device, navigate to the Wallet screen<br>and select ‘Import missing keypairs’. For security reasons,<br>do not save this code anywhere.")
            codeExpiredMessage: qsTr("Your QR and encrypted keypairs code have expired.")

            onConnectionStringChanged: {
                if (!!connectionString) {
                    start()
                }
            }

            onRequestConnectionString: {
                root.store.generateConnectionStringForExporting()
            }
        }

        SyncingErrorMessage {
            Layout.fillWidth: true
            visible: !!root.store.keypairImportModule.connectionStringError
            primaryText: qsTr("Failed to generate sync code")
            secondaryText: qsTr("Failed to start pairing server")
            errorDetails: root.store.keypairImportModule.connectionStringError
        }
    }
}
