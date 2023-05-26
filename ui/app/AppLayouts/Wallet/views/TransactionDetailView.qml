import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import shared.panels 1.0
import utils 1.0
import shared.stores 1.0

import "../controls"
import "../popups"
import "../stores" as WalletStores
import ".."
import "../panels"

Item {
    id: root

    property var overview: WalletStores.RootStore.overview
    property var contactsStore
    property var transaction
    property var sendModal
    readonly property bool isTransactionValid: transaction !== undefined && !!transaction

    QtObject {
        id: d
        readonly property bool isIncoming: root.isTransactionValid ? root.transaction.to.toLowerCase() === root.overview.mixedcaseAddress.toLowerCase() : false
        readonly property bool isNFT: root.isTransactionValid ? root.transaction.isNFT : false
        readonly property string savedAddressNameTo: root.isTransactionValid ? d.getNameForSavedWalletAddress(transaction.to) : ""
        readonly property string savedAddressNameFrom: root.isTransactionValid ? d.getNameForSavedWalletAddress(transaction.from): ""
        readonly property string from: root.isTransactionValid ? !!savedAddressNameFrom ? savedAddressNameFrom : Utils.compactAddress(transaction.from, 4): ""
        readonly property string to: root.isTransactionValid ? !!savedAddressNameTo ? savedAddressNameTo : Utils.compactAddress(transaction.to, 4): ""
        readonly property string savedAddressEns: root.isTransactionValid ? RootStore.getEnsForSavedWalletAddress(isIncoming ? transaction.from : transaction.to) : ""
        readonly property string savedAddressChains: root.isTransactionValid ? RootStore.getChainShortNamesForSavedWalletAddress(isIncoming ? transaction.from : transaction.to) : ""
        readonly property string networkShortName: root.isTransactionValid ? RootStore.getNetworkShortName(transaction.chainId) : ""
        readonly property string networkFullName: root.isTransactionValid ? RootStore.getNetworkFullName(transaction.chainId): ""
        readonly property string networkIcon: root.isTransactionValid ? RootStore.getNetworkIcon(transaction.chainId): ""
        readonly property int blockNumber: root.isTransactionValid ? RootStore.hex2Dec(root.transaction.blockNumber) : 0
        readonly property string bridgeNetworkIcon: "" // TODO fill when bridge data is implemented
        readonly property string bridgeNetworkFullname: ""  // TODO fill when bridge data is implemented
        readonly property string bridgeNetworkShortName: "" // TODO fill when bridge data is implemented
        readonly property int bridgeBlockNumber: 0 // TODO fill when bridge data is implemented
        readonly property double swapCryptoValue: 0 // TODO fill when swap data is implemented
        readonly property string swapSymbol: "" // TODO fill when swap data is implemented
        readonly property string symbol: root.isTransactionValid ? transaction.symbol : ""
        readonly property var multichainNetworks: [] // TODO fill icon for networks for multichain
        readonly property double cryptoValue: root.isTransactionValid ? transaction.value.amount: 0.0
        readonly property double fiatValue: root.isTransactionValid ? RootStore.getFiatValue(cryptoValue, symbol, RootStore.currentCurrency): 0.0
        readonly property string fiatValueFormatted: root.isTransactionValid ? RootStore.formatCurrencyAmount(d.fiatValue, RootStore.currentCurrency) : ""
        readonly property string cryptoValueFormatted: root.isTransactionValid ? LocaleUtils.currencyAmountToLocaleString(transaction.value) : ""
        readonly property real feeEthValue: root.isTransactionValid ? RootStore.getGasEthValue(transaction.totalFees.amount, 1) : 0
        readonly property real feeFiatValue: root.isTransactionValid ? RootStore.getFiatValue(d.feeEthValue, "ETH", RootStore.currentCurrency) : 0

        function getNameForSavedWalletAddress(address) {
            return RootStore.getNameForSavedWalletAddress(address)
        }

        function retryTransaction() {
            // TODO handle failed transaction retry
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        Column {
            id: column
            width: scrollView.availableWidth
            spacing: Style.current.xlPadding + Style.current.halfPadding

            Column {
                width: parent.width
                spacing: Style.current.bigPadding

                TransactionDelegate {
                    id: transactionHeader
                    objectName: "transactionDetailHeader"
                    width: parent.width
                    leftPadding: 0

                    modelData: transaction
                    transactionType: d.isIncoming ? TransactionDelegate.Receive : TransactionDelegate.Send
                    currentCurrency: RootStore.currentCurrency
                    cryptoValue: d.cryptoValue
                    fiatValue: d.fiatValue
                    networkIcon: d.networkIcon
                    networkColor: root.isTransactionValid ? RootStore.getNetworkColor(transaction.chainId): ""
                    networkName: d.networkFullName
                    swapSymbol: d.swapSymbol
                    bridgeNetworkName: d.bridgeNetworkFullname
                    symbol: d.symbol
                    transferStatus: root.isTransactionValid ? RootStore.hex2Dec(transaction.txStatus): ""
                    timeStampText: root.isTransactionValid ? qsTr("Signed at %1").arg(LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat)): ""
                    addressNameTo: root.isTransactionValid ? WalletStores.RootStore.getNameForAddress(transaction.to): ""
                    addressNameFrom: root.isTransactionValid ? WalletStores.RootStore.getNameForAddress(transaction.from): ""
                    sensor.enabled: false
                    formatCurrencyAmount: RootStore.formatCurrencyAmount
                    color: Theme.palette.transparent
                    state: "header"
                    onRetryClicked: d.retryTransaction()
                }

                Separator { }
            }

            WalletTxProgressBlock {
                id: progressBlock
                width: Math.min(513, root.width)
                error: transactionHeader.transactionStatus === TransactionDelegate.TransactionStatus.Failed
                isLayer1: RootStore.getNetworkLayer(root.transaction.chainId) == 1
                confirmations: root.isTransactionValid ? Math.abs(WalletStores.RootStore.getLatestBlockNumber(root.transaction.chainId) - d.blockNumber): 0
                chainName: d.networkFullName
                timeStamp: root.isTransactionValid ? transaction.timestamp: ""
            }

            Separator {
                width: progressBlock.width
            }

            WalletNftPreview {
                visible: root.isTransactionValid && d.isNFT && !!transaction.nftImageUrl
                width: Math.min(304, progressBlock.width)
                nftName: root.isTransactionValid ? transaction.nftName : ""
                nftUrl: root.isTransactionValid && !!transaction.nftImageUrl ? transaction.nftImageUrl : ""
                strikethrough: transactionHeader.transactionType === TransactionDelegate.Destroy
                tokenId: root.isTransactionValid ? transaction.tokenID : ""
                contractAddress: root.isTransactionValid ? transaction.contract : ""
            }

            Column {
                width: progressBlock.width
                spacing: 0

                StatusBaseText {
                    width: parent.width
                    font.pixelSize: 15
                    color: Theme.palette.directColor5
                    text: qsTr("Transaction summary")
                    elide: Text.ElideRight
                }

                Item {
                    width: parent.width
                    height: Style.current.smallPadding
                }

                DetailsPanel {
                    RowLayout {
                        spacing: 0
                        width: parent.width
                        height: opacity > 0 ? Math.max(implicitHeight, 85) : 0
                        opacity: fromNetworkTile.visible || toNetworkTile.visible ? 1 : 0
                        TransactionDataTile {
                            id: fromNetworkTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            title: qsTr("From")
                            subTitle: {
                                switch(transactionHeader.transactionType) {
                                case TransactionDelegate.Swap:
                                    return d.symbol
                                case TransactionDelegate.Bridge:
                                    return d.networkFullName
                                default:
                                    return ""
                                }
                            }
                            asset.name: {
                                switch(transactionHeader.transactionType) {
                                case TransactionDelegate.Swap:
                                    return !!d.symbol ? Style.png("tokens/%1".arg(d.symbol)) : ""
                                case TransactionDelegate.Bridge:
                                    return !!d.networkIcon ? Style.svg(d.networkIcon) : ""
                                default:
                                    return ""
                                }
                            }
                            visible: !!subTitle
                        }
                        TransactionDataTile {
                            id: toNetworkTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            title: qsTr("To")
                            subTitle: {
                                switch(transactionHeader.transactionType) {
                                case TransactionDelegate.Swap:
                                    return d.swapSymbol
                                case TransactionDelegate.Bridge:
                                    return d.bridgeNetworkFullname
                                default:
                                    return ""
                                }
                            }
                            asset.name: {
                                switch(transactionHeader.transactionType) {
                                case TransactionDelegate.Swap:
                                    return !!d.swapSymbol ? Style.png("tokens/%1".arg(d.swapSymbol)) : ""
                                case TransactionDelegate.Bridge:
                                    return !!d.bridgeNetworkIcon ? Style.svg(d.bridgeNetworkIcon) : ""
                                default:
                                    return ""
                                }
                            }
                            visible: !!subTitle
                        }
                    }
                    TransactionAddressTile {
                        width: parent.width
                        title: transactionHeader.transactionType === TransactionDelegate.Swap || transactionHeader.transactionType === TransactionDelegate.Bridge ?
                                   qsTr("In") : qsTr("From")
                        addresses: root.isTransactionValid ? [root.transaction.from] : []
                        contactsStore: root.contactsStore
                        rootStore: WalletStores.RootStore
                        onButtonClicked: {
                            if (transactionHeader.transactionType === TransactionDelegate.Swap || transactionHeader.transactionType === TransactionDelegate.Bridge) {
                                addressMenu.openEthAddressMenu(this, addresses[0])
                            } else {
                                addressMenu.openSenderMenu(this, addresses[0])
                            }
                        }
                    }
                    TransactionAddressTile {
                        width: parent.width
                        title: qsTr("To")
                        addresses: root.isTransactionValid ? [root.transaction.to] : []
                        contactsStore: root.contactsStore
                        rootStore: WalletStores.RootStore
                        onButtonClicked: addressMenu.openReceiverMenu(this, addresses[0])
                        visible: transactionHeader.transactionType !== TransactionDelegate.Swap && transactionHeader.transactionType !== TransactionDelegate.Bridge && transactionHeader.transactionType !== TransactionDelegate.Destroy
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("Using")
                        buttonIconName: "external"
                        subTitle: "" // TODO fill protocol name for Swap and Bridge
                        asset.name: "" // TODO fill protocol icon for Bridge and Swap e.g. Style.svg("network/Network=Arbitrum")
                        onButtonClicked: {
                            // TODO handle
                        }
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("%1 Tx hash").arg(d.networkFullName)
                        subTitle: root.isTransactionValid ? root.transaction.txHash : ""
                        visible: !!subTitle
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, d.networkShortName)
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("%1 Tx hash").arg(d.bridgeNetworkFullname)
                        subTitle: "" // TODO fill tx hash for Bridge
                        visible: !!subTitle
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, d.bridgeNetworkShortName)
                    }
                    TransactionContractTile {
                        // Used for Bridge and Swap to display 'From' network Protocol contract address
                        address: "" // TODO fill protocol contract address for 'from' network for Bridge and Swap
                        symbol: "" // TODO fill protocol name for Bridge and Swap
                        networkName: d.networkFullName
                        shortNetworkName: d.networkShortName
                        visible: !!subTitle && (transactionHeader.transactionType === TransactionDelegate.Bridge || transactionHeader.transactionType === TransactionDelegate.Swap)
                    }
                    TransactionContractTile {
                        // Used to display contract address for any network
                        address: root.isTransactionValid ? transaction.contract : ""
                        symbol: root.isTransactionValid ? transaction.value.symbol.toUpperCase() : ""
                        networkName: d.networkFullName
                        shortNetworkName: d.networkShortName
                    }
                    TransactionContractTile {
                        // Used for Bridge to display 'To' network Protocol contract address
                        address: "" // TODO fill protocol contract address for 'to' network for Bridge
                        symbol: "" // TODO fill protocol name for Bridge
                        networkName: d.bridgeNetworkFullname
                        shortNetworkName: d.bridgeNetworkShortName
                        visible: !!subTitle && transactionHeader.transactionType === TransactionDelegate.Bridge
                    }
                    TransactionContractTile {
                        // Used for Bridge and Swap to display 'To' network token contract address
                        address: {
                            if (!root.isTransactionValid)
                                return ""
                            switch(transactionHeader.transactionType) {
                            case TransactionDelegate.Swap:
                                return transaction.contract
                            case TransactionDelegate.Bridge:
                                return "" // TODO fill swap token's contract address for 'to' network for Bridge
                            default:
                                return ""
                            }
                        }
                        symbol: {
                            if (!root.isTransactionValid)
                                return ""
                            switch(transactionHeader.transactionType) {
                            case TransactionDelegate.Swap:
                                return d.swapSymbol
                            case TransactionDelegate.Bridge:
                                return transaction.value.symbol.toUpperCase()
                            default:
                                return ""
                            }
                        }
                        networkName: d.bridgeNetworkFullname
                        shortNetworkName: d.bridgeNetworkShortName
                    }
                }

                Item {
                    width: parent.width
                    height: Style.current.bigPadding
                }

                DetailsPanel {
                    width: progressBlock.width
                    RowLayout {
                        width: parent.width
                        height: Math.max(implicitHeight, 85)
                        spacing: 0
                        TransactionDataTile {
                            id: multichainNetworksTile
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Networks")
                            visible: d.multichainNetworks.length > 0
                            Row {
                                anchors {
                                    top: parent.top
                                    topMargin: multichainNetworksTile.statusListItemTitleArea.height + multichainNetworksTile.topPadding
                                    left: parent.left
                                    leftMargin: multichainNetworksTile.leftPadding
                                }
                                spacing: -4
                                Repeater {
                                    model: d.multichainNetworks
                                    delegate: StatusRoundedImage {
                                        width: 20
                                        height: 20
                                        visible: image.source !== ""
                                        border.width: index === 0 ? 0 : 1
                                        border.color: Theme.palette.white
                                        image.source: Style.svg("tiny/" + modelData)
                                        z: index + 1
                                    }
                                }
                            }
                        }
                        TransactionDataTile {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Network")
                            subTitle: d.networkFullName
                            asset.name: !!d.networkIcon ? Style.svg("%1".arg(d.networkIcon)) : ""
                            smallIcon: true
                            visible: transactionHeader.transactionType !== TransactionDelegate.Bridge
                        }
                        TransactionDataTile {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Token format")
                            subTitle: root.isTransactionValid ? transaction.type.toUpperCase() : ""
                            visible: !!subTitle
                        }
                        TransactionDataTile {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Nonce")
                            subTitle: root.isTransactionValid ? RootStore.hex2Dec(root.transaction.nonce) : ""
                            visible: !!subTitle
                        }
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("Input data")
                        subTitle: root.isTransactionValid ? root.transaction.input : ""
                        visible: !!subTitle
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openInputDataMenu(this, subTitle)
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: !!d.networkFullName ? qsTr("Included in Block on %1").arg(d.networkFullName) : qsTr("Included on Block")
                        subTitle: d.blockNumber
                        tertiaryTitle: root.isTransactionValid ? LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat) : ""
                        visible: d.blockNumber > 0
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: !!d.bridgeNetworkFullname ? qsTr("Included in Block on %1").arg(d.bridgeNetworkFullname) : qsTr("Included on Block")
                        subTitle: d.bridgeBlockNumber
                        tertiaryTitle: root.isTransactionValid ? LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat) : ""
                        visible: d.bridgeBlockNumber > 0
                    }
                }
            }

            Column {
                width: progressBlock.width
                spacing: Style.current.smallPadding
                visible: !(d.isNFT && d.isIncoming)

                RowLayout {
                    width: parent.width
                    StatusBaseText {
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 15
                        color: Theme.palette.directColor5
                        text: qsTr("Values")
                        elide: Text.ElideRight
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        font.pixelSize: 15
                        color: Theme.palette.directColor5
                        text: root.isTransactionValid ? qsTr("as of %1").arg(LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat)) : ""
                        elide: Text.ElideRight
                    }
                }

                DetailsPanel {
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("Amount sent")
                        subTitle: d.cryptoValueFormatted
                        tertiaryTitle: d.fiatValueFormatted
                        visible: {
                            if (d.isNFT)
                                return false
                            switch(transactionHeader.transactionType) {
                            case TransactionDelegate.Send:
                            case TransactionDelegate.Swap:
                            case TransactionDelegate.Bridge:
                                return true
                            default:
                                return false
                            }
                        }
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: transactionHeader.transactionStatus === TransactionDelegate.Pending ? qsTr("Amount to receive") : qsTr("Amount received")
                        subTitle: {
                            if (d.isNFT)
                                return ""
                            const type = transactionHeader.transactionType
                            if (type === TransactionDelegate.Swap) {
                                return RootStore.formatCurrencyAmount(d.swapCryptoValue, d.swapSymbol)
                            } else if (type === TransactionDelegate.Bridge) {
                                // Reduce crypto value by fee value
                                const valueInCrypto = RootStore.getCryptoValue(d.fiatValue - d.feeFiatValue, d.symbol, RootStore.currentCurrency)
                                return RootStore.formatCurrencyAmount(valueInCrypto, d.symbol)
                            }
                            return ""
                        }
                        tertiaryTitle: {
                            const type = transactionHeader.transactionType
                            if (type === TransactionDelegate.Swap) {
                                return RootStore.formatCurrencyAmount(d.swapCryptoValue, d.swapSymbol)
                            } else if (type === TransactionDelegate.Bridge) {
                                return RootStore.formatCurrencyAmount(d.fiatValue - d.feeFiatValue, RootStore.currentCurrency)
                            }
                            return ""
                        }
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("Fees")
                        subTitle: {
                            if (!root.isTransactionValid || d.isNFT)
                                return ""
                            switch(transactionHeader.transactionType) {
                            case TransactionDelegate.Send:
                            case TransactionDelegate.Swap:
                            case TransactionDelegate.Bridge:
                                return LocaleUtils.currencyAmountToLocaleString(root.transaction.totalFees)
                            default:
                                return ""
                            }
                        }
                        tertiaryTitle: !!subTitle ? RootStore.formatCurrencyAmount(d.feeFiatValue, RootStore.currentCurrency) : ""
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        width: parent.width
                        // Using fees in this tile because of same higlight and color settings as Total
                        title: transactionHeader.transactionType === TransactionDelegate.Destroy || d.isNFT ? qsTr("Fees") : qsTr("Total")
                        subTitle: {
                            if (d.isNFT && d.isIncoming)
                                return ""
                            const type = transactionHeader.transactionType
                            if (type === TransactionDelegate.Destroy || d.isNFT) {
                                return RootStore.formatCurrencyAmount(d.feeEthValue, "ETH")
                            } else if (type === TransactionDelegate.Receive || (type === TransactionDelegate.Buy && progressBlock.isLayer1)) {
                                return d.cryptoValueFormatted
                            }
                            return "%1 + %2".arg(d.cryptoValueFormatted).arg(RootStore.formatCurrencyAmount(d.feeEthValue, "ETH"))
                        }
                        tertiaryTitle: {
                            if (d.isNFT && d.isIncoming)
                                return ""
                            const type = transactionHeader.transactionType
                            if (type === TransactionDelegate.Destroy || d.isNFT) {
                                return RootStore.formatCurrencyAmount(d.feeFiatValue, RootStore.currentCurrency)
                            } else if (type === TransactionDelegate.Receive || (type === TransactionDelegate.Buy && progressBlock.isLayer1)) {
                                return d.fiatValueFormatted
                            }
                            return RootStore.formatCurrencyAmount(d.fiatValue + d.feeFiatValue, RootStore.currentCurrency)
                        }
                        visible: !!subTitle
                        highlighted: true
                        statusListItemTertiaryTitle.customColor: Theme.palette.directColor1
                    }
                }
            }
        }
    }

    TransactionAddressMenu {
        id: addressMenu

        contactsStore: root.contactsStore
        onOpenSendModal: (address) => root.sendModal.open(address)
    }

    component DetailsPanel: Item {
        width: parent.width
        height: detailsColumn.childrenRect.height
        default property alias content: detailsColumn.children
        Rectangle {
            id: tileBackground
            anchors.fill: parent
            radius: 8
            border.width: 1
            border.color: Style.current.separator
        }

        Column {
            id: detailsColumn
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: tileBackground
            }
        }
    }

    component TransactionContractTile: TransactionDataTile {
        property string networkName: ""
        property string symbol: ""
        property string address: ""
        property string shortNetworkName: ""
        width: parent.width
        title: qsTr("%1 %2 contract address").arg(networkName).arg(symbol)
        subTitle: !!address && !/0x0+$/.test(address) ? address : ""
        buttonIconName: "more"
        visible: !!subTitle
        onButtonClicked: addressMenu.openContractMenu(this, address, shortNetworkName, symbol)
    }
}
