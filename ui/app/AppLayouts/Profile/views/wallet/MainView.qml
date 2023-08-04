import QtQuick 2.13
import SortFilterProxyModel 0.2

import utils 1.0
import shared.status 1.0
import shared.panels 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

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

    Spacer {
        visible: root.walletStore.walletModule.hasPairedDevices
        width: parent.width
    }

    Rectangle {
        visible: root.walletStore.walletModule.hasPairedDevices
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
                    console.warn("TODO: run generate qr code flow...")
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
            objectName: "generatedAccounts"
            model: walletStore.originModel
            delegate: WalletKeyPairDelegate {
                width: parent.width
                keyPair: model.keyPair
                getNetworkShortNames: walletStore.getNetworkShortNames
                userProfilePublicKey: walletStore.userProfilePublicKey
                includeWatchOnlyAccount: walletStore.includeWatchOnlyAccount
                onGoToAccountView: root.goToAccountView(account, keyPair)
                onToggleIncludeWatchOnlyAccount: walletStore.toggleIncludeWatchOnlyAccount()
                onRunRenameKeypairFlow: root.runRenameKeypairFlow(model)
                onRunRemoveKeypairFlow: root.runRemoveKeypairFlow(model)
                onRunImportViaSeedPhraseFlow: {
                    root.walletStore.runKeypairImportPopup(model.keyPair.keyUid, Constants.keypairImportPopup.importOption.seedPhrase)
                }
                onRunImportViaPrivateKeyFlow: {
                    root.walletStore.runKeypairImportPopup(model.keyPair.keyUid, Constants.keypairImportPopup.importOption.privateKey)
                }
            }
        }
    }
}
