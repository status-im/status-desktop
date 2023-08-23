import QtQuick 2.14
import QtQuick.Layouts 1.14

import shared.views 1.0

import "../stores"

Item {
    id: root

    property KeypairImportStore store

    implicitHeight: layout.implicitHeight

    SyncingCodeInstructions {
        id: layout

        anchors.fill: parent
        anchors.margins: 24

        purpose: SyncingCodeInstructions.Purpose.KeypairSync
        type: root.store.syncViaQr?
                  SyncingCodeInstructions.Type.QRCode :
                  SyncingCodeInstructions.Type.EncryptedKey
    }
}
