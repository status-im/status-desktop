import QtQuick 2.13

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.status 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.popups.addaccount 1.0

import "../../stores"
import "../../controls"
import "../../popups"

Column {
    id: root

    property WalletStore walletStore
    property var emojiPopup

    signal goToNetworksView()
    signal goToAccountOrderView()
    signal goToAccountView(var account, var keypair)
    signal goToDappPermissionsView()
    signal runRenameKeypairFlow(var model)
    signal runRemoveKeypairFlow(var model)
    signal runMoveKeypairToKeycardFlow(var model)
    signal runStopUsingKeycardFlow(var model)
    signal goToManageTokensView()

    spacing: 8

    Connections {
        target: walletSection

        function onDisplayAddAccountPopup() {
            addAccount.active = true
        }
        function onDestroyAddAccountPopup() {
            addAccount.active = false
        }
    }

    QtObject {
        id: d

        readonly property int unimportedNonProfileKeypairs: {
            let total = 0
            for (var i = 0; i < keypairsRepeater.count; i++) {
                let item = keypairsRepeater.itemAt(i)
                if (item == undefined || item == null) {
                    continue
                }
                let kp = item.keyPair
                if (kp.migratedToKeycard ||
                        kp.pairType === Constants.keypair.type.profile ||
                        kp.pairType === Constants.keypair.type.watchOnly ||
                        kp.operability === Constants.keypair.operability.fullyOperable ||
                        kp.operability === Constants.keypair.operability.partiallyOperable) {
                    continue
                }
                total++
            }
            return total
        }

        readonly property int allNonProfileKeypairsMigratedToAKeycard: {
            for (var i = 0; i < keypairsRepeater.count; i++) {
                let item = keypairsRepeater.itemAt(i)
                if (item == undefined || item == null) {
                    continue
                }
                let kp = item.keyPair
                if (!kp.migratedToKeycard &&
                        kp.pairType !== Constants.keypair.type.profile &&
                        kp.pairType !== Constants.keypair.type.watchOnly &&
                        kp.operability !== Constants.keypair.operability.nonOperable) {
                    return false
                }
            }
            return true
        }

    }

    component Spacer: Item {
        height: 8
    }


    Loader {
        id: addAccount
        active: false
        asynchronous: true

        sourceComponent: AddAccountPopup {
            store.emojiPopup: root.emojiPopup
            store.addAccountModule: walletSection.addAccountModule
        }

        onLoaded: {
            addAccount.item.open()
        }
    }

    Separator {}

    StatusListItem {
        objectName: "networksItem"
        title: qsTr("Networks")
        height: 64
        width: parent.width
        onClicked: goToNetworksView()
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
    }

    Separator {}

    StatusListItem {
        objectName: "accountOrderItem"
        title: qsTr("Account order")
        height: 64
        width: parent.width
        onClicked: goToAccountOrderView()
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
    }

    Separator {}

    StatusListItem {
        title: qsTr("Manage Tokens")
        height: 64
        width: parent.width
        onClicked: goToManageTokensView()
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
    }

    Separator {}

    Spacer {
        visible: root.walletStore.walletModule.hasPairedDevices
        width: parent.width
    }

    Rectangle {
        visible: root.walletStore.walletModule.hasPairedDevices &&
                 !d.allNonProfileKeypairsMigratedToAKeycard
        height: 102
        width: parent.width
        color: Theme.palette.transparent
        radius: 8
        border.width: 1
        border.color: Theme.palette.baseColor5

        Column {
            anchors.fill: parent
            padding: 16
            spacing: 8

            StatusBaseText {
                text: qsTr("Import keypairs from this device to your other synced devices")
                font.pixelSize: 15
            }

            StatusButton {
                text: qsTr("Show encrypted QR of keypairs on device")
                icon.name: "qr"
                onClicked: {
                    root.walletStore.runKeypairImportPopup("", Constants.keypairImportPopup.mode.exportKeypairQr)
                }
            }
        }
    }

    Rectangle {
        visible: root.walletStore.walletModule.hasPairedDevices &&
                 d.unimportedNonProfileKeypairs > 0
        height: 102
        width: parent.width
        color: Theme.palette.transparent
        radius: 8
        border.width: 1
        border.color: Theme.palette.baseColor5

        Column {
            anchors.fill: parent
            padding: 16
            spacing: 8

            StatusBaseText {
                text: qsTr("%n keypair(s) require import to use on this device", "", d.unimportedNonProfileKeypairs)
                font.pixelSize: 15
            }

            StatusButton {
                text: qsTr("Import missing keypairs")
                type: StatusBaseButton.Type.Warning
                icon.name: "download"
                onClicked: {
                    root.walletStore.runKeypairImportPopup("", Constants.keypairImportPopup.mode.selectKeypair)
                }
            }
        }
    }

    Spacer {
        width: parent.width
    }

    Column {
        width: parent.width
        spacing: 24
        Repeater {
            id: keypairsRepeater
            objectName: "generatedAccounts"
            model: walletStore.originModel
            delegate: WalletKeyPairDelegate {
                width: parent.width
                keyPair: model.keyPair
                hasPairedDevices: root.walletStore.walletModule.hasPairedDevices
                getNetworkShortNames: walletStore.getNetworkShortNames
                userProfilePublicKey: walletStore.userProfilePublicKey
                onGoToAccountView: root.goToAccountView(account, keyPair)
                onRunRenameKeypairFlow: root.runRenameKeypairFlow(model)
                onRunRemoveKeypairFlow: root.runRemoveKeypairFlow(model)
                onRunImportViaSeedPhraseFlow: {
                    root.walletStore.runKeypairImportPopup(model.keyPair.keyUid, Constants.keypairImportPopup.mode.importViaSeedPhrase)
                }
                onRunImportViaPrivateKeyFlow: {
                    root.walletStore.runKeypairImportPopup(model.keyPair.keyUid, Constants.keypairImportPopup.mode.importViaPrivateKey)
                }
                onRunExportQrFlow: {
                    root.walletStore.runKeypairImportPopup(model.keyPair.keyUid, Constants.keypairImportPopup.mode.exportKeypairQr)
                }
                onRunImportViaQrFlow: {
                    root.walletStore.runKeypairImportPopup(model.keyPair.keyUid, Constants.keypairImportPopup.mode.importViaQr)
                }
                onRunMoveKeypairToKeycardFlow: {
                    root.runMoveKeypairToKeycardFlow(model)
                }
                onRunStopUsingKeycardFlow: {
                    root.runStopUsingKeycardFlow(model)
                }
            }
        }
    }
}
