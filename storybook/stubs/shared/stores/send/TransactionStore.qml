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
    
    readonly property var accounts: WalletSendAccountsModel {
        Component.onCompleted: selectedSenderAccount = accounts.get(0)
    }

    property WalletAssetsStore walletAssetStore

    property QtObject tmpActivityController: QtObject {
        property ListModel model: ListModel{}
    }

    property var flatNetworksModel: NetworksModel.flatNetworks
    property var fromNetworksRouteModel: NetworksModel.sendFromNetworks
    property var toNetworksRouteModel: NetworksModel.sendToNetworks
    property var selectedSenderAccount: accounts.get(0)
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

    function setSenderAccountByAddress(address) {
        for (let i = 0; i < accounts.count; i++) {
            const acc = accounts.get(i)
            if (acc.address === address && accounts.canSend) {
                selectedSenderAccount = accounts.get(i)
                break
            }
        }
    }

    function getNetworkShortNames(chainIds) {
        return ""
    }

    function getShortChainIds(chainIds) {
        let listOfChains = chainIds.split(":")
        let listOfChainIds = []
        for (let k =0;k<listOfChains.length;k++) {
            listOfChainIds.push(SQUtils.ModelUtils.getByKey(flatNetworksModel, "shortName", listOfChains[k], "chainId"))
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
        root.toNetworksRouteModel.updateRoutePreferredChains(chainIds)
    }

    function toggleShowUnPreferredChains() {
        root.showUnPreferredChains = !root.showUnPreferredChains
    }

    function setRouteEnabledFromChains(chainId) {
    }

    function setSelectedTokenIsOwnerToken(isOwnerToken) {
    }

    function setSelectedTokenName(tokenName) {
    }

    property string amountToSend
    property bool suggestedRoutesCalled: false
    function suggestedRoutes(amount) {
        root.amountToSend = amount
        root.suggestedRoutesCalled = true
    }

    function resetStoredProperties() {
        root.amountToSend = ""
        root.sendType = Constants.SendType.Transfer
        root.selectedRecipient = ""
        root.selectedAssetKey = ""
        root.showUnPreferredChains = false
        root.fromNetworksRouteModel.reset()
        root.toNetworksRouteModel.reset()
    }

    function getNetworkName(chainId) {
        return SQUtils.ModelUtils.getByKey(flatNetworksModel, "chainId", chainId, "chainName")
    }

    function formatCurrencyAmountFromBigInt(balance, symbol, decimals, options = null) {
        return currencyStore.formatCurrencyAmountFromBigInt(balance, symbol, decimals, options)
    }

    // Property and methods below are used to apply advanced token management settings to the SendModal
    property bool showCommunityAssetsInSend: true
    property bool balanceThresholdEnabled: true
    property real balanceThresholdAmount
}
