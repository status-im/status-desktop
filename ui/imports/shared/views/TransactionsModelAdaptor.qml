import QtQml

import StatusQ
import StatusQ.Core.Utils

import utils

import QtModelsToolkit

/*!
   \qmltype TransactionsModelAdaptor
   \inqmlmodule shared.adaptors
   \since shared.adaptors 1.0
   \brief Model adaptor that computes derived transaction properties

   Wraps a transactions model with ObjectProxyModel to compute all derived
   properties at the model layer instead of per-delegate at render time.

   Includes date grouping computation (Today, Yesterday, etc.) that was
   previously in HistoryView's SortFilterProxyModel.
*/

QObject {
    id: root

    required property var sourceModel
    required property var flatNetworks
    required property string currentCurrency
    required property var getFiatValueFn
    required property var formatCurrencyAmountFn
    required property var getNameForAddressFn
    required property var getDappDetailsFn
    required property var getTransactionTypeFn
    property var getCommunityDetailsFn: null
    required property var localeUtils

    readonly property alias model: objectProxyModel

    ObjectProxyModel {
        id: objectProxyModel
        sourceModel: root.sourceModel

        delegate: QtObject {
            readonly property var activityEntry: model.activityEntry
            readonly property var modelData: model.activityEntry
            readonly property bool isModelDataValid: modelData !== undefined && !!modelData

            readonly property string date: {
                if (!isModelDataValid || modelData.timestamp === 0)
                    return ""

                const currDate = new Date()
                const timestampDate = new Date(modelData.timestamp * 1000)
                const daysDiff = root.localeUtils.daysBetween(currDate, timestampDate)
                const daysToBeginingOfThisWeek = root.localeUtils.daysTo(timestampDate, root.localeUtils.getFirstDayOfTheCurrentWeek())

                if (daysDiff < 1)
                    return qsTr("Today")
                if (daysDiff < 2)
                    return qsTr("Yesterday")
                if (daysToBeginingOfThisWeek >= 0)
                    return qsTr("Earlier this week")
                if (daysToBeginingOfThisWeek > -7)
                    return qsTr("Last week")
                if (currDate.getMonth() === timestampDate.getMonth() &&
                    currDate.getYear() === timestampDate.getYear())
                    return qsTr("Earlier this month")

                const previousMonthDate = new Date(new Date().setDate(0))
                if ((timestampDate.getMonth() === previousMonthDate.getMonth() &&
                     timestampDate.getYear() === previousMonthDate.getYear()) ||
                    (previousMonthDate.getMonth() === 11 && timestampDate.getMonth() === 0 &&
                     Math.abs(timestampDate.getYear() - previousMonthDate.getYear()) === 1))
                    return qsTr("Last month")

                return timestampDate.toLocaleDateString(Qt.locale(), "MMM yyyy")
            }

            readonly property string txID: isModelDataValid ? modelData.id : "INVALID"
            readonly property int transactionStatus: isModelDataValid ? modelData.status : Constants.TransactionStatus.Pending
            readonly property bool isMultiTransaction: isModelDataValid && modelData.isMultiTransaction
            readonly property double cryptoValue: isModelDataValid ? modelData.amount : 0.0
            readonly property double fiatValue: isModelDataValid ? root.getFiatValueFn(cryptoValue, modelData.symbol) : 0.0
            readonly property double inCryptoValue: isModelDataValid ? modelData.inAmount : 0.0
            readonly property double inFiatValue: isModelDataValid && isMultiTransaction ? root.getFiatValueFn(inCryptoValue, modelData.inSymbol) : 0.0
            readonly property double outCryptoValue: isModelDataValid ? modelData.outAmount : 0.0
            readonly property double outFiatValue: isModelDataValid && isMultiTransaction ? root.getFiatValueFn(outCryptoValue, modelData.outSymbol) : 0.0

            readonly property string networkColor: isModelDataValid ? ModelUtils.getByKey(root.flatNetworks, "chainId", modelData.chainId, "chainColor") : ""
            readonly property string networkName: isModelDataValid ? ModelUtils.getByKey(root.flatNetworks, "chainId", modelData.chainId, "chainName") : ""
            readonly property string networkNameIn: isMultiTransaction ? ModelUtils.getByKey(root.flatNetworks, "chainId", modelData.chainIdIn, "chainName") : ""
            readonly property string networkNameOut: isMultiTransaction ? ModelUtils.getByKey(root.flatNetworks, "chainId", modelData.chainIdOut, "chainName") : ""

            readonly property string addressNameTo: isModelDataValid ? root.getNameForAddressFn(modelData.recipient) : ""
            readonly property string addressNameFrom: isModelDataValid ? root.getNameForAddressFn(modelData.sender) : ""

            readonly property bool isNFT: isModelDataValid && modelData.isNFT
            readonly property string communityId: isModelDataValid && modelData.communityId ? modelData.communityId : ""
            readonly property var community: root.getCommunityDetailsFn && !!communityId ? root.getCommunityDetailsFn(communityId) : null
            readonly property bool isCommunityToken: !!community && Object.keys(community).length > 0
            readonly property string communityImage: isCommunityToken ? community.image : ""
            readonly property string communityName: isCommunityToken ? community.name : ""

            readonly property int txType: root.getTransactionTypeFn(modelData)
            readonly property bool isCommunityAssetViaAirdrop: isModelDataValid && !!communityId && txType === Constants.TransactionType.Mint

            readonly property var dAppDetails: {
                if (!isModelDataValid)
                    return null
                if (modelData.txType === Constants.TransactionType.Approve)
                    return root.getDappDetailsFn(modelData.chainId, modelData.approvalSpender)
                if (modelData.txType === Constants.TransactionType.Swap)
                    return root.getDappDetailsFn(modelData.chainId, modelData.interactedContractAddress)
                return null
            }
            readonly property string dAppIcon: dAppDetails ? dAppDetails.icon : ""
            readonly property string dAppUrl: dAppDetails ? dAppDetails.url : ""
            readonly property string dAppName: dAppDetails ? dAppDetails.name : ""

            readonly property string transactionValue: {
                if (!isModelDataValid)
                    return qsTr("N/A")
                if (isNFT) {
                    let value = ""
                    if (txType === Constants.TransactionType.Mint)
                        value += modelData.amount + " "
                    if (modelData.nftName)
                        value += modelData.nftName
                    else if (modelData.tokenID)
                        value += "#" + modelData.tokenID
                    else
                        value += qsTr("Unknown NFT")
                    return value
                }
                if (!modelData.symbol && !!modelData.tokenAddress)
                    return "%1 (%2)".arg(root.formatCurrencyAmountFn(cryptoValue, "")).arg(Utils.compactAddress(modelData.tokenAddress, 4))
                return root.formatCurrencyAmountFn(cryptoValue, modelData.symbol)
            }

            readonly property string inTransactionValue: {
                if (!isModelDataValid)
                    return qsTr("N/A")
                if (!modelData.inSymbol && !!modelData.tokenInAddress)
                    return "%1 (%2)".arg(root.formatCurrencyAmountFn(inCryptoValue, "")).arg(Utils.compactAddress(modelData.tokenInAddress, 4))
                return root.formatCurrencyAmountFn(inCryptoValue, modelData.inSymbol)
            }

            readonly property string outTransactionValue: {
                if (!isModelDataValid)
                    return qsTr("N/A")
                if (!modelData.outSymbol && !!modelData.tokenOutAddress)
                    return "%1 (%2)".arg(root.formatCurrencyAmountFn(outCryptoValue, "")).arg(Utils.compactAddress(modelData.tokenOutAddress, 4))
                return root.formatCurrencyAmountFn(outCryptoValue, modelData.outSymbol)
            }

            readonly property string tokenImage: {
                if (!isModelDataValid ||
                    txType === Constants.TransactionType.ContractDeployment ||
                    txType === Constants.TransactionType.ContractInteraction)
                    return ""
                if (isNFT)
                    return modelData.nftImageUrl ? modelData.nftImageUrl : ""
                return Constants.tokenIcon(isMultiTransaction ? txType === Constants.TransactionType.Receive ? modelData.inSymbol : modelData.outSymbol : modelData.symbol)
            }

            readonly property string inTokenImage: isModelDataValid ? Constants.tokenIcon(modelData.inSymbol) : ""

            readonly property string toAddress: !!addressNameTo ? addressNameTo : isModelDataValid ? Utils.compactAddress(modelData.recipient, 4) : ""
            readonly property string fromAddress: !!addressNameFrom ? addressNameFrom : isModelDataValid ? Utils.compactAddress(modelData.sender, 4) : ""

            readonly property string interactedContractAddress: isModelDataValid ? Utils.compactAddress(modelData.interactedContractAddress, 4) : ""
            readonly property string approvalSpender: isModelDataValid ? Utils.compactAddress(modelData.approvalSpender, 4) : ""
        }

        expectedRoles: ["activityEntry"]
        exposedRoles: [
            "activityEntry", "date", "isModelDataValid", "txID", "transactionStatus",
            "isMultiTransaction", "cryptoValue", "fiatValue", "inCryptoValue", "inFiatValue",
            "outCryptoValue", "outFiatValue", "networkColor", "networkName", "networkNameIn",
            "networkNameOut", "addressNameTo", "addressNameFrom", "isNFT",
            "isCommunityAssetViaAirdrop", "communityId", "community", "isCommunityToken",
            "communityImage", "communityName", "txType", "dAppDetails", "dAppIcon", "dAppUrl",
            "dAppName", "transactionValue", "inTransactionValue", "outTransactionValue",
            "tokenImage", "inTokenImage", "toAddress", "fromAddress",
            "interactedContractAddress", "approvalSpender"
        ]
    }
}
