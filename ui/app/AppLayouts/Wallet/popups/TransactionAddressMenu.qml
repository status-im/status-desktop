import QtQuick 2.15
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import utils 1.0
import shared.stores 1.0

import "../stores" as WalletStores

import AppLayouts.Profile.stores 1.0 as ProfileStores

////////////////////////////////////////////////////////////////////////////////
// NOTE:
//
// The address should be marked as shown (calling `mainModule.addressWasShown(address)`) if the user interacts with
// actions in the menu that reveals the address.
//
// That call is not added now, just because the only place where this menu is used is in the transaction details view
// and the address will be already marked as shown when the user opens the transaction details view.
//
// This note here is just to remember that if this menu is used in other places, the address should be marked as shown.
////////////////////////////////////////////////////////////////////////////////

StatusMenu {
    id: root

    property ProfileStores.ContactsStore contactsStore
    property NetworkConnectionStore networkConnectionStore
    property bool areTestNetworksEnabled: false
    property bool isGoerliEnabled: false

    signal openSendModal(address: string)

    enum AddressType {
        Address,
        Sender,
        Receiver,
        Tx,
        InputData,
        Contract
    }

    QtObject {
        id: d

        property string selectedAddress: ""
        property string cleanSelectedAddress: d.selectedAddress.split(":").pop()

        property string addressName: ""
        property string addressEns: ""
        property string colorId: ""

        property string contractName: ""

        property int addressType: TransactionAddressMenu.AddressType.Address

        readonly property QtObject exp: Constants.networkExplorerLinks
        readonly property QtObject chains: Constants.networkShortChainNames
        readonly property bool isAddress: d.addressType !== TransactionAddressMenu.Tx

        function getViewText(target) {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Contract:
                if (d.contractName.length > 0)
                    return qsTr("View %1 contract address on %2").arg(d.contractName).arg(target)
                return qsTr("View contract address on %1").arg(target)
            case TransactionAddressMenu.AddressType.InputData:
                return qsTr("View input data on %1").arg(target)
            case TransactionAddressMenu.AddressType.Tx:
                return qsTr("View transaction on %1").arg(target)
            case TransactionAddressMenu.AddressType.Sender:
                return qsTr("View sender address on %1").arg(target)
            case TransactionAddressMenu.AddressType.Receiver:
                return qsTr("View receiver address on %1").arg(target)
            default:
                return qsTr("View address on %1").arg(target)
            }
        }

        function refreshShowOnActionsVisiblity(shortChainNameList) {
            for (let i = 0 ; i < shortChainNameList.length ; i++) {
                switch(shortChainNameList[i].toLowerCase()) {
                case d.chains.arbitrum:
                    showOnArbiscanAction.enabled = true
                    break
                case d.chains.optimism:
                    showOnOptimismAction.enabled = true
                    break
                default:
                    showOnEtherscanAction.enabled = true
                    break
                }
            }
        }

        function openMenu(delegate) {
            const x = delegate.width - 40
            const y = delegate.height / 2 + 20
            root.popup(delegate, x, y)
        }

        readonly property TextMetrics contentMetrics: TextMetrics {
            id: contentMetrics
            font.pixelSize: root.fontSettings.pixelSize
            font.family: Theme.palette.baseFont.name
            text: {
                // Getting longest possible text
                if (showOnEtherscanAction.enabled) {
                    return showOnEtherscanAction.text
                } else if (showOnArbiscanAction.enabled) {
                    return showOnArbiscanAction.text
                }
                return showOnOptimismAction.text
            }
        }
    }

    function openSenderMenu(delegate, address, chainShortNameList = []) {
        d.addressType = TransactionAddressMenu.AddressType.Sender
        openEthAddressMenu(delegate, address, chainShortNameList)
    }

    function openReceiverMenu(delegate, address, chainShortNameList = []) {
        d.addressType = TransactionAddressMenu.AddressType.Receiver
        openEthAddressMenu(delegate, address, chainShortNameList)
    }

    function openEthAddressMenu(delegate, address, chainShortNameList = []) {
        d.selectedAddress = address

        address = address.toLowerCase()
        const contactPubKey = "" // TODO retrive contact public key or contact data directly from address
        let contactData = Utils.getContactDetailsAsJson(contactPubKey)
        let isWalletAccount = false
        const isContact = contactData.isContact
        if (isContact) {
            d.addressName = contactData.name
        } else {
            // Revisit here after this issue (resolving source for preferred chains...):
            // https://github.com/status-im/status-desktop/issues/13109
            d.addressName = WalletStores.RootStore.getNameForWalletAddress(address)
            isWalletAccount = d.addressName.length > 0
            if (!isWalletAccount) {
                let savedAddress = WalletStores.RootStore.getSavedAddress(address)
                d.addressName = savedAddress.name
                d.addressEns = savedAddress.ens
                d.colorId = savedAddress.colorId
            }
        }

        showOnEtherscanAction.enabled = true
        showOnArbiscanAction.enabled = address.includes(d.chains.arbitrum + ":")
        showOnOptimismAction.enabled = address.includes(d.chains.optimism + ":")
        d.refreshShowOnActionsVisiblity(chainShortNameList)
        saveAddressAction.enabled = d.addressName.length === 0
        editAddressAction.enabled = !isWalletAccount && !isContact && d.addressName.length > 0

        if (root.networkConnectionStore.sendBuyBridgeEnabled)
            sendToAddressAction.enabled = true

        showQrAction.enabled = true

        d.openMenu(delegate)
    }

    function openTxMenu(delegate, address, chainShortNameList=[]) {
        d.addressType = TransactionAddressMenu.AddressType.Tx
        d.selectedAddress = address
        d.refreshShowOnActionsVisiblity(chainShortNameList)
        d.openMenu(delegate)
    }

    function openContractMenu(delegate, address, chainShortNameList=[], name="") {
        d.addressType = TransactionAddressMenu.AddressType.Contract
        d.contractName = name
        d.selectedAddress = address
        d.refreshShowOnActionsVisiblity(chainShortNameList)
        d.openMenu(delegate)
    }

    function openInputDataMenu(delegate, address) {
        d.addressType = TransactionAddressMenu.AddressType.InputData
        d.selectedAddress = address
        d.openMenu(delegate)
    }

    onClosed: {
        d.addressType = TransactionAddressMenu.AddressType.Address
        d.contractName = ""

        showOnEtherscanAction.enabled = false
        showOnArbiscanAction.enabled = false
        showOnOptimismAction.enabled = false
        showQrAction.enabled = false
        saveAddressAction.enabled = false
        editAddressAction.enabled = false
        sendToAddressAction.enabled = false
    }

    // Additional offset for menu icon
    contentWidth: contentMetrics.width + 50
    hideDisabledItems: true

    StatusAction {
        id: showOnEtherscanAction
        enabled: false
        text: d.getViewText(qsTr("Etherscan"))
        icon.name: "link"
        onTriggered: {
            let url = Utils.getEtherscanUrl(d.chains.mainnet, root.areTestNetworksEnabled, !root.isGoerliEnabled,
                                            d.cleanSelectedAddress, d.isAddress)
            Global.openLink(url)
        }
    }
    StatusAction {
        id: showOnArbiscanAction
        enabled: false
        text: d.getViewText(qsTr("Arbiscan"))
        icon.name: "link"
        onTriggered: {
            let url = Utils.getEtherscanUrl(d.chains.arbitrum, root.areTestNetworksEnabled, !root.isGoerliEnabled,
                                            d.cleanSelectedAddress, d.isAddress)
            Global.openLink(url)
        }
    }
    StatusAction {
        id: showOnOptimismAction
        enabled: false
        text: d.getViewText(qsTr("Optimism Explorer"))
        icon.name: "link"
        onTriggered: {
            let url = Utils.getEtherscanUrl(d.chains.optimism, root.areTestNetworksEnabled, !root.isGoerliEnabled,
                                            d.cleanSelectedAddress, d.isAddress)
            Global.openLink(url)
        }
    }
    StatusSuccessAction {
        id: copyAddressAction
        successText: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Contract:
                return qsTr("Contract address copied")
            case TransactionAddressMenu.AddressType.InputData:
                return qsTr("Input data copied")
            case TransactionAddressMenu.AddressType.Tx:
                return qsTr("Tx hash copied")
            case TransactionAddressMenu.AddressType.Sender:
                return qsTr("Sender address copied")
            case TransactionAddressMenu.AddressType.Receiver:
                return qsTr("Receiver address copied")
            default:
                return qsTr("Address copied")
            }
        }
        text: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Contract:
                return qsTr("Copy contract address")
            case TransactionAddressMenu.AddressType.InputData:
                return qsTr("Copy input data")
            case TransactionAddressMenu.AddressType.Tx:
                return qsTr("Copy Tx hash")
            case TransactionAddressMenu.AddressType.Sender:
                return qsTr("Copy sender address")
            case TransactionAddressMenu.AddressType.Receiver:
                return qsTr("Copy receiver address")
            default:
                return qsTr("Copy address")
            }
        }
        icon.name: "copy"
        onTriggered: ClipboardUtils.setText(d.selectedAddress)
    }
    StatusAction {
        id: showQrAction
        enabled: false
        text: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Sender:
                return qsTr("Show sender address QR")
            case TransactionAddressMenu.AddressType.Receiver:
                return qsTr("Show receiver address QR")
            default:
                return qsTr("Show address QR")
            }
        }
        icon.name: "qr"
        onTriggered: {
            onTriggered: Global.openShowQRPopup({
                                                    showSingleAccount: true,
                                                    switchingAccounsEnabled: false,
                                                    hasFloatingButtons: false,
                                                    name: d.addressName,
                                                    address: d.selectedAddress,
                                                    colorId: d.colorId,
                                                })
        }
    }
    StatusAction {
        id: saveAddressAction
        enabled: false
        text: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Sender:
                return qsTr("Save sender address")
            case TransactionAddressMenu.AddressType.Receiver:
                return qsTr("Save receiver address")
            default:
                return qsTr("Save address")
            }
        }
        icon.name: "star-icon-outline"
        onTriggered: {
            Global.openAddEditSavedAddressesPopup({
                                                      addAddress: true,
                                                      address: d.selectedAddress,
                                                      ens: d.addressEns
                                                  })
        }
    }
    StatusAction {
        id: editAddressAction
        enabled: false
        text: qsTr("Edit saved address")
        icon.name: "pencil-outline"
        onTriggered: Global.openAddEditSavedAddressesPopup({
                                          edit: true,
                                          name: d.addressName,
                                          address: d.selectedAddress,
                                          ens: d.addressEns,
                                          colorId: d.colorId})
    }
    StatusAction {
        id: sendToAddressAction
        enabled: false
        text: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Sender:
                return qsTr("Send to sender address")
            case TransactionAddressMenu.AddressType.Receiver:
                return qsTr("Send to receiver address")
            default:
                return qsTr("Send to address")
            }
        }
        icon.name: "send"
        onTriggered: root.openSendModal(d.selectedAddress)
    }
}
