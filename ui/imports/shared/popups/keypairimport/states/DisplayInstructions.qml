import QtQuick
import QtQuick.Layouts

import shared.views

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
