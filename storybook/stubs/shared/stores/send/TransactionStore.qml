import QtQuick 2.15

import Models 1.0
import utils 1.0
import StatusQ.Core.Utils 0.1
import shared.stores 1.0

QtObject {
    id: root

    readonly property var currencyStore: CurrenciesStore{}
    readonly property var senderAccounts: WalletSendAccountsModel {
        Component.onCompleted: selectedSenderAccount = senderAccounts.get(0)
    }
    property var accounts: senderAccounts
    property QtObject tmpActivityController: QtObject {
        property ListModel model: ListModel{}
    }

    property var allNetworksModel: NetworksModel.allNetworks
    property var fromNetworksModel: NetworksModel.sendFromNetworks
    property var toNetworksModel: NetworksModel.sendToNetworks
    property var selectedSenderAccount: senderAccounts.get(0)
    readonly property QtObject collectiblesModel: WalletCollectiblesModel {}
    readonly property QtObject nestedCollectiblesModel: WalletNestedCollectiblesModel {}

    readonly property QtObject walletSectionSendInst: QtObject {
        signal transactionSent(var chainId, var txHash, var uuid, var error)
        signal suggestedRoutesReady(var txRoutes)
    }
    readonly property QtObject mainModuleInst: QtObject {
        signal resolvedENS(var resolvedPubKey, var resolvedAddress, var uuid)
    }

    property string selectedAssetSymbol
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
                           chainShortNames: "eth:arb"
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
        const idx = ModelUtils.indexOf(assetsList, "symbol", symbol)
        if (idx < 0) {
            return {}
        }
        return ModelUtils.get(assetsList, idx)
    }

    function getCollectible(uid) {
        const idx = ModelUtils.indexOf(collectiblesModel, "uid", uid)
        if (idx < 0) {
            return {}
        }
        return ModelUtils.get(collectiblesModel, idx)
    }

    function getSelectorCollectible(uid) {
        const idx = ModelUtils.indexOf(nestedCollectiblesModel, "uid", uid)
        if (idx < 0) {
            return {}
        }
        return ModelUtils.get(nestedCollectiblesModel, idx)
    }

    function getHolding(holdingId, holdingType) {
        if (holdingType === Constants.TokenType.ERC20) {
            return getAsset(selectedSenderAccount.assets, holdingId)
        } else if (holdingType === Constants.TokenType.ERC721) {
            return getCollectible(holdingId)
        } else {
            return {}
        }
    }

    function getSelectorHolding(holdingId, holdingType) {
        if (holdingType === Constants.TokenType.ERC20) {
            return getAsset(selectedSenderAccount.assets, holdingId)
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
        if (holdingType === Constants.TokenType.Asset) {
            return assetToSelectorAsset(holding)
        } else if (holdingType === Constants.TokenType.Collectible) {
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

    function findTokenSymbolByAddress() {
        return "ETH"
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
            listOfChainIds.push(ModelUtils.getByKey(NetworksModel.allNetworks, "shortName", listOfChains[k], "chainId"))
        }
        return listOfChainIds
    }

    function setSendType(sendType) {
        root.sendType = sendType
    }

    function setSelectedRecipient(recipientAddress) {
        root.selectedRecipient = recipientAddress
    }

    function setSelectedAssetSymbol(symbol) {
       root.selectedAssetSymbol = symbol
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
        root.selectedAssetSymbol = ""
        root.showUnPreferredChains = false
        root.fromNetworksModel.reset()
        root.toNetworksModel.reset()
    }

    function getNetworkName(chainId) {
        return ModelUtils.getByKey(NetworksModel.allNetworks, "chainId", chainId, "chainName")
    }
}
