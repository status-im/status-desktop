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

    onTransactionChanged: {
        d.decodedInputData = ""
        if (!transaction || !transaction.input || !RootStore.history)
            return
        RootStore.history.fetchDecodedTxData(transaction.txHash, transaction.input)
    }

    QtObject {
        id: d
        readonly property bool isIncoming: transactionType === Constants.TransactionType.Received
        readonly property string networkShortName: root.isTransactionValid ? RootStore.getNetworkShortName(transaction.chainId) : ""
        readonly property string networkIcon: isTransactionValid ? RootStore.getNetworkIcon(transaction.chainId) : ""
        readonly property int blockNumber: root.isTransactionValid ? RootStore.hex2Dec(root.transaction.blockNumber) : 0
        readonly property int toBlockNumber: 0 // TODO fill when bridge data is implemented
        readonly property string toNetworkIcon: "" // TODO fill when bridge data is implemented
        readonly property string toNetworkShortName: "" // TODO fill when bridge data is implemented
        readonly property string symbol: isTransactionValid ? transaction.symbol : ""
        readonly property string inSymbol: isTransactionValid ? transaction.inSymbol : ""
        readonly property string outSymbol: isTransactionValid ? transaction.outSymbol : ""
        readonly property var multichainNetworks: [] // TODO fill icon for networks for multichain
        readonly property string fiatValueFormatted: root.isTransactionValid && !transactionHeader.isMultiTransaction ? RootStore.formatCurrencyAmount(transactionHeader.fiatValue, RootStore.currentCurrency) : ""
        readonly property string cryptoValueFormatted: root.isTransactionValid && !transactionHeader.isMultiTransaction ? RootStore.formatCurrencyAmount(transaction.amount, transaction.symbol) : ""
        readonly property string outFiatValueFormatted: root.isTransactionValid && transactionHeader.isMultiTransaction ? RootStore.formatCurrencyAmount(transactionHeader.outFiatValue, RootStore.currentCurrency) : ""
        readonly property string outCryptoValueFormatted: root.isTransactionValid && transactionHeader.isMultiTransaction ? RootStore.formatCurrencyAmount(transaction.outAmount, transaction.outSymbol) : ""
        readonly property real feeEthValue: root.isTransactionValid ? RootStore.getGasEthValue(transaction.totalFees.amount, 1) : 0 // TODO use directly?
        readonly property real feeFiatValue: root.isTransactionValid ? RootStore.getFiatValue(d.feeEthValue, "ETH", RootStore.currentCurrency) : 0 // TODO use directly?
        readonly property int transactionType: root.isTransactionValid ? transaction.txType : Constants.TransactionType.Send
        readonly property string toNetworkName: "" // TODO fill network name for bridge

        property string decodedInputData: ""

        function getNameForSavedWalletAddress(address) {
            return RootStore.getNameForSavedWalletAddress(address)
        }

        function retryTransaction() {
            // TODO handle failed transaction retry
        }
    }

    Connections {
        target: RootStore.history
        function onTxDecoded(txHash: string, dataDecoded: string) {
            if (!root.isTransactionValid || txHash !== root.transaction.txHash || !dataDecoded)
                return
            try {
                const decodedObject = JSON.parse(dataDecoded)
                let text = qsTr("Function: %1").arg(decodedObject.signature)
                text += "\n" + qsTr("MethodID: %1").arg(decodedObject.id)
                for (const [key, value] of Object.entries(decodedObject.inputs)) {
                    text += "\n[%1]: %2".arg(key).arg(value)
                }
                d.decodedInputData = text
            } catch(e) {
                console.error("Failed to parse decoded tx data. Data:", dataDecoded)
            }
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
                    sensor.enabled: false
                    color: Theme.palette.transparent
                    state: "header"

                    modelData: transaction
                    timeStampText: root.isTransactionValid ? qsTr("Signed at %1").arg(LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat)): ""
                    rootStore: RootStore
                    walletRootStore: WalletStores.RootStore

                    onRetryClicked: d.retryTransaction()
                }

                Separator { }
            }

            WalletTxProgressBlock {
                id: progressBlock
                width: Math.min(513, root.width)
                error: transactionHeader.transactionStatus === Constants.TransactionStatus.Failed
                isLayer1: root.isTransactionValid && RootStore.getNetworkLayer(root.transaction.chainId) == 1
                confirmations: root.isTransactionValid ? Math.abs(WalletStores.RootStore.getLatestBlockNumber(root.transaction.chainId) - d.blockNumber): 0
                chainName: transactionHeader.networkName
                timeStamp: root.isTransactionValid ? transaction.timestamp: ""
            }

            Separator {
                width: progressBlock.width
            }

            WalletNftPreview {
                visible: root.isTransactionValid && transactionHeader.isNFT && !!transaction.nftImageUrl
                width: Math.min(304, progressBlock.width)
                nftName: root.isTransactionValid ? transaction.nftName : ""
                nftUrl: root.isTransactionValid && !!transaction.nftImageUrl ? transaction.nftImageUrl : ""
                strikethrough: d.transactionType === Constants.TransactionType.Destroy
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
                        height: fromNetworkTile.visible || toNetworkTile.visible ? 85 : 0
                        TransactionDataTile {
                            id: fromNetworkTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            title: qsTr("From")
                            subTitle: {
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return d.outSymbol
                                case Constants.TransactionType.Bridge:
                                    return transactionHeader.networkName
                                default:
                                    return ""
                                }
                            }
                            asset.name: {
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return !!d.outSymbol ? Constants.tokenIcon(d.outSymbol) : ""
                                case Constants.TransactionType.Bridge:
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
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return d.inSymbol
                                case Constants.TransactionType.Bridge:
                                    return d.toNetworkName
                                default:
                                    return ""
                                }
                            }
                            asset.name: {
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return !!d.inSymbol ? Constants.tokenIcon(d.inSymbol) : ""
                                case Constants.TransactionType.Bridge:
                                    return !!d.toNetworkIcon ? Style.svg(d.toNetworkIcon) : ""
                                default:
                                    return ""
                                }
                            }
                            visible: !!subTitle
                        }
                    }
                    TransactionAddressTile {
                        width: parent.width
                        title: d.transactionType === Constants.TransactionType.Swap || d.transactionType === Constants.TransactionType.Bridge ?
                                   qsTr("In") : qsTr("From")
                        addresses: root.isTransactionValid ? [root.transaction.sender] : []
                        contactsStore: root.contactsStore
                        rootStore: WalletStores.RootStore
                        onButtonClicked: {
                            if (d.transactionType === Constants.TransactionType.Swap || d.transactionType === Constants.TransactionType.Bridge) {
                                addressMenu.openEthAddressMenu(this, addresses[0], d.networkShortName)
                            } else {
                                addressMenu.openSenderMenu(this, addresses[0], d.networkShortName)
                            }
                        }
                    }
                    TransactionAddressTile {
                        width: parent.width
                        title: qsTr("To")
                        addresses: root.isTransactionValid && visible ? [root.transaction.recipient] : []
                        contactsStore: root.contactsStore
                        rootStore: WalletStores.RootStore
                        onButtonClicked: addressMenu.openReceiverMenu(this, addresses[0], d.networkShortName)
                        visible: d.transactionType !== Constants.TransactionType.Swap && d.transactionType !== Constants.TransactionType.Bridge && d.transactionType !== Constants.TransactionType.Destroy
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
                        title: qsTr("%1 Tx hash").arg(transactionHeader.networkName)
                        subTitle: root.isTransactionValid ? root.transaction.txHash : ""
                        visible: !!subTitle
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, d.networkShortName)
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("%1 Tx hash").arg(d.toNetworkName)
                        subTitle: "" // TODO fill tx hash for Bridge
                        visible: !!subTitle
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, d.toNetworkShortName)
                    }
                    TransactionContractTile {
                        // Used for Bridge and Swap to display 'From' network Protocol contract address
                        address: "" // TODO fill protocol contract address for 'from' network for Bridge and Swap
                        symbol: "" // TODO fill protocol name for Bridge and Swap
                        networkName: transactionHeader.networkName
                        shortNetworkName: d.networkShortName
                        visible: !!subTitle && (d.transactionType === Constants.TransactionType.Bridge || d.transactionType === Constants.TransactionType.Swap)
                    }
                    TransactionContractTile {
                        // Used to display contract address for any network
                        address: root.isTransactionValid ? transaction.contract : ""
                        symbol: root.isTransactionValid ? d.symbol : ""
                        networkName: transactionHeader.networkName
                        shortNetworkName: d.networkShortName
                    }
                    TransactionContractTile {
                        // Used for Bridge to display 'To' network Protocol contract address
                        address: "" // TODO fill protocol contract address for 'to' network for Bridge
                        symbol: "" // TODO fill protocol name for Bridge
                        networkName: d.toNetworkName
                        shortNetworkName: d.toNetworkShortName
                        visible: !!subTitle && d.transactionType === Constants.TransactionType.Bridge
                    }
                    TransactionContractTile {
                        // Used for Bridge and Swap to display 'To' network token contract address
                        address: {
                            if (!root.isTransactionValid)
                                return ""
                            switch(d.transactionType) {
                            case Constants.TransactionType.Swap:
                                return "" // TODO fill swap contract address for Swap
                            case Constants.TransactionType.Bridge:
                                return "" // TODO fill swap token's contract address for 'to' network for Bridge
                            default:
                                return ""
                            }
                        }
                        symbol: {
                            if (!root.isTransactionValid)
                                return ""
                            switch(d.transactionType) {
                            case Constants.TransactionType.Swap:
                                return d.inSymbol
                            case Constants.TransactionType.Bridge:
                                return d.outSymbol
                            default:
                                return ""
                            }
                        }
                        networkName: d.toNetworkName
                        shortNetworkName: d.toNetworkShortName
                        visible: root.isTransactionValid && !!subTitle
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
                            subTitle: transactionHeader.networkName
                            asset.name: !!d.networkIcon ? Style.svg("%1".arg(d.networkIcon)) : ""
                            smallIcon: true
                            visible: d.transactionType !== Constants.TransactionType.Bridge
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
                        id: inputDataTile
                        width: parent.width
                        height: Math.min(implicitHeight + bottomPadding, 112)
                        title: qsTr("Input data")
                        subTitle: {
                            if (!!d.decodedInputData) {
                                return d.decodedInputData
                            } else if (root.isTransactionValid) {
                                return root.transaction.input
                            }
                            return ""
                        }
                        visible: !!subTitle
                        buttonIconName: "more"
                        statusListItemSubTitle.maximumLineCount: 4
                        statusListItemSubTitle.lineHeight: 1.21
                        onButtonClicked: addressMenu.openInputDataMenu(this, subTitle)
                        statusListItemSubTitle.layer.enabled: statusListItemSubTitle.lineCount > 3
                        statusListItemSubTitle.layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: 10
                                height: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#f00" }
                                    GradientStop { position: 0.4; color: "#a0ff0000" }
                                    GradientStop { position: 0.75; color: "#00ff0000" }
                                }
                            }
                        }
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: !!transactionHeader.networkName ? qsTr("Included in Block on %1").arg(transactionHeader.networkName) : qsTr("Included on Block")
                        subTitle: d.blockNumber
                        tertiaryTitle: root.isTransactionValid ? LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat) : ""
                        visible: d.blockNumber > 0
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: !!d.toNetworkName ? qsTr("Included in Block on %1").arg(d.toNetworkName) : qsTr("Included on Block")
                        subTitle: d.toBlockNumber
                        tertiaryTitle: root.isTransactionValid ? LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat) : ""
                        visible: d.toBlockNumber > 0
                    }
                }
            }

            Column {
                width: progressBlock.width
                spacing: Style.current.smallPadding
                visible: !(transactionHeader.isNFT && d.isIncoming)

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
                        subTitle: transactionHeader.isMultiTransaction ? d.outCryptoValueFormatted : d.cryptoValueFormatted
                        tertiaryTitle: transactionHeader.isMultiTransaction ? d.outFiatValueFormatted : d.fiatValueFormatted
                        visible: {
                            if (transactionHeader.isNFT)
                                return false
                            switch(d.transactionType) {
                            case Constants.TransactionType.Send:
                            case Constants.TransactionType.Swap:
                            case Constants.TransactionType.Bridge:
                                return true
                            default:
                                return false
                            }
                        }
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: transactionHeader.transactionStatus === Constants.TransactionType.Pending ? qsTr("Amount to receive") : qsTr("Amount received")
                        subTitle: {
                            if (!root.isTransactionValid || transactionHeader.isNFT)
                                return ""
                            const type = d.transactionType
                            if (type === Constants.TransactionType.Swap) {
                                return RootStore.formatCurrencyAmount(transactionHeader.inCryptoValue, d.inSymbol)
                            } else if (type === Constants.TransactionType.Bridge) {
                                // Reduce crypto value by fee value
                                const valueInCrypto = RootStore.getCryptoValue(transactionHeader.fiatValue - d.feeFiatValue, d.inSymbol, RootStore.currentCurrency)
                                return RootStore.formatCurrencyAmount(valueInCrypto, d.inSymbol)
                            }
                            return ""
                        }
                        tertiaryTitle: {
                            const type = d.transactionType
                            if (type === Constants.TransactionType.Swap) {
                                return RootStore.formatCurrencyAmount(transactionHeader.inFiatValue, RootStore.currentCurrency)
                            } else if (type === Constants.TransactionType.Bridge) {
                                return RootStore.formatCurrencyAmount(transactionHeader.fiatValue - d.feeFiatValue, RootStore.currentCurrency)
                            }
                            return ""
                        }
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("Fees")
                        subTitle: {
                            if (!root.isTransactionValid || transactionHeader.isNFT)
                                return ""
                            switch(d.transactionType) {
                            case Constants.TransactionType.Send:
                            case Constants.TransactionType.Swap:
                            case Constants.TransactionType.Bridge:
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
                        title: d.transactionType === Constants.TransactionType.Destroy || transactionHeader.isNFT ? qsTr("Fees") : qsTr("Total")
                        subTitle: {
                            if (transactionHeader.isNFT && d.isIncoming)
                                return ""
                            const type = d.transactionType
                            if (type === Constants.TransactionType.Destroy || transactionHeader.isNFT) {
                                return RootStore.formatCurrencyAmount(d.feeEthValue, "ETH")
                            } else if (type === Constants.TransactionType.Receive || (type === Constants.TransactionType.Buy && progressBlock.isLayer1)) {
                                return d.cryptoValueFormatted
                            }
                            const cryptoValue = transactionHeader.isMultiTransaction ? d.outCryptoValueFormatted : d.cryptoValueFormatted
                            return "%1 + %2".arg(cryptoValue).arg(RootStore.formatCurrencyAmount(d.feeEthValue, "ETH"))
                        }
                        tertiaryTitle: {
                            if (transactionHeader.isNFT && d.isIncoming)
                                return ""
                            const type = d.transactionType
                            if (type === Constants.TransactionType.Destroy || transactionHeader.isNFT) {
                                return RootStore.formatCurrencyAmount(d.feeFiatValue, RootStore.currentCurrency)
                            } else if (type === Constants.TransactionType.Receive || (type === Constants.TransactionType.Buy && progressBlock.isLayer1)) {
                                return d.fiatValueFormatted
                            }
                            const fiatValue = transactionHeader.isMultiTransaction ? transactionHeader.outFiatValue : transactionHeader.fiatValue
                            return RootStore.formatCurrencyAmount(fiatValue + d.feeFiatValue, RootStore.currentCurrency)
                        }
                        visible: !!subTitle
                        highlighted: true
                        statusListItemTertiaryTitle.customColor: Theme.palette.directColor1
                    }
                }
            }
            
            Separator {
                width: progressBlock.width
            }

            RowLayout {
                width: progressBlock.width
                visible: root.isTransactionValid
                spacing: 8
                StatusButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: copyDetailsButton.height
                    text: qsTr("Repeat transaction")
                    size: StatusButton.Small
                    visible: root.isTransactionValid && !root.overview.isWatchOnlyAccount && d.transactionType === TransactionDelegate.Send
                    onClicked: {
                        root.sendModal.open(root.transaction.to)
                        // TODO handle other types
                    }
                }
                StatusButton {
                    id: copyDetailsButton
                    Layout.fillWidth: true
                    text: qsTr("Copy details")
                    icon.name: "copy"
                    icon.width: 20
                    icon.height: 20
                    size: StatusButton.Small
                    onClicked: RootStore.copyToClipboard(transactionHeader.getDetailsString())
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
        height: {
            // Using childrenRect and transactionvalid properties to refresh this binding
            if (!isTransactionValid || detailsColumn.childrenRect.height === 0)
                return 0

            // Height is calculated from visible children because Column doesn't handle
            // visibility change properly and childrenRect.height gives different values
            // comparing to manual check
            var visibleHeight = 0
            for (var i = 0 ; i < detailsColumn.children.length ; i++) {
                if (detailsColumn.children[i].visible)
                    visibleHeight += detailsColumn.children[i].height
            }
            return visibleHeight
        }

        default property alias content: detailsColumn.children

        Rectangle {
            id: tileBackground
            anchors.fill: parent
            color: Style.current.transparent
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
                // Separate rectangle is used as mask because background rectangle must be transaprent
                maskSource: Rectangle {
                    width: tileBackground.width
                    height: tileBackground.height
                    radius: tileBackground.radius
                }
            }
        }
    }

    component TransactionContractTile: TransactionDataTile {
        property string networkName: ""
        property string symbol: ""
        property string address: ""
        property string shortNetworkName: ""
        width: parent.width
        title: visible ? qsTr("%1 %2 contract address").arg(networkName).arg(symbol) : ""
        subTitle: !!address && !/0x0+$/.test(address) ? address : ""
        buttonIconName: "more"
        visible: !!subTitle
        onButtonClicked: addressMenu.openContractMenu(this, address, shortNetworkName, symbol)
    }
}
