import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import AppLayouts.Wallet 1.0

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
        modelData: model.activityEntry
        rootStore: RootStore
        walletRootStore: WalletStore.RootStore
        loading: isModelDataValid
    }
   \endqml

   Additional usages should be handled using states.
*/

StatusListItem {
    id: root

    signal retryClicked()

    property var modelData
    property string timeStampText: isModelDataValid ? LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000) : ""
    property bool showAllAccounts: false

    required property var rootStore
    required property var walletRootStore

    readonly property bool isModelDataValid: modelData !== undefined && !!modelData

    readonly property int transactionStatus: isModelDataValid ? modelData.status : Constants.TransactionStatus.Pending
    readonly property bool isMultiTransaction: isModelDataValid && modelData.isMultiTransaction
    readonly property string currentCurrency: rootStore.currentCurrency
    readonly property double cryptoValue: isModelDataValid ? modelData.amount : 0.0
    readonly property double fiatValue: isModelDataValid && !isMultiTransaction ? rootStore.getFiatValue(cryptoValue, modelData.symbol, currentCurrency) : 0.0
    readonly property double inCryptoValue: isModelDataValid ? modelData.inAmount : 0.0
    readonly property double inFiatValue: isModelDataValid && isMultiTransaction ? rootStore.getFiatValue(inCryptoValue, modelData.inSymbol, currentCurrency): 0.0
    readonly property double outCryptoValue: isModelDataValid ? modelData.outAmount : 0.0
    readonly property double outFiatValue: isModelDataValid && isMultiTransaction ? rootStore.getFiatValue(outCryptoValue, modelData.outSymbol, currentCurrency): 0.0
    readonly property double feeCryptoValue: 0.0 // TODO fill when bridge data is implemented
    readonly property double feeFiatValue: 0.0 // TODO fill when bridge data is implemented
    readonly property string networkColor: isModelDataValid ? rootStore.getNetworkColor(modelData.chainId) : ""
    readonly property string networkName: isModelDataValid ? rootStore.getNetworkFullName(modelData.chainId) : ""
    readonly property string networkNameIn: isMultiTransaction ? rootStore.getNetworkFullName(modelData.chainIdIn) : ""
    readonly property string networkNameOut: isMultiTransaction ? rootStore.getNetworkFullName(modelData.chainIdOut) : ""
    readonly property string addressNameTo: isModelDataValid ? walletRootStore.getNameForAddress(modelData.recipient) : ""
    readonly property string addressNameFrom: isModelDataValid ? walletRootStore.getNameForAddress(modelData.sender) : ""
    readonly property bool isNFT: isModelDataValid && modelData.isNFT

    readonly property string transactionValue: {
        if (!isModelDataValid) {
            return qsTr("N/A")
        } else if (root.isNFT) {
            return modelData.nftName ? modelData.nftName : "#" + modelData.tokenID
        } else if (!modelData.symbol && !!modelData.tokenAddress) {
            return "%1 (%2)".arg(root.rootStore.formatCurrencyAmount(cryptoValue, "")).arg(Utils.compactAddress(modelData.tokenAddress, 4))
        }
        return root.rootStore.formatCurrencyAmount(cryptoValue, modelData.symbol)
    }

    readonly property string inTransactionValue: {
        if (!isModelDataValid || !isMultiTransaction) {
            return qsTr("N/A")
        } else if (!modelData.inSymbol && !!modelData.tokenInAddress) {
            return "%1 (%2)".arg(root.rootStore.formatCurrencyAmount(inCryptoValue, "")).arg(Utils.compactAddress(modelData.tokenInAddress, 4))
        }
        return rootStore.formatCurrencyAmount(inCryptoValue, modelData.inSymbol)
    }
    readonly property string outTransactionValue: {
        if (!isModelDataValid || !isMultiTransaction) {
            return qsTr("N/A")
        } else if (!modelData.outSymbol && !!modelData.tokenOutAddress) {
            return "%1 (%2)".arg(root.rootStore.formatCurrencyAmount(outCryptoValue, "")).arg(Utils.compactAddress(modelData.tokenOutAddress, 4))
        }
        return rootStore.formatCurrencyAmount(outCryptoValue, modelData.outSymbol)
    }

    readonly property string tokenImage: {
        if (!isModelDataValid || modelData.txType === Constants.TransactionType.ContractDeployment)
            return ""
        if (root.isNFT) {
            return modelData.nftImageUrl ? modelData.nftImageUrl : ""
        } else {
            return Constants.tokenIcon(isMultiTransaction ? modelData.outSymbol : modelData.symbol)
        }
    }

    readonly property string inTokenImage: isModelDataValid ? Constants.tokenIcon(modelData.inSymbol) : ""

    readonly property string toAddress: !!addressNameTo ?
                                            addressNameTo :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.recipient, 4) :
                                                ""

    readonly property string fromAddress: !!addressNameFrom ?
                                            addressNameFrom :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.sender, 4) :
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
                return Style.svg("transaction/confirmed")
            case Constants.TransactionStatus.Finalised:
                return Style.svg("transaction/finished")
            case Constants.TransactionStatus.Failed:
                return Style.svg("transaction/failed")
            default:
                return ""
            }
        }
    }

    property StatusAssetSettings tokenIconAsset: StatusAssetSettings {
        width: 20
        height: 20
        bgWidth: width + 2
        bgHeight: height + 2
        bgRadius: bgWidth / 2
        bgColor: Style.current.name === Constants.lightThemeName && Constants.isDefaultTokenIcon(root.tokenImage) ?
                     Theme.palette.white : "transparent"
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
        property bool showRetryButton: false
    }

    function getDetailsString(detailsObj) {
        if (!detailsObj) {
            rootStore.fetchTxDetails(index)
            detailsObj = rootStore.getTxDetails()
        }

        let details = ""
        const endl = "\n"
        const endl2 = endl + endl
        const type = modelData.txType
        const feeEthValue = rootStore.getGasEthValue(detailsObj.totalFees.amount, 1)

        // TITLE
        switch (type) {
        case Constants.TransactionType.Send:
            details += qsTr("Send transaction details" + endl2)
            break
        case Constants.TransactionType.Receive:
            details += qsTr("Receive transaction details") + endl2
            break
        case Constants.TransactionType.Buy:
            details += qsTr("Buy transaction details") + endl2
            break
        case Constants.TransactionType.Sell:
            details += qsTr("Sell transaction details") + endl2
            break
        case Constants.TransactionType.Destroy:
            details += qsTr("Destroy transaction details") + endl2
            break
        case Constants.TransactionType.Swap:
            details += qsTr("Swap transaction details") + endl2
            break
        case Constants.TransactionType.Bridge:
            details += qsTr("Bridge transaction details") + endl2
            break
        case Constants.TransactionType.ContractDeployment:
            details += qsTr("Contract deployment details") + endl2
            break
        case Constants.TransactionType.Mint:
            if (isNFT)
                details += qsTr("Mint collectible details") + endl2
            else
                details += qsTr("Mint token details") + endl2
            break
        default:
            break
        }

        details += qsTr("Summary") + endl
        switch(modelData.txType) {
        case Constants.TransactionType.Buy:
        case Constants.TransactionType.Sell:
        case Constants.TransactionType.Destroy:
        case Constants.TransactionType.Swap:
        case Constants.TransactionType.Bridge:
        case Constants.TransactionType.ContractDeployment:
        case Constants.TransactionType.Mint:
            details += getSubtitle(true) + endl2
            break
        default:
            details += qsTr("%1 from %2 to %3 via %4").arg(transactionValue).arg(fromAddress).arg(toAddress).arg(networkName) + endl2
            break
        }

        if (root.isNFT) {
            details += qsTr("Token ID") + endl + modelData.tokenID + endl2
            if (!!modelData.nftName) {
                details += qsTr("Token name") + endl + modelData.nftName + endl2
            }
        }

        // PROGRESS
        const networkLayer = rootStore.getNetworkLayer(modelData.chainId)

        const isBridge = type === Constants.TransactionType.Bridge
        switch(transactionStatus) {
        case Constants.TransactionStatus.Pending:
            details += qsTr("Status") + endl
            details += qsTr("Pending on %1").arg(root.networkName) + endl2
            if (isBridge) {
                details += qsTr("Pending on %1").arg(root.networkNameIn) + endl2
            }
            break
        case Constants.TransactionStatus.Failed:
            details += qsTr("Status") + endl
            details += qsTr("Failed on %1").arg(root.networkName) + endl2
            if (isBridge) {
                details += qsTr("Failed on %1").arg(root.networkNameIn) + endl2
            }
            break
        case Constants.TransactionStatus.Complete: {
            const confirmationTimeStamp = WalletUtils.calculateConfirmationTimestamp(networkLayer, modelData.timestamp)
            const timestampString = LocaleUtils.formatDateTime(modelData.timestamp * 1000, Locale.LongFormat)
            details += qsTr("Status") + endl
            details += qsTr("Signed on %1").arg(root.networkName) + endl + timestampString + endl2
            details += qsTr("Confirmed on %1").arg(root.networkName) + endl
            details += LocaleUtils.formatDateTime(confirmationTimeStamp * 1000, Locale.LongFormat) + endl2
            if (isBridge) {
                const networkInLayer = rootStore.getNetworkLayer(modelData.chainIdIn)
                const confirmationTimeStampIn = WalletUtils.calculateConfirmationTimestamp(networkInLayer, modelData.timestamp)
                details += qsTr("Signed on %1").arg(root.networkNameIn) + endl + timestampString + endl2
                details += qsTr("Confirmed on %1").arg(root.networkNameIn) + endl
                details += LocaleUtils.formatDateTime(confirmationTimeStampIn * 1000, Locale.LongFormat) + endl2
            }
            break
        }
        case Constants.TransactionStatus.Finalised: {
            const timestampString = LocaleUtils.formatDateTime(modelData.timestamp * 1000, Locale.LongFormat)
            const confirmationTimeStamp = WalletUtils.calculateConfirmationTimestamp(networkLayer, modelData.timestamp)
            const finalisationTimeStamp = WalletUtils.calculateFinalisationTimestamp(networkLayer, modelData.timestamp)
            details += qsTr("Status") + endl
            const epoch = Math.abs(walletRootStore.getEstimatedLatestBlockNumber(modelData.chainId) - detailsObj.blockNumberOut)
            details += qsTr("Finalised in epoch %1 on %2").arg(epoch.toFixed(0)).arg(root.networkName) + endl2
            details += qsTr("Signed on %1").arg(root.networkName) + endl + timestampString + endl2
            details += qsTr("Confirmed on %1").arg(root.networkName) + endl
            details += LocaleUtils.formatDateTime(confirmationTimeStamp * 1000, Locale.LongFormat) + endl2
            details += qsTr("Finalised on %1").arg(root.networkName) + endl
            details += LocaleUtils.formatDateTime(finalisationTimeStamp * 1000, Locale.LongFormat) + endl2
            if (isBridge) {
                const networkInLayer = rootStore.getNetworkLayer(modelData.chainIdIn)
                const confirmationTimeStampIn = WalletUtils.calculateConfirmationTimestamp(networkInLayer, modelData.timestamp)
                const finalisationTimeStampIn = WalletUtils.calculateFinalisationTimestamp(networkInLayer, modelData.timestamp)
                const epochIn = Math.abs(walletRootStore.getEstimatedLatestBlockNumber(modelData.chainIdIn) - detailsObj.blockNumberIn)
                details += qsTr("Finalised in epoch %1 on %2").arg(epochIn.toFixed(0)).arg(root.networkNameIn) + endl2
                details += qsTr("Signed on %1").arg(root.networkNameIn) + endl + timestampString + endl2
                details += qsTr("Confirmed on %1").arg(root.networkNameIn) + endl
                details += LocaleUtils.formatDateTime(confirmationTimeStampIn * 1000, Locale.LongFormat) + endl2
                details += qsTr("Finalised on %1").arg(root.networkNameIn) + endl
                details += LocaleUtils.formatDateTime(finalisationTimeStampIn * 1000, Locale.LongFormat) + endl2
            }

            break
        }
        default:
            break
        }

        // SUMMARY ADRESSES
        switch (type) {
        case Constants.TransactionType.Swap:
            details += qsTr("From") + endl + modelData.outSymbol + endl2
            details += qsTr("To") + endl + modelData.inSymbol + endl2
            details += qsTr("In") + endl + modelData.sender + endl2
            break
        case Constants.TransactionType.Bridge:
            details += qsTr("From") + endl + networkNameOut + endl2
            details += qsTr("To") + endl + networkNameIn + endl2
            details += qsTr("In") + endl + modelData.sender + endl2
            break
        case Constants.TransactionType.ContractDeployment:
            details += qsTr("From") + endl + modelData.sender + endl2
            const failed = root.transactionStatus === Constants.TransactionStatus.Failed
            const isPending = root.transactionStatus === Constants.TransactionStatus.Pending || !modelData.contract
            if (failed) {
                details += qsTr("To\nContract address not created")
            } else if (isPending) {
                details += qsTr("To\nAwaiting contract address...")
            } else {
                details += qsTr("To\nContract created") + endl + modelData.contract + endl2
            }
            break
        default:
            details += qsTr("From") + endl + modelData.sender + endl2
            details += qsTr("To") + endl + modelData.recipient + endl2
            break
        }
        if (!!detailsObj.protocol) {
            details += qsTr("Using") + endl + detailsObj.protocol + endl2
        }
        if (root.isMultiTransaction) {
            if (!!detailsObj.txHashOut) {
                details += qsTr("%1 Tx hash").arg(root.networkNameOut) + endl + detailsObj.txHashOut + endl2
            }
            if (!!detailsObj.txHashIn) {
                details += qsTr("%1 Tx hash").arg(root.networkNameIn) + endl + detailsObj.txHashIn + endl2
            }
        } else if (!!detailsObj.txHash) {
            details += qsTr("%1 Tx hash").arg(root.networkName) + endl + detailsObj.txHash + endl2
        }

        const protocolFromContractAddress = "" // TODO fill protocol contract address for 'from' network for Bridge and Swap
        if (!!detailsObj.protocol && !!protocolFromContractAddress) {
            details += qsTr("%1 %2 contract address").arg(root.networkName).arg(detailsObj.protocol) + endl
            details += protocolFromContractAddress + endl2
        }
        if (!!detailsObj.contract && type !== Constants.TransactionType.ContractDeployment && !/0x0+$/.test(detailsObj.contract)) {
            let symbol = !!modelData.symbol || !modelData.tokenAddress ? modelData.symbol : "(%1)".arg(Utils.compactAddress(modelData.tokenAddress, 4))
            details += qsTr("%1 %2 contract address").arg(root.networkName).arg(symbol) + endl
            details += detailsObj.contract + endl2
        }
        const protocolToContractAddress = "" // TODO fill protocol contract address for 'to' network for Bridge
        if (!!protocolToContractAddress && !!detailsObj.protocol) {
            details += qsTr("%1 %2 contract address").arg(networkNameOut).arg(detailsObj.protocol) + endl
            details += protocolToContractAddress + endl2
        }
        switch (type) {
        case Constants.TransactionType.Swap:
            if (!!detailsObj.contractOut) {
                details += qsTr("%1 %2 contract address").arg(root.networkName).arg(modelData.toSymbol) + endl
                details += detailsObj.contractOut + endl2
            }
            break
        case Constants.TransactionType.Bridge:
            if (!!detailsObj.contractOut) {
                details += qsTr("%1 %2 contract address").arg(networkNameOut).arg(modelData.symbol) + endl
                details += detailsObj.contractOut + endl2
            }
            break
        default:
            break
        }

        // SUMMARY DATA
        if (type !== Constants.TransactionType.Bridge) {
            details += qsTr("Network") + endl + networkName + endl2
        }
        if (!!detailsObj.tokenType) {
            details += qsTr("Token format") + endl + detailsObj.tokenType.toUpperCase() + endl2
        }
        details += qsTr("Nonce") + endl + detailsObj.nonce + endl2
        if (type === Constants.TransactionType.Bridge) {
            details += qsTr("Included in Block on %1").arg(networkNameOut) + endl
            details += detailsObj.blockNumberOut  + endl2
            if (detailsObj.blockNumberIn > 0) {
                details += qsTr("Included in Block on %1").arg(networkNameIn) + endl
                details += detailsObj.blockNumberIn + endl2
            }
        } else {
            details += qsTr("Included in Block") + endl + detailsObj.blockNumberOut  + endl2
        }

        // VALUES
        const fiatTransactionValue = rootStore.formatCurrencyAmount(isMultiTransaction ? root.outFiatValue : root.fiatValue, root.currentCurrency)
        const feeFiatValue = rootStore.getFiatValue(feeEthValue, "ETH", root.currentCurrency)
        let valuesString = ""
        if (!root.isNFT) {
            switch(type) {
            case Constants.TransactionType.Send:
                valuesString += qsTr("Amount sent %1 (%2)").arg(root.transactionValue).arg(fiatTransactionValue) + endl2
                break
            case Constants.TransactionType.Swap:
            case Constants.TransactionType.Bridge:
                valuesString += qsTr("Amount sent %1 (%2)").arg(root.outTransactionValue).arg(fiatTransactionValue) + endl2
                break
            default:
                break
            }
            if (type === Constants.TransactionType.Swap) {
                const crypto = rootStore.formatCurrencyAmount(root.inCryptoValue, modelData.inSymbol)
                const fiat = rootStore.formatCurrencyAmount(root.inCryptoValue, modelData.inSymbol)
                valuesString += qsTr("Amount received %1 (%2)").arg(crypto).arg(fiat) + endl2
            } else if (type === Constants.TransactionType.Bridge) {
                // Reduce crypto value by fee value
                const valueInCrypto = rootStore.getCryptoValue(root.fiatValue - feeFiatValue, modelData.inSymbol, root.currentCurrency)
                const crypto = rootStore.formatCurrencyAmount(valueInCrypto, modelData.inSymbol)
                const fiat = rootStore.formatCurrencyAmount(root.fiatValue - feeFiatValue, root.currentCurrency)
                valuesString += qsTr("Amount received %1 (%2)").arg(crypto).arg(fiat) + endl2
            }
            switch(type) {
            case Constants.TransactionType.Send:
            case Constants.TransactionType.Swap:
            case Constants.TransactionType.Bridge:
                const feeValue = LocaleUtils.currencyAmountToLocaleString(detailsObj.totalFees)
                const feeFiat = rootStore.formatCurrencyAmount(feeFiatValue, root.currentCurrency)
                valuesString += qsTr("Fees %1 (%2)").arg(feeValue).arg(feeFiat) + endl2
                break
            default:
                break
            }
        }

        if (!root.isNFT || type !== Constants.TransactionType.Receive) {
            if (type === Constants.TransactionType.Destroy || root.isNFT) {
                const feeCrypto = rootStore.formatCurrencyAmount(feeEthValue, "ETH")
                const feeFiat = rootStore.formatCurrencyAmount(feeFiatValue, root.currentCurrency)
                valuesString += qsTr("Fees %1 (%2)").arg(feeCrypto).arg(feeFiat) + endl2
            } else if (type === Constants.TransactionType.Receive || (type === Constants.TransactionType.Buy && networkLayer === 1)) {
                valuesString += qsTr("Total %1 (%2)").arg(root.transactionValue).arg(fiatTransactionValue) + endl2
            } else if (type === Constants.TransactionType.ContractDeployment) {
                const isPending = root.transactionStatus === Constants.TransactionStatus.Pending
                if (isPending) {
                    const maxFeeEthValue = rootStore.getFeeEthValue(detailsObj.maxTotalFees.amount)
                    const maxFeeCrypto = rootStore.formatCurrencyAmount(maxFeeEthValue, "ETH")
                    const maxFeeFiat = rootStore.formatCurrencyAmount(maxFeeCrypto, root.currentCurrency)
                    valuesString += qsTr("Estimated max fee %1 (%2)").arg(maxFeeCrypto).arg(maxFeeFiat) + endl2
                } else {
                    const feeCrypto = rootStore.formatCurrencyAmount(feeEthValue, "ETH")
                    const feeFiat = rootStore.formatCurrencyAmount(feeFiatValue, root.currentCurrency)
                    valuesString += qsTr("Fees %1 (%2)").arg(feeCrypto).arg(feeFiat) + endl2
                }
            } else {
                const feeEth = rootStore.formatCurrencyAmount(feeEthValue, "ETH")
                const txValue = isMultiTransaction ? root.inTransactionValue : root.transactionValue
                valuesString += qsTr("Total %1 + %2 (%3)").arg(txValue).arg(feeEth).arg(fiatTransactionValue) + endl2
            }
        }

        if (valuesString !== "") {
            const timestampString = LocaleUtils.formatDateTime(modelData.timestamp * 1000, Locale.LongFormat)
            details += qsTr("Values at %1").arg(timestampString) + endl2
            details += valuesString + endl2
        }

        // Remove no-break space
        details = details.replace(/[\xA0]/g, " ");
        // Remove empty new lines at the end
        return details.replace(/[\r\n\s]*$/, '')
    }

    function getSubtitle(allAccounts) {
        switch(modelData.txType) {
        case Constants.TransactionType.Receive:
            if (allAccounts)
                return qsTr("%1 from %2 to %3 via %4").arg(transactionValue).arg(fromAddress).arg(toAddress).arg(networkName)
            return qsTr("%1 from %2 via %3").arg(transactionValue).arg(fromAddress).arg(networkName)
        case Constants.TransactionType.Buy:
            let protocol = "" // TODO fill data for buy
            if (allAccounts)
                return qsTr("%1 on %2 via %3 in %4").arg(transactionValue).arg(protocol).arg(networkName).arg(toAddress)
            return qsTr("%1 on %2 via %3").arg(transactionValue).arg(protocol).arg(networkName)
        case Constants.TransactionType.Destroy:
            if (allAccounts)
                return qsTr("%1 at %2 via %3 in %4").arg(inTransactionValue).arg(toAddress).arg(networkName).arg(toAddress)
            return qsTr("%1 at %2 via %3").arg(inTransactionValue).arg(toAddress).arg(networkName)
        case Constants.TransactionType.Swap:
            if (allAccounts)
                return qsTr("%1 to %2 via %3 in %4").arg(outTransactionValue).arg(inTransactionValue).arg(networkName).arg(fromAddress)
            return qsTr("%1 to %2 via %3").arg(outTransactionValue).arg(inTransactionValue).arg(networkName)
        case Constants.TransactionType.Bridge:
            if (allAccounts)
                return qsTr("%1 from %2 to %3 in %4").arg(inTransactionValue).arg(networkNameOut).arg(networkNameIn).arg(fromAddress)
            return qsTr("%1 from %2 to %3").arg(inTransactionValue).arg(networkNameOut).arg(networkNameIn)
        case Constants.TransactionType.ContractDeployment:
            const name = addressNameTo || addressNameFrom
            return qsTr("Via %1 on %2").arg(name).arg(networkName)
        case Constants.TransactionType.Mint:
            if (allAccounts)
                return qsTr("%1 via %2 in %3").arg(transactionValue).arg(networkName).arg(toAddress)
            return qsTr("%1 via %2").arg(transactionValue).arg(networkName)
        default:
            if (allAccounts)
                return qsTr("%1 from %2 to %3 via %4").arg(transactionValue).arg(fromAddress).arg(toAddress).arg(networkName)
            return qsTr("%1 to %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        }
    }

    rightPadding: 16
    enabled: !loading
    loading: !isModelDataValid
    color: sensor.containsMouse ? Theme.palette.baseColor5 : Style.current.transparent

    statusListItemIcon.active: (loading || root.asset.name)
    asset {
        width: 24
        height: 24
        isImage: false
        imgIsIdenticon: true
        isLetterIdenticon: loading
        name: {
            if (!root.isModelDataValid)
                return ""

            switch(modelData.txType) {
            case Constants.TransactionType.Send:
                return "send"
            case Constants.TransactionType.Receive:
                return "receive"
            case Constants.TransactionType.Buy:
            case Constants.TransactionType.Sell:
            case Constants.TransactionType.Mint:
                return "token"
            case Constants.TransactionType.Destroy:
                return "destroy"
            case Constants.TransactionType.Swap:
                return "swap"
            case Constants.TransactionType.Bridge:
                return "bridge"
            case Constants.TransactionType.ContractDeployment:
                return "contract_deploy"
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
        switch(modelData.txType) {
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
        case Constants.TransactionType.ContractDeployment:
            return failed ? qsTr("Contract deployment failed") : (isPending ? qsTr("Deploying contract") : qsTr("Contract deployed"))
        case Constants.TransactionType.Mint:
            if (isNFT)
                return failed ? qsTr("Collectible minting failed") : (isPending ? qsTr("Minting collectible") : qsTr("Collectible minted"))
            return failed ? qsTr("Token minting failed") : (isPending ? qsTr("Minting token") : qsTr("Token minted"))
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
            id: tokenImagesRow
            visible: !root.loading && !!root.tokenIconAsset.name
            spacing: secondTokenImage.visible ? -tokenImage.width * 0.2 : 0
            StatusRoundIcon {
                id: tokenImage
                anchors.verticalCenter: parent.verticalCenter
                asset: root.tokenIconAsset
            }
            StatusRoundIcon {
                id: secondTokenImage
                visible: root.isModelDataValid && !root.isNFT && !!root.inTokenImage && modelData.txType === Constants.TransactionType.Swap
                anchors.verticalCenter: parent.verticalCenter
                asset: StatusAssetSettings {
                    width: root.tokenIconAsset.width
                    height: root.tokenIconAsset.height
                    bgWidth: width + 2
                    bgHeight: height + 2
                    bgRadius: bgWidth / 2
                    bgColor: Theme.palette.white
                    isImage:root.tokenIconAsset.isImage
                    color: root.tokenIconAsset.color
                    name: root.inTokenImage
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
            leftPadding: tokenImagesRow.visible ? 0 : parent.spacing
        }
    }

    // subtitle
    subTitle: {
        if (root.loading) {
            return "dummy text dummy text dummy text dummy text dummy text dummy text"
        }

        if (!root.isModelDataValid) {
            return ""
        }

        return getSubtitle(root.showAllAccounts)
    }
    statusListItemSubTitle.maximumLoadingStateWidth: 400
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

                        switch(modelData.txType) {
                        case Constants.TransactionType.Send:
                        case Constants.TransactionType.Sell:
                            return "−" + root.transactionValue
                        case Constants.TransactionType.Buy:
                        case Constants.TransactionType.Receive:
                            return "+" + root.transactionValue
                        case Constants.TransactionType.Swap:
                            let outValue = root.outTransactionValue
                            outValue = outValue.replace('<', '&lt;')
                            let inValue = root.inTransactionValue
                            inValue = inValue.replace('<', '&lt;')
                            return "<font color=\"%1\">-%2</font> <font color=\"%3\">/</font> <font color=\"%4\">+%5</font>"
                                          .arg(Theme.palette.directColor1)
                                          .arg(outValue)
                                          .arg(Theme.palette.baseColor1)
                                          .arg(Theme.palette.successColor1)
                                          .arg(inValue)
                        case Constants.TransactionType.Bridge:
                            return "−" + root.rootStore.formatCurrencyAmount(feeCryptoValue, modelData.symbol)
                        default:
                            return ""
                        }
                    }
                    horizontalAlignment: Qt.AlignRight
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: root.loading ? d.loadingPixelSize : 13
                    customColor: {
                        if (!root.isModelDataValid)
                            return ""

                        switch(modelData.txType) {
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
                        } else if (!root.isModelDataValid || root.isNFT || !modelData.symbol) {
                            return ""
                        }

                        switch(modelData.txType) {
                        case Constants.TransactionType.Send:
                        case Constants.TransactionType.Sell:
                        case Constants.TransactionType.Buy:
                            return "−" + root.rootStore.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
                        case Constants.TransactionType.Receive:
                            return "+" + root.rootStore.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
                        case Constants.TransactionType.Swap:
                            return "-%1 / +%2".arg(root.rootStore.formatCurrencyAmount(root.outFiatValue, root.currentCurrency))
                                              .arg(root.rootStore.formatCurrencyAmount(root.inFiatValue, root.currentCurrency))
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
                    text: qsTr("Retry")
                    size: StatusButton.Small
                    type: StatusButton.Primary
                    visible: d.showRetryButton
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
                bgBorderWidth: d.showRetryButton ? 0 : 1
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
                target: d
                titlePixelSize: 17
                datePixelSize: 13
                subtitlePixelSize: 15
                loadingPixelSize: 14
                showRetryButton: (!root.loading && root.transactionStatus === Constants.TransactionStatus.Failed && walletRootStore.isOwnedAccount(modelData.sender))
            }
        }
    ]
}
