import QtQuick 2.15

import Models 1.0
import utils 1.0
import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import shared.stores 1.0
import SortFilterProxyModel 0.2

import AppLayouts.Wallet.stores 1.0

QtObject {
    id: root

    readonly property CurrenciesStore currencyStore: CurrenciesStore {}
    readonly property var senderAccounts: WalletSendAccountsModel {
        Component.onCompleted: selectedSenderAccount = senderAccounts.get(0)
    }
    property var accounts: senderAccounts

    property WalletAssetsStore walletAssetStore

    property QtObject tmpActivityController: QtObject {
        property ListModel model: ListModel{}
    }

    property var flatNetworksModel: NetworksModel.flatNetworks
    property var fromNetworksModel: NetworksModel.sendFromNetworks
    property var toNetworksModel: NetworksModel.sendToNetworks
    property var selectedSenderAccount: senderAccounts.get(0)
    readonly property QtObject collectiblesModel: ManageCollectiblesModel {}
    readonly property QtObject nestedCollectiblesModel: WalletNestedCollectiblesModel {}

    readonly property QtObject walletSectionSendInst: QtObject {
        signal transactionSent(var chainId, var txHash, var uuid, var error)
        signal suggestedRoutesReady(var txRoutes)
    }
    readonly property QtObject mainModuleInst: QtObject {
        signal resolvedENS(var resolvedPubKey, var resolvedAddress, var uuid)
    }

    property string selectedAssetKey
    property bool showUnPreferredChains: false
    property int sendType: Constants.SendType.Transfer
    property string selectedRecipient

    readonly property var savedAddressesModel: ListModel {
        Component.onCompleted: {
            for (let i = 0; i < 10; i++)
                append({
                           name: "some saved addr name " + i,
                           ens: [],
                           address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4",
                           chainShortNames: "eth:arb1"
                       })
        }
    }

    function splitAndFormatAddressPrefix(textAddrss, updateInStore) {
        return textAddrss
    }

    function resolveENS() {
        return ""
    }

    function getAsset(assetsList, symbol) {
        const idx = SQUtils.ModelUtils.indexOf(assetsList, "symbol", symbol)
        if (idx < 0) {
            return {}
        }
        return SQUtils.ModelUtils.get(assetsList, idx)
    }

    function getCollectible(uid) {
        const idx = SQUtils.ModelUtils.indexOf(collectiblesModel, "uid", uid)
        if (idx < 0) {
            return {}
        }
        return SQUtils.ModelUtils.get(collectiblesModel, idx)
    }

    function getSelectorCollectible(uid) {
        const idx = SQUtils.ModelUtils.indexOf(nestedCollectiblesModel, "uid", uid)
        if (idx < 0) {
            return {}
        }
        return SQUtils.ModelUtils.get(nestedCollectiblesModel, idx)
    }

    function getHolding(holdingId, holdingType) {
        if (holdingType === Constants.TokenType.ERC20) {
            return getAsset(processedAssetsModel, holdingId)
        } else if (holdingType === Constants.TokenType.ERC721) {
            return getCollectible(holdingId)
        } else {
            return {}
        }
    }

    function getSelectorHolding(holdingId, holdingType) {
        if (holdingType === Constants.TokenType.ERC20) {
            return getAsset(processedAssetsModel, holdingId)
        } else if (holdingType === Constants.TokenType.ERC721) {
            return getSelectorCollectible(holdingId)
        } else {
            return {}
        }
    }

    function assetToSelectorAsset(asset) {
        return asset
    }

    function collectibleToSelectorCollectible(collectible) {
        return {
            uid: collectible.uid,
            chainId: collectible.chainId,
            name: collectible.name,
            iconUrl: collectible.imageUrl,
            collectionUid: collectible.collectionUid,
            collectionName: collectible.collectionName,
            isCollection: false
        }
    }

    function holdingToSelectorHolding(holding, holdingType) {
        if (holdingType === Constants.TokenType.ERC20) {
            return assetToSelectorAsset(holding)
        } else if (holdingType === Constants.TokenType.ERC721) {
            return collectibleToSelectorCollectible(holding)
        } else {
            return {}
        }
    }

    readonly property string currentCurrency: "USD"

    function getAllNetworksSupportedString() {
        return "OPT"
    }

    function plainText(text) {
        return text
    }

    function prepareTransactionsForAddress(address) {
        console.log("prepareTransactionsForAddress:", address)
    }

    function getTransactions() {
        return transactions
    }

    readonly property var transactions_: ListModel {
        id: transactions

        Component.onCompleted: {
            for (let i = 0; i < 10; i++)
                append({
                           to: "to",
                           loadingTransaction: false,
                           value: {
                               displayDecimals: true,
                               stripTrailingZeroes: true,
                               amount: 3.234
                           },
                           timestamp: new Date()
                       })
        }
    }

    function switchSenderAccount(index) {
        selectedSenderAccount = senderAccounts.get(index)
    }

    function getNetworkShortNames(chainIds) {
        return ""
    }

    function getShortChainIds(chainIds) {
        let listOfChains = chainIds.split(":")
        let listOfChainIds = []
        for (let k =0;k<listOfChains.length;k++) {
            listOfChainIds.push(SQUtils.ModelUtils.getByKey(NetworksModel.flatNetworks, "shortName", listOfChains[k], "chainId"))
        }
        return listOfChainIds
    }

    function setSendType(sendType) {
        root.sendType = sendType
    }

    function setSelectedRecipient(recipientAddress) {
        root.selectedRecipient = recipientAddress
    }

    function setSelectedAssetKey(assetsKey) {
       root.selectedAssetKey = assetsKey
    }

    function getWei2Eth(wei, decimals) {
        return wei/(10**decimals)
    }

    function updateRoutePreferredChains(chainIds) {
        root.toNetworksModel.updateRoutePreferredChains(chainIds)
    }

    function toggleShowUnPreferredChains() {
        root.showUnPreferredChains = !root.showUnPreferredChains
    }

    property string amountToSend
    property bool suggestedRoutesCalled: false
    function suggestedRoutes(amount) {
        root.amountToSend = amount
        root.suggestedRoutesCalled = true
    }

    enum EstimatedTime {
        Unknown = 0,
        LessThanOneMin,
        LessThanThreeMins,
        LessThanFiveMins,
        MoreThanFiveMins
    }

    function getLabelForEstimatedTxTime(estimatedFlag) {
        switch(estimatedFlag) {
        case TransactionStore.EstimatedTime.Unknown:
            return qsTr("~ Unknown")
        case TransactionStore.EstimatedTime.LessThanOneMin :
            return qsTr("< 1 minute")
        case TransactionStore.EstimatedTime.LessThanThreeMins :
            return qsTr("< 3 minutes")
        case TransactionStore.EstimatedTime.LessThanFiveMins:
            return qsTr("< 5 minutes")
        default:
            return qsTr("> 5 minutes")
        }
    }

    function resetStoredProperties() {
        root.amountToSend = ""
        root.sendType = Constants.SendType.Transfer
        root.selectedRecipient = ""
        root.selectedAssetKey = ""
        root.showUnPreferredChains = false
        root.fromNetworksModel.reset()
        root.toNetworksModel.reset()
    }

    function getNetworkName(chainId) {
        return SQUtils.ModelUtils.getByKey(NetworksModel.flatNetworks, "chainId", chainId, "chainName")
    }

    function formatCurrencyAmountFromBigInt(balance, symbol, decimals) {
        let bigIntBalance = SQUtils.AmountsArithmetic.fromString(balance)
        let decimalBalance = SQUtils.AmountsArithmetic.toNumber(bigIntBalance, decimals)
        return currencyStore.formatCurrencyAmount(decimalBalance, symbol)
    }

    // Property and methods below are used to apply advanced token management settings to the SendModal
    property bool showCommunityAssetsInSend: true
    property bool balanceThresholdEnabled: true
    property real balanceThresholdAmount

    // Property set from TokenLIstView and HoldingSelector to search token by name, symbol or contract address
    property string assetSearchString

    // Model prepared to provide filtered and sorted assets as per the advanced Settings in token management
    property var processedAssetsModel: SortFilterProxyModel {
        sourceModel: walletAssetStore.groupedAccountAssetsModel
        proxyRoles: [
            FastExpressionRole {
                name: "isCommunityAsset"
                expression: !!model.communityId
                expectedRoles: ["communityId"]
            },
            FastExpressionRole {
                name: "currentBalance"
                expression: __getTotalBalance(model.balances, model.decimals)
                expectedRoles: ["balances", "decimals", "symbol"]
            },
            FastExpressionRole {
                name: "currentCurrencyBalance"
                expression: {
                    if (!!model.marketDetails) {
                        return model.currentBalance * model.marketDetails.currencyPrice.amount
                    }
                    return 0
                }
                expectedRoles: ["marketDetails", "currentBalance"]
            }
        ]
        filters: [
            FastExpressionFilter {
                function search(symbol, name, addressPerChain, searchString) {
                    return (
                        symbol.startsWith(searchString.toUpperCase()) ||
                                name.toUpperCase().startsWith(searchString.toUpperCase()) || __searchAddressInList(addressPerChain, searchString)
                    )
                }
                expression: search(model.symbol, model.name, model.addressPerChain, root.assetSearchString)
                expectedRoles: ["symbol", "name", "addressPerChain"]
            },
            ValueFilter {
                roleName: "isCommunityAsset"
                value: false
                enabled: !showCommunityAssetsInSend
            },
            FastExpressionFilter {
                expression: {
                    if (model.isCommunityAsset)
                        return true
                    return model.currentCurrencyBalance > balanceThresholdAmount
                }
                expectedRoles: ["isCommunityAsset", "currentCurrencyBalance"]
                enabled: balanceThresholdEnabled
            }
        ]
        sorters: RoleSorter {
            roleName: "isCommunityAsset"
        }
    }

    /* Internal function to search token address */
    function __searchAddressInList(addressPerChain, searchString) {
        let addressFound = false
        let tokenAddresses = SQUtils.ModelUtils.modelToFlatArray(addressPerChain, "address")
        for (let i =0; i< tokenAddresses.length; i++){
            if(tokenAddresses[i].toUpperCase().startsWith(searchString.toUpperCase())) {
                addressFound = true
                break;
            }
        }
        return addressFound
    }

    /* Internal function to calculate total balance */
    function __getTotalBalance(balances, decimals) {
        let totalBalance = 0
        for(let i=0; i<balances.count; i++) {
            let balancePerAddressPerChain = SQUtils.ModelUtils.get(balances, i)
            totalBalance+=SQUtils.AmountsArithmetic.toNumber(balancePerAddressPerChain.balance, decimals)
        }
        return totalBalance
    }
}
