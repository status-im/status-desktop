import QtQuick 2.14

import StatusQ.Popups.Dialog 0.1

import shared.views 1.0

StatusDialog {
    id: root

    title: qsTr("How to get a sync code on...")
    horizontalPadding: 24
    verticalPadding: 32
    footer: null

    SyncingCodeInstructions {
    }
}
