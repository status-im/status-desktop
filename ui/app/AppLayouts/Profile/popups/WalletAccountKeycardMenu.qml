import QtQuick 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusMenu {
    id: root

    property var keyPair

    signal runRenameKeypairFlow()
    signal runRemoveKeypairFlow()

    QtObject {
        id: d
        readonly property bool isProfileKeypair: keyPair.pairType === Constants.keycard.keyPairType.profile
    }

    StatusAction {
        text: enabled? qsTr("Show encrypted QR of keypairs on device") : ""
        enabled: !d.isProfileKeypair &&
                 !keyPair.migratedToKeycard &&
                 !keyPair.operability === Constants.keypair.operability.nonOperable
        icon.name: "qr"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            console.warn("TODO: show encrypted QR")
        }
    }

    StatusAction {
        text: keyPair.migratedToKeycard? qsTr("Stop using Keycard") : qsTr("Move keys to a Keycard")
        icon.name: keyPair.migratedToKeycard? "keycard-crossed" : "keycard"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            if (keyPair.migratedToKeycard)
                console.warn("TODO: stop using Keycard")
            else
                console.warn("TODO: move keys to a Keycard")
        }
    }

    StatusAction {
        text: enabled? qsTr("Rename keypair") : ""
        enabled: !d.isProfileKeypair
        icon.name: "edit"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            root.runRenameKeypairFlow()
        }
    }

    StatusMenuSeparator {
        visible: !d.isProfileKeypair
    }

    StatusAction {
        text: enabled? qsTr("Remove keypair and associated accounts") : ""
        enabled: !d.isProfileKeypair
        type: StatusAction.Type.Danger
        icon.name: "delete"
        icon.color: Theme.palette.dangerColor1
        onTriggered: {
            root.runRemoveKeypairFlow()
        }
    }
}
