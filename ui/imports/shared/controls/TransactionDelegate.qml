import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0

/*!
   \qmltype TransactionDelegate
   \inherits StatusListItem
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief Delegate for transaction activity list

   Delegate to display transaction activity data.

   \qml
    TransactionDelegate {
        id: delegate
        width: ListView.view.width
        modelData: model
        swapCryptoValue: 0.18
        swapFiatValue: 340
        swapSymbol: "SNT"
        timeStampText: LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000)
        cryptoValue: 0.1234
        fiatValue: 123123
        currentCurrency: "USD"
        networkName: "Optimism"
        symbol: "ETH"
        bridgeNetworkName: "Mainnet"
        feeFiatValue: 10.34
        feeCryptoValue: 0.013
        transactionStatus: TransactionDelegate.Pending
        transactionType: TransactionDelegate.Send
        rootStore: RootStore
        loading: isModelDataValid && modelData.loadingTransaction
    }
   \endqml

   Additional usages should be handled using states.
*/

StatusListItem {
    id: root

    signal retryClicked()

    property var modelData
    property string symbol
    property string swapSymbol // TODO fill when swap data is implemented
    property int transactionType
    property int transactionStatus: transferStatus === 0 ? Constants.TransactionStatus.Pending : Constants.TransactionStatus.Finished
    property string currentCurrency
    property int transferStatus
    property double cryptoValue
    property double swapCryptoValue // TODO fill when swap data is implemented
    property double fiatValue
    property double swapFiatValue // TODO fill when swap data is implemented
    property double feeCryptoValue // TODO fill when bridge data is implemented
    property double feeFiatValue // TODO fill when bridge data is implemented
    property string networkIcon
    property string networkColor
    property string networkName
    property string bridgeNetworkName // TODO fill when bridge data is implemented
    property string timeStampText
    property string addressNameTo
    property string addressNameFrom
    property var rootStore
    property var walletRootStore

    readonly property bool isModelDataValid: modelData !== undefined && !!modelData
    readonly property bool isNFT: isModelDataValid && modelData.isNFT
    readonly property string transactionValue: {
        if (!isModelDataValid)
            return qsTr("N/A")
        if (root.isNFT) {
            return modelData.nftName ? modelData.nftName : "#" + modelData.tokenID
        } else {
            return root.rootStore.formatCurrencyAmount(cryptoValue, symbol)
        }
    }
    readonly property string swapTransactionValue: {
        if (!isModelDataValid) {
            return qsTr("N/A")
        }
        return root.rootStore.formatCurrencyAmount(swapCryptoValue, swapSymbol)
    }

    readonly property string tokenImage: {
        if (!isModelDataValid)
            return ""
        if (root.isNFT) {
            return modelData.nftImageUrl ? modelData.nftImageUrl : ""
        } else {
            return root.symbol ? Style.png("tokens/%1".arg(root.symbol)) : ""
        }
    }

    readonly property string swapTokenImage: {
        if (!isModelDataValid)
            return ""
        return root.swapSymbol ? Style.png("tokens/%1".arg(root.swapSymbol)) : ""
    }

    readonly property string toAddress: !!addressNameTo ?
                                            addressNameTo :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.to, 4) :
                                                ""

    readonly property string fromAddress: !!addressNameFrom ?
                                            addressNameFrom :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.from, 4) :
                                                ""

    property StatusAssetSettings statusIconAsset: StatusAssetSettings {
        width: 12
        height: 12
        bgWidth: width + 2
        bgHeight: bgWidth
        bgRadius: bgWidth / 2
        bgColor: root.color
        color: "transparent"
        name: {
            switch(root.transactionStatus) {
            case Constants.TransactionStatus.Pending:
                return Style.svg("transaction/pending")
            case Constants.TransactionStatus.Complete:
                return Style.svg("transaction/verified")
            case Constants.TransactionStatus.Finished:
                return Style.svg("transaction/finished")
            case Constants.TransactionStatus.Failed:
                return Style.svg("transaction/failed")
            default:
                return ""
            }
        }
    }

    property StatusAssetSettings tokenIconAsset: StatusAssetSettings {
        width: 18
        height: 18
        bgWidth: width
        bgHeight: height
        bgColor: "transparent"
        color: "transparent"
        isImage: !loading
        name: root.tokenImage
        isLetterIdenticon: loading
    }

    QtObject {
        id: d

        property int loadingPixelSize: 13
        property int datePixelSize: 12
        property int titlePixelSize: 15
        property int subtitlePixelSize: 13
    }

    function getDetailsString() {
        let details = ""
        const endl = "\n"
        const endl2 = endl + endl
        const type = root.transactionType
        const feeEthValue = rootStore.getGasEthValue(modelData.totalFees.amount, 1)

        // TITLE
        switch (type) {
        case TransactionDelegate.TransactionType.Send:
            details += qsTr("Send transaction details" + endl2)
            break
        case TransactionDelegate.TransactionType.Receive:
            details += qsTr("Receive transaction details") + endl2
            break
        case TransactionDelegate.TransactionType.Buy:
            details += qsTr("Buy transaction details") + endl2
            break
        case TransactionDelegate.TransactionType.Sell:
            details += qsTr("Sell transaction details") + endl2
            break
        case TransactionDelegate.TransactionType.Destroy:
            details += qsTr("Destroy transaction details") + endl2
            break
        case TransactionDelegate.TransactionType.Swap:
            details += qsTr("Swap transaction details") + endl2
            break
        case TransactionDelegate.TransactionType.Bridge:
            details += qsTr("Bridge transaction details") + endl2
            break
        default:
            break
        }

        details += qsTr("Summary") + endl
        switch(root.transactionType) {
        case TransactionDelegate.TransactionType.Buy:
        case TransactionDelegate.TransactionType.Sell:
        case TransactionDelegate.TransactionType.Destroy:
        case TransactionDelegate.TransactionType.Swap:
        case TransactionDelegate.TransactionType.Bridge:
            details += subTitle + endl2
            break
        default:
            details += qsTr("%1 from %2 to %3 via %4").arg(transactionValue).arg(fromAddress).arg(toAddress).arg(networkName) + endl2
            break
        }

        if (root.isNFT) {
            details += qsTr("Token ID") + endl + modelData.tokenID + endl2
            details += qsTr("Token name") + endl + modelData.nftName + endl2
        }

        // PROGRESS
        const isLayer1 = rootStore.getNetworkLayer(modelData.chainId) === 1
        // A block on layer1 is every 12s
        const confirmationTimeStamp = isLayer1 ? modelData.timestamp + 12 * 4 : modelData.timestamp
        // A block on layer1 is every 12s
        const finalisationTimeStamp = isLayer1 ? modelData.timestamp + 12 * 64 : modelData.timestamp + 604800 // 7 days in seconds
        switch(transactionStatus) {
        case TransactionDelegate.TransactionStatus.Pending:
            details += qsTr("Status") + endl
            details += qsTr("Pending on %1").arg(root.networkName) + endl2
            break
        case TransactionDelegate.TransactionStatus.Failed:
            details += qsTr("Status") + endl
            details += qsTr("Failed on %1").arg(root.networkName) + endl2
            break
        case TransactionDelegate.TransactionStatus.Verified: {
            const timestampString = LocaleUtils.formatDateTime(modelData.timestamp * 1000, Locale.LongFormat)
            details += qsTr("Status") + endl
            const epoch = parseFloat(Math.abs(walletRootStore.getLatestBlockNumber(modelData.chainId) - rootStore.hex2Dec(modelData.blockNumber)).toFixed(0)).toLocaleString()
            details += qsTr("Finalised in epoch %1").arg(epoch.toFixed(0)) + endl2
            details += qsTr("Signed") + endl + root.timestampString + endl2
            details += qsTr("Confirmed") + endl
            details += LocaleUtils.formatDateTime(confirmationTimeStamp * 1000, Locale.LongFormat) + endl2
            break
        }
        case TransactionDelegate.TransactionStatus.Finished: {
            const timestampString = LocaleUtils.formatDateTime(modelData.timestamp * 1000, Locale.LongFormat)
            details += qsTr("Status") + endl
            const epoch = Math.abs(walletRootStore.getLatestBlockNumber(modelData.chainId) - rootStore.hex2Dec(modelData.blockNumber))
            details += qsTr("Finalised in epoch %1").arg(epoch.toFixed(0)) + endl2
            details += qsTr("Signed") + endl + timestampString + endl2
            details += qsTr("Confirmed") + endl
            details += LocaleUtils.formatDateTime(confirmationTimeStamp * 1000, Locale.LongFormat) + endl2
            details += qsTr("Finalised") + endl
            details += LocaleUtils.formatDateTime(finalisationTimeStamp * 1000, Locale.LongFormat) + endl2
            break
        }
        default:
            break
        }

        // SUMMARY ADRESSES
        switch (type) {
        case TransactionDelegate.Swap:
            details += qsTr("From") + endl + root.symbol + endl2
            details += qsTr("To") + endl + root.swapSymbol + endl2
            details += qsTr("In") + endl + root.fromAddress + endl2
            break
        case TransactionDelegate.Bridge:
            details += qsTr("From") + endl + root.networkName + endl2
            details += qsTr("To") + endl + root.bridgeNetworkName + endl2
            details += qsTr("In") + endl + modelData.from + endl2
            break
        default:
            details += qsTr("From") + endl + modelData.from + endl2
            details += qsTr("To") + endl + modelData.to + endl2
            break
        }
        const protocolName = "" // TODO fill protocol name for Bridge and Swap
        if (!!protocolName) {
            details += qsTr("Using") + endl + protocolName + endl2
        }
        if (!!modelData.txHash) {
            details += qsTr("%1 Tx hash").arg(root.networkName) + endl + modelData.txHash + endl2
        }
        const bridgeTxHash = "" // TODO fill tx hash for Bridge
        if (!!bridgeTxHash) {
            details += qsTr("%1 Tx hash").arg(root.bridgeNetworkName) + endl + bridgeTxHash + endl2
        }
        const protocolFromContractAddress = "" // TODO fill protocol contract address for 'from' network for Bridge and Swap
        if (!!protocolName && !!protocolFromContractAddress) {
            details += qsTr("%1 %2 contract address").arg(root.networkName).arg(protocolName) + endl
            details += protocolFromContractAddress + endl2
        }
        if (!!modelData.contract) {
            details += qsTr("%1 %2 contract address").arg(root.networkName).arg(root.symbol) + endl
            details += modelData.contract + endl2
        }
        const protocolToContractAddress = "" // TODO fill protocol contract address for 'to' network for Bridge
        if (!!protocolToContractAddress && !!protocolName) {
            details += qsTr("%1 %2 contract address").arg(root.bridgeNetworkName).arg(protocolName) + endl
            details += protocolToContractAddress + endl2
        }
        const swapContractAddress = "" // TODO fill swap contract address for Swap
        const bridgeContractAddress = "" // TODO fill token's contract address for 'to' network for Bridge
        switch (type) {
        case TransactionDelegate.Swap:
            if (!!swapContractAddress) {
                details += qsTr("%1 %2 contract address").arg(root.networkName).arg(root.swapSymbol) + endl
                details += swapContractAddress + endl2
            }
            break
        case TransactionDelegate.Bridge:
            if (!!bridgeContractAddress) {
                details += qsTr("%1 %2 contract address").arg(root.bridgeNetworkName).arg(root.symbol) + endl
                details += bridgeContractAddress + endl2
            }
            break
        default:
            break
        }

        // SUMMARY DATA
        if (type !== TransactionDelegate.Bridge) {
            details += qsTr("Network") + endl + networkName + endl2
        }
        details += qsTr("Token format") + endl + modelData.type.toUpperCase() + endl2
        details += qsTr("Nonce") + endl + rootStore.hex2Dec(modelData.nonce) + endl2
        if (type === TransactionDelegate.Bridge) {
            details += qsTr("Included in Block on %1").arg(networkName) + endl
            details += rootStore.hex2Dec(modelData.blockNumber)  + endl2
            details += qsTr("Included in Block on %1").arg(bridgeNetworkName) + endl
            const bridgeBlockNumber = 0 // TODO fill when bridge data is implemented
            details += rootStore.hex2Dec(bridgeBlockNumber)  + endl2
        } else {
            details += qsTr("Included in Block") + endl + rootStore.hex2Dec(modelData.blockNumber)  + endl2
        }

        // VALUES
        const fiatTransactionValue = rootStore.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
        const feeFiatValue = rootStore.getFiatValue(feeEthValue, "ETH", root.currentCurrency)
        let valuesString = ""
        if (!root.isNFT) {
            switch(type) {
            case TransactionDelegate.Send:
            case TransactionDelegate.Swap:
            case TransactionDelegate.Bridge:
                valuesString += qsTr("Amount sent %1 (%2)").arg(root.transactionValue).arg(fiatTransactionValue) + endl2
                break
            default:
                break
            }
            if (type === TransactionDelegate.Swap) {
                const crypto = rootStore.formatCurrencyAmount(d.swapCryptoValue, d.swapSymbol)
                const fiat = rootStore.formatCurrencyAmount(d.swapCryptoValue, d.swapSymbol)
                valuesString += qsTr("Amount received %1 (%2)").arg(crypto).arg(fiat) + endl2
            } else if (type === TransactionDelegate.Bridge) {
                // Reduce crypto value by fee value
                const valueInCrypto = rootStore.getCryptoValue(root.fiatValue - feeFiatValue, root.symbol, root.currentCurrency)
                const crypto = rootStore.formatCurrencyAmount(valueInCrypto, d.symbol)
                const fiat = rootStore.formatCurrencyAmount(root.fiatValue - feeFiatValue, root.currentCurrency)
                valuesString += qsTr("Amount received %1 (%2)").arg(crypto).arg(fiat) + endl2
            }
            switch(type) {
            case TransactionDelegate.Send:
            case TransactionDelegate.Swap:
            case TransactionDelegate.Bridge:
                const feeValue = LocaleUtils.currencyAmountToLocaleString(modelData.totalFees)
                const feeFiat = rootStore.formatCurrencyAmount(feeFiatValue, root.currentCurrency)
                valuesString += qsTr("Fees %1 (%2)").arg(feeValue).arg(feeFiat) + endl2
                break
            default:
                break
            }
        }

        if (!root.isNFT || type !== TransactionDelegate.Receive) {
            if (type === TransactionDelegate.Destroy || root.isNFT) {
                const feeCrypto = rootStore.formatCurrencyAmount(feeEthValue, "ETH")
                const feeFiat = rootStore.formatCurrencyAmount(feeFiatValue, root.currentCurrency)
                valuesString += qsTr("Fees %1 (%2)").arg(feeCrypto).arg(feeFiat) + endl2
            } else if (type === TransactionDelegate.Receive || (type === TransactionDelegate.Buy && isLayer1)) {
                valuesString += qsTr("Total %1 (%2)").arg(root.transactionValue).arg(fiatTransactionValue) + endl2
            } else {
                const feeEth = rootStore.formatCurrencyAmount(feeEthValue, "ETH")
                valuesString += qsTr("Total %1 + %2 (%3)").arg(root.transactionValue).arg(feeEth).arg(fiatTransactionValue) + endl2
            }
        }

        if (valuesString !== "") {
            const timestampString = LocaleUtils.formatDateTime(modelData.timestamp * 1000, Locale.LongFormat)
            details += qsTr("Values at %1").arg(timestampString) + endl2
            details += valuesString + endl2
        }

        // Remove locale specific number separator
        details = details.replace(/\ /, ' ')
        // Remove empty new lines at the end
        return details.replace(/[\r\n\s]*$/, '')
    }

    rightPadding: 16
    enabled: !loading
    color: sensor.containsMouse ? Theme.palette.baseColor5 : Theme.palette.statusListItem.backgroundColor

    statusListItemIcon.active: (loading || root.asset.name)
    asset {
        width: 24
        height: 24
        isImage: false
        imgIsIdenticon: true
        isLetterIdenticon: loading
        name: {
            switch(root.transactionType) {
            case Constants.TransactionType.Send:
                return "send"
            case Constants.TransactionType.Receive:
                return "receive"
            case Constants.TransactionType.Buy:
            case Constants.TransactionType.Sell:
                return "token"
            case Constants.TransactionType.Destroy:
                return "destroy"
            case Constants.TransactionType.Swap:
                return "swap"
            case Constants.TransactionType.Bridge:
                return "bridge"
            default:
                return ""
            }
        }
        bgColor: "transparent"
        color: Theme.palette.directColor1
        bgBorderWidth: 1
        bgBorderColor: Theme.palette.primaryColor3
    }

    sensor.children: [
        StatusRoundIcon {
            id: leftIconStatusIcon
            visible: !root.loading
            anchors {
                right: root.statusListItemIcon.right
                bottom: root.statusListItemIcon.bottom
            }
            asset: root.statusIconAsset
        }
    ]

    // Title
    title: {
        if (root.loading) {
            return "dummmy"
        } else if (!root.isModelDataValid) {
            return ""
        }

        const isPending = root.transactionStatus === Constants.TransactionStatus.Pending
        const failed = root.transactionStatus === Constants.TransactionStatus.Failed
        switch(root.transactionType) {
        case Constants.TransactionType.Send:
            return failed ? qsTr("Send failed") : (isPending ? qsTr("Sending") : qsTr("Sent"))
        case Constants.TransactionType.Receive:
            return failed ? qsTr("Receive failed") : (isPending ? qsTr("Receiving") : qsTr("Received"))
        case Constants.TransactionType.Buy:
            return failed ? qsTr("Buy failed") : (isPending ? qsTr("Buying") : qsTr("Bought"))
        case Constants.TransactionType.Sell:
            return failed ? qsTr("Sell failed") : (isPending ? qsTr("Selling") : qsTr("Sold"))
        case Constants.TransactionType.Destroy:
            return failed ? qsTr("Destroy failed") : (isPending ? qsTr("Destroying") : qsTr("Destroyed"))
        case Constants.TransactionType.Swap:
            return failed ? qsTr("Swap failed") : (isPending ? qsTr("Swapping") : qsTr("Swapped"))
        case Constants.TransactionType.Bridge:
            return failed ? qsTr("Bridge failed") : (isPending ? qsTr("Bridging") : qsTr("Bridged"))
        default:
            return ""
        }
    }
    statusListItemTitleArea.anchors.rightMargin: root.rightPadding
    statusListItemTitle.font.weight: Font.DemiBold
    statusListItemTitle.font.pixelSize: root.loading ? d.loadingPixelSize : d.titlePixelSize

    // title icons and date
    statusListItemTitleIcons.sourceComponent: Row {
        spacing: 8
        Row {
            visible: !root.loading
            spacing: swapTokenImage.visible ? -tokenImage.width * 0.2 : 0
            StatusRoundIcon {
                id: tokenImage
                anchors.verticalCenter: parent.verticalCenter
                asset: root.tokenIconAsset
            }
            StatusRoundIcon {
                id: swapTokenImage
                visible: !root.isNFT && !!root.swapTokenImage && root.transactionType === Constants.TransactionType.Swap
                anchors.verticalCenter: parent.verticalCenter
                asset: StatusAssetSettings {
                    width: root.tokenIconAsset.width
                    height: root.tokenIconAsset.height
                    bgWidth: width + 2
                    bgHeight: height + 2
                    bgRadius: bgWidth / 2
                    bgColor: root.color
                    isImage:root.tokenIconAsset.isImage
                    color: root.tokenIconAsset.color
                    name: root.swapTokenImage
                    isLetterIdenticon: root.tokenIconAsset.isLetterIdenticon
                }
            }
        }
        StatusTextWithLoadingState {
            anchors.verticalCenter: parent.verticalCenter
            text: root.loading ? root.title : root.timeStampText
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: root.loading ? d.loadingPixelSize : d.datePixelSize
            visible: !!text
            loading: root.loading
            customColor: Theme.palette.baseColor1
        }
    }

    // subtitle
    subTitle: {
        if (!root.isModelDataValid) {
            return ""
        }
        switch(root.transactionType) {
        case Constants.TransactionType.Receive:
            return qsTr("%1 from %2 via %3").arg(transactionValue).arg(fromAddress).arg(networkName)
        case Constants.TransactionType.Buy:
        case Constants.TransactionType.Sell:
            return qsTr("%1 on %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        case Constants.TransactionType.Destroy:
            return qsTr("%1 at %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        case Constants.TransactionType.Swap:
            return qsTr("%1 to %2 via %3").arg(transactionValue).arg(swapTransactionValue).arg(networkName)
        case Constants.TransactionType.Bridge:
            return qsTr("%1 from %2 to %3").arg(transactionValue).arg(bridgeNetworkName).arg(networkName)
        default:
            return qsTr("%1 to %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        }
    }
    statusListItemSubTitle.maximumLoadingStateWidth: 300
    statusListItemSubTitle.customColor: Theme.palette.directColor1
    statusListItemSubTitle.font.pixelSize: root.loading ? d.loadingPixelSize : d.subtitlePixelSize
    statusListItemTagsRowLayout.anchors.topMargin: 4 // Spacing between title row nad subtitle row

    // Right side components
    components: [
        Loader {
            active: !headerStatusLoader.active
            visible: active
            sourceComponent: ColumnLayout {
                StatusTextWithLoadingState {
                    id: cryptoValueText
                    text: {
                        if (root.loading) {
                            return "dummy text"
                        } else if (!root.isModelDataValid || root.isNFT) {
                            return ""
                        }

                        switch(root.transactionType) {
                        case Constants.TransactionType.Send:
                        case Constants.TransactionType.Sell:
                            return "−" + root.transactionValue
                        case Constants.TransactionType.Buy:
                        case Constants.TransactionType.Receive:
                            return "+" + root.transactionValue
                        case Constants.TransactionType.Swap:
                            return "<font color=\"%1\">-%2</font> <font color=\"%3\">/</font> <font color=\"%4\">+%5</font>"
                                          .arg(Theme.palette.directColor1)
                                          .arg(root.transactionValue)
                                          .arg(Theme.palette.baseColor1)
                                          .arg(Theme.palette.successColor1)
                                          .arg(root.swapTransactionValue)
                        case Constants.TransactionType.Bridge:
                            return "−" + root.rootStore.formatCurrencyAmount(feeCryptoValue, root.symbol)
                        default:
                            return ""
                        }
                    }
                    horizontalAlignment: Qt.AlignRight
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: root.loading ? d.loadingPixelSize : 13
                    customColor: {
                        switch(root.transactionType) {
                        case Constants.TransactionType.Receive:
                        case Constants.TransactionType.Buy:
                        case Constants.TransactionType.Swap:
                            return Theme.palette.successColor1
                        default:
                            return Theme.palette.directColor1
                        }
                    }
                    loading: root.loading
                }
                StatusTextWithLoadingState {
                    id: fiatValueText
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Qt.AlignRight
                    text: {
                        if (root.loading) {
                            return "dummy text"
                        } else if (!root.isModelDataValid || root.isNFT) {
                            return ""
                        }

                        switch(root.transactionType) {
                        case Constants.TransactionType.Send:
                        case Constants.TransactionType.Sell:
                        case Constants.TransactionType.Buy:
                            return "−" + root.rootStore.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
                        case Constants.TransactionType.Receive:
                            return "+" + root.rootStore.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
                        case Constants.TransactionType.Swap:
                            return "-%1 / +%2".arg(root.rootStore.formatCurrencyAmount(root.fiatValue, root.currentCurrency))
                                              .arg(root.rootStore.formatCurrencyAmount(root.swapFiatValue, root.currentCurrency))
                        case Constants.TransactionType.Bridge:
                            return "−" + root.rootStore.formatCurrencyAmount(root.feeFiatValue, root.currentCurrency)
                        default:
                            return ""
                        }
                    }
                    font.pixelSize: root.loading ? d.loadingPixelSize : 12
                    customColor: Theme.palette.baseColor1
                    loading: root.loading
                }
            }
        },
        Loader {
            id: headerStatusLoader
            active: false
            visible: active
            sourceComponent: Rectangle {
                id: statusRect
                width: transactionTypeIcon.width + (retryButton.visible ? retryButton.width + 5 : 0)
                height: transactionTypeIcon.height
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                radius: 100
                border {
                    width: retryButton.visible ? 1 : 0
                    color: root.asset.bgBorderColor
                }

                StatusButton {
                    id: retryButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    radius: height / 2
                    height: parent.height * 0.7
                    verticalPadding: 0
                    horizontalPadding: radius
                    textFillWidth: true
                    text: qsTr("Retry")
                    size: StatusButton.Small
                    type: StatusButton.Primary
                    visible: !root.loading && root.transactionStatus === Constants.TransactionType.Failed
                    onClicked: root.retryClicked()
                }

                StatusSmartIdenticon {
                    id: transactionTypeIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    enabled: false
                    asset: root.asset
                    active: !!root.asset.name
                    loading: root.loading
                    name: root.title
                }
                StatusRoundIcon {
                    visible: !root.loading
                    anchors {
                        right: transactionTypeIcon.right
                        bottom: transactionTypeIcon.bottom
                    }
                    asset: root.statusIconAsset
                }
            }
        }
    ]

    states: [
        State {
            name: "header"
            PropertyChanges {
                target: headerStatusLoader
                active: true
            }
            PropertyChanges {
                target: leftIconStatusIcon
                visible: false
            }
            PropertyChanges {
                target: root.statusListItemIcon
                active: false
            }
            PropertyChanges {
                target: root.asset
                bgBorderWidth: root.transactionStatus === Constants.TransactionType.Failed ? 0 : 1
                width: 34
                height: 34
                bgWidth: 56
                bgHeight: 56
            }
            PropertyChanges {
                target: root.statusIconAsset
                width: 17
                height: 17
            }
            PropertyChanges {
                target: root.tokenIconAsset
                width: 20
                height: 20
            }
            PropertyChanges {
                target: d
                titlePixelSize: 17
                datePixelSize: 13
                subtitlePixelSize: 15
                loadingPixelSize: 14
            }
        }
    ]
}
