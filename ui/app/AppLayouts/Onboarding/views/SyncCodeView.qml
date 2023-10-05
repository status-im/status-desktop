import QtQuick 2.13

import shared.popups 1.0
import shared.views 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Timer {
        id: nextStateDelay

        property string connectionString

        interval: 1000
        repeat: false
        onTriggered: {
            root.startupStore.setConnectionString(nextStateDelay.connectionString)
            root.startupStore.doPrimaryAction()
        }
    }

    SyncingEnterCode {
        id: layout

        objectName: "syncingEnterCode"

        anchors.centerIn: parent
        width: 400
        spacing: 24

        validateConnectionString: function(connectionString) {
            const result = root.startupStore.validateLocalPairingConnectionString(connectionString)
            return result === ""
        }

        onProceed: {
            nextStateDelay.connectionString = connectionString
            nextStateDelay.start()
        }

        onDisplayInstructions: {
            instructionsPopup.open()
        }
    }

    GetSyncCodeInstructionsPopup {
        id: instructionsPopup
    }
}
