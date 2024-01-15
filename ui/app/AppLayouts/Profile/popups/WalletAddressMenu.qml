import QtQuick 2.15

import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Wallet.popups 1.0

////////////////////////////////////////////////////////////////////////////////
// NOTE:
//
// The address should be marked as shown (calling `mainModule.addressWasShown(address)`) if the user interacts with any
// of the current actions in the menu.
//
// That call is not added now, just because the only place where this menu is used is in the account view and the address
// will be already marked as shown when the user opens the account view.
//
// This note here is just to remember that if this menu is used in other places, the address should be marked as shown.
////////////////////////////////////////////////////////////////////////////////

StatusMenu {
    id: root

    property var selectedAccount: ({
                                       address: "",
                                       name: "",
                                       emoji: "",
                                       colorId: "",
                                       preferredSharingChainIds: ""
                                   })
    property bool areTestNetworksEnabled: false
    property bool isSepoliaEnabled: false
    property string preferredSharingNetworks
    property var preferredSharingNetworksArray

    signal copyToClipboard(string address)

    function openMenu(delegate) {
        const x = delegate.width - 40
        const y = delegate.height / 2 + 20
        root.popup(delegate, x, y)
    }

    StatusAction {
        id: showOnEtherscanAction
        text: qsTr("View address on Etherscan")
        icon.name: "link"
        onTriggered: {
            let link = Constants.networkExplorerLinks.etherscan
            if (areTestNetworksEnabled) {
                if (root.isSepoliaEnabled) {
                    link = Constants.networkExplorerLinks.sepoliaEtherscan
                } else {
                    link = Constants.networkExplorerLinks.goerliEtherscan
                }
            }
            
            Global.openLink("%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.selectedAccount.address?? ""))
        }
    }
    StatusAction {
        id: showOnArbiscanAction
        text: qsTr("View address on Arbiscan")
        icon.name: "link"
        onTriggered: {
            const link = areTestNetworksEnabled ? Constants.networkExplorerLinks.goerliArbiscan : Constants.networkExplorerLinks.arbiscan
            Global.openLink("%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.selectedAccount.address?? ""))
        }
    }
    StatusAction {
        id: showOnOptimismAction
        text: qsTr("View address on Optimism Explorer")
        icon.name: "link"
        onTriggered: {
            const link = areTestNetworksEnabled ? Constants.networkExplorerLinks.goerliOptimistic : Constants.networkExplorerLinks.optimistic
            Global.openLink("%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.selectedAccount.address?? ""))
        }
    }
    StatusSuccessAction {
        id: copyAddressAction
        successText:  qsTr("Address copied")
        text: qsTr("Copy address")
        icon.name: "copy"
        onTriggered: root.copyToClipboard(root.selectedAccount.address?? "")
    }
    StatusAction {
        id: showQrAction
        text: qsTr("Show address QR")
        icon.name: "qr"
        onTriggered: Global.openShowQRPopup({
                                                showSingleAccount: true,
                                                switchingAccounsEnabled: false,
                                                changingPreferredChainsEnabled: false,
                                                hasFloatingButtons: false,
                                                name: root.selectedAccount.name?? "",
                                                address: root.selectedAccount.address?? "",
                                                emoji: root.selectedAccount.emoji?? "",
                                                colorId: root.selectedAccount.colorId?? "",
                                                preferredSharingChainIds: root.selectedAccount.preferredSharingChainIds?? ""
                                            })
    }
}
