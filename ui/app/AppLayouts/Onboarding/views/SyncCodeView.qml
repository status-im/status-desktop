import QtQuick 2.13

import shared.popups 1.0
import shared.views 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    SyncingEnterCode {
        id: layout

        anchors.centerIn: parent
        width: 400
        spacing: 24

        validateConnectionString: function(connectionString) {
            const result = root.startupStore.validateLocalPairingConnectionString(connectionString)
            return result === ""
        }

        onProceed: {
            root.startupStore.setConnectionString(connectionString)
            root.startupStore.doPrimaryAction()
        }

        onDisplayInstructions: {
            instructionsPopup.open()
        }
    }

    GetSyncCodeInstructionsPopup {
        id: instructionsPopup
    }
}
