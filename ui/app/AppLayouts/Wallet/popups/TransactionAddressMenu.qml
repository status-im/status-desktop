import QtQuick 2.15
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import utils 1.0
import shared.stores 1.0

import "../stores" as WalletStores

StatusMenu {
    id: root

    property var contactsStore

    // TODO get those names from model
    readonly property string arbiscanShortChainName: "arb"
    readonly property string optimismShortChainName: "opt"

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

        property string addressName: ""
        property string addressEns: ""
        property string addressChains: ""

        property string contractName: ""

        property int addressType: TransactionAddressMenu.AddressType.Address

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

        function openMenu(delegate) {
            const x = delegate.width - root.contentWidth / 2
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

    function openSenderMenu(delegate, address) {
        d.addressType = TransactionAddressMenu.AddressType.Sender
        openEthAddressMenu(delegate, address, true, false)
    }

    function openReceiverMenu(delegate, address) {
        d.addressType = TransactionAddressMenu.AddressType.Receiver
        openEthAddressMenu(delegate, address)
    }

    function openEthAddressMenu(delegate, address) {
        d.selectedAddress = address

        const contactPubKey = "" // TODO retrive contact public key or contact data directly from address
        let contactData = Utils.getContactDetailsAsJson(contactPubKey)
        let isWalletAccount = false
        const isContact = contactData.isContact
        if (isContact) {
            d.addressName = contactData.name
        } else {
            d.addressName = WalletStores.RootStore.getNameForWalletAddress(address)
            isWalletAccount = d.addressName.length > 0
            if (!isWalletAccount) {
                d.addressName = WalletStores.RootStore.getNameForSavedWalletAddress(address)
            }
        }

        d.addressName = contactData.isContact ? contactData.name : WalletStores.RootStore.getNameForAddress(address)
        d.addressEns = RootStore.getEnsForSavedWalletAddress(address)
        d.addressChains = RootStore.getChainShortNamesForSavedWalletAddress(address)

        showOnEtherscanAction.enabled = true
        showOnArbiscanAction.enabled = address.includes(root.arbiscanShortChainName + ":")
        showOnOptimismAction.enabled = address.includes(root.optimismShortChainName + ":")
        saveAddressAction.enabled = d.addressName.length === 0
        editAddressAction.enabled = !isWalletAccount && !isContact && d.addressName.length > 0
        copyAddressAction.isSuccessState = false
        sendToAddressAction.enabled = true
        showQrAction.enabled = true

        d.openMenu(delegate)
    }

    function openTxMenu(delegate, address, chainShortName="") {
        d.addressType = TransactionAddressMenu.AddressType.Tx
        d.selectedAddress = address
        if (chainShortName === root.arbiscanShortChainName) {
            showOnArbiscanAction.enabled = true
        } else if (chainShortName === root.optimismShortChainName) {
            showOnOptimismAction.enabled = true
        } else {
            showOnEtherscanAction.enabled = true
        }
        d.openMenu(delegate)
    }

    function openContractMenu(delegate, address, chainShortName="", name="") {
        d.addressType = TransactionAddressMenu.AddressType.Contract
        d.contractName = name
        d.selectedAddress = address
        if (chainShortName === root.arbiscanShortChainName) {
            showOnArbiscanAction.enabled = true
        } else if (chainShortName === root.optimismShortChainName) {
            showOnOptimismAction.enabled = true
        } else {
            showOnEtherscanAction.enabled = true
        }
        d.openMenu(delegate)
    }

    function openInputDataMenu(delegate, address) {
        d.addressType = TransactionAddressMenu.AddressType.InputData
        d.selectedAddress = address
        d.openMenu(delegate)
    }

    component StatusCopyAction: StatusMenuItem {
        id: copyAction

        property bool isSuccessState: false
        property string successText: ""
        property string defaultText: ""

        text: isSuccessState ? successText : defaultText
        action: StatusAction {
            type: copyAddressAction.isSuccessState ? StatusAction.Type.Success : StatusAction.Type.Normal
            icon.name: copyAddressAction.isSuccessState ? "tiny/checkmark" : "copy"
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                RootStore.copyToClipboard(d.selectedAddress)
                copyAction.isSuccessState = true
                Backpressure.debounce(addressMenu, 2000, () => { copyAction.isSuccessState = false })()
            }
        }
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
        assetSettings.name: "link"
        onTriggered: Global.openLink("https://etherscan.io/address/%1".arg(d.selectedAddress))
    }
    StatusAction {
        id: showOnArbiscanAction
        enabled: false
        text: d.getViewText(qsTr("Arbiscan"))
        assetSettings.name: "link"
        onTriggered: Global.openLink("https://arbiscan.io/address/%1".arg(d.selectedAddress))
    }
    StatusAction {
        id: showOnOptimismAction
        enabled: false
        text: d.getViewText(qsTr("Optimism Explorer"))
        assetSettings.name: "link"
        onTriggered: Global.openLink("https://optimistic.etherscan.io/address/%1".arg(d.selectedAddress))
    }
    StatusCopyAction {
        id: copyAddressAction
        successText: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Contract:
                if (d.contractName.length > 0)
                    return qsTr("%1 contract address copied").arg(d.contractName)
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
        defaultText: {
            switch(d.addressType) {
            case TransactionAddressMenu.AddressType.Contract:
                if (d.contractName.length > 0)
                    return qsTr("Copy %1 contract address").arg(d.contractName)
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
        assetSettings.name: "qr"
        onTriggered: {
            Global.openPopup(addressQr,
                             {
                                 address: d.selectedAddress,
                                 chainShortNames: d.addressChains
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
        assetSettings.name: "star-icon-outline"
        onTriggered: {
            Global.openPopup(addEditSavedAddress,
                             {
                                 addAddress: true,
                                 address: d.selectedAddress,
                                 ens: d.addressEns,
                                 chainShortNames: d.addressChains
                             })
        }
    }
    StatusAction {
        id: editAddressAction
        enabled: false
        text: qsTr("Edit saved address")
        assetSettings.name: "pencil-outline"
        onTriggered: Global.openPopup(addEditSavedAddress,
                                      {
                                          edit: true,
                                          name: d.addressName,
                                          address: d.selectedAddress,
                                          ens: d.addressEns,
                                          chainShortNames: d.addressChains
                                      })
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
        assetSettings.name: "send"
        onTriggered: root.openSendModal(d.selectedAddress)
    }

    Component {
        id: addEditSavedAddress
        AddEditSavedAddressPopup {
            id: addEditModal
            anchors.centerIn: parent
            onClosed: destroy()
            contactsStore: root.contactsStore
            store: WalletStores.RootStore
            onSave: {
                RootStore.createOrUpdateSavedAddress(name, address, false, chainShortNames, ens)
                close()
            }
        }
    }

    Component {
        id: addressQr
        ReceiveModal {
            anchors.centerIn: parent
            readOnly: true
            hasFloatingButtons: false
            advancedHeaderComponent: Item {}
            description: qsTr("Address")
        }
    }
}
