import QtQuick

import StatusQ.Popups.Dialog

import shared.views

StatusDialog {
    id: root

    title: qsTr("How to get a pairing code on...")
    horizontalPadding: 24
    verticalPadding: 32
    footer: null

    SyncingCodeInstructions {
    }
}
