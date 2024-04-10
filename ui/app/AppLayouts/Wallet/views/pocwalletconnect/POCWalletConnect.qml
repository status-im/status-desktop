/////////////////////////////////////////////////////
// WalletConnect POC - to remove this file
/////////////////////////////////////////////////////

import QtQuick 2.15

import AppLayouts.Wallet.stores 1.0 as WalletStores

import shared.popups.walletconnect 1.0

Item {
    id: root

    required property var controller

    property alias modal: modal
    property alias sdk: sdk
    property alias url: sdk.url

    POCWalletConnectModal {
        id: modal

        controller: root.controller
        sdk: sdk
    }

    WalletConnectSDK {
        id: sdk

        projectId: controller.projectId

        active: WalletStores.RootStore.walletSectionInst.walletReady && (controller.hasActivePairings || modal.opened)

        onSessionRequestEvent: (details) => {
            modal.openWithSessionRequestEvent(details)
        }
    }

    Connections {
        target: root.controller
        function onRequestOpenWalletConnectPopup(uri) {
            modal.openWithUri(uri)
        }
    }
}
