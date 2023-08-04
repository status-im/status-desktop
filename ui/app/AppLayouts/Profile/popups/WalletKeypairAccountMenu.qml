import QtQuick 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusMenu {
    id: root

    property var keyPair

    signal runImportViaSeedPhraseFlow()
    signal runImportViaPrivateKeyFlow()
    signal runRenameKeypairFlow()
    signal runRemoveKeypairFlow()

    StatusAction {
        text: enabled? qsTr("Show encrypted QR of keypairs on device") : ""
        enabled: !!root.keyPair &&
                 root.keyPair.pairType !== Constants.keypair.type.profile &&
                 !root.keyPair.migratedToKeycard &&
                 root.keyPair.operability === Constants.keypair.operability.fullyOperable
        icon.name: "qr"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            console.warn("TODO: show encrypted QR")
        }
    }

    StatusAction {
        text: enabled? root.keyPair.migratedToKeycard? qsTr("Stop using Keycard") : qsTr("Move keys to a Keycard") : ""
        enabled: !!root.keyPair &&
                 root.keyPair.operability !== Constants.keypair.operability.nonOperable
        icon.name: !!root.keyPair && root.keyPair.migratedToKeycard? "keycard-crossed" : "keycard"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            if (root.keyPair.migratedToKeycard)
                console.warn("TODO: stop using Keycard")
            else
                console.warn("TODO: move keys to a Keycard")
        }
    }

    StatusAction {
        text: enabled? qsTr("Import keypair from device via encrypted QR") : ""
        enabled: !!root.keyPair &&
                 root.keyPair.pairType !== Constants.keypair.type.profile &&
                 root.keyPair.operability === Constants.keypair.operability.nonOperable &&
                 root.keyPair.syncedFrom !== Constants.keypair.syncedFrom.backup
        icon.name: "qr-scan"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            console.warn("TODO: run import via encrypted QR")
        }
    }

    StatusAction {
        text: enabled? root.keyPair.pairType === Constants.keypair.type.privateKeyImport? qsTr("Import via entering private key") : qsTr("Import via entering seed phrase") : ""
        enabled: !!root.keyPair &&
                 root.keyPair.operability === Constants.keypair.operability.nonOperable &&
                 (root.keyPair.pairType === Constants.keypair.type.seedImport ||
                  root.keyPair.pairType === Constants.keypair.type.privateKeyImport)
        icon.name: enabled? root.keyPair.pairType === Constants.keypair.type.privateKeyImport? "objects" : "key_pair_seed_phrase" : ""
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            if (root.keyPair.pairType === Constants.keypair.type.privateKeyImport)
                root.runImportViaPrivateKeyFlow()
            else
                root.runImportViaSeedPhraseFlow()
        }
    }

    StatusAction {
        text: enabled? qsTr("Rename keypair") : ""
        enabled: !!root.keyPair &&
                 root.keyPair.pairType !== Constants.keypair.type.profile
        icon.name: "edit"
        icon.color: Theme.palette.primaryColor1
        onTriggered: {
            root.runRenameKeypairFlow()
        }
    }

    StatusMenuSeparator {
        visible: !!root.keyPair &&
                 root.keyPair.pairType !== Constants.keypair.type.profile
    }

    StatusAction {
        text: enabled? qsTr("Remove keypair and associated accounts") : ""
        enabled: !!root.keyPair &&
                 root.keyPair.pairType !== Constants.keypair.type.profile
        type: StatusAction.Type.Danger
        icon.name: "delete"
        icon.color: Theme.palette.dangerColor1
        onTriggered: {
            root.runRemoveKeypairFlow()
        }
    }
}
