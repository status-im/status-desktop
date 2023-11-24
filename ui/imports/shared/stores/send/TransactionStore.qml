import QtQuick 2.13

import SortFilterProxyModel 0.2

import shared.stores 1.0

import utils 1.0

import StatusQ.Core.Utils 0.1

QtObject {
    id: root

    property CurrenciesStore currencyStore: CurrenciesStore {}

    property var mainModuleInst: mainModule
    property var walletSectionSendInst: walletSectionSend

    property var assets: walletSectionAssets.assets
    property var fromNetworksModel: walletSectionSendInst.fromNetworksModel
    property var toNetworksModel: walletSectionSendInst.toNetworksModel
    property var allNetworksModel: networksModule.all
    property var senderAccounts: walletSectionSendInst.senderAccounts
    property var selectedSenderAccount: walletSectionSendInst.selectedSenderAccount
    property var accounts: walletSectionSendInst.accounts
    property var collectiblesModel: walletSectionSendInst.collectiblesModel
    property var nestedCollectiblesModel: walletSectionSendInst.nestedCollectiblesModel
    property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var tmpActivityController: walletSection.tmpActivityController
    property var savedAddressesModel: SortFilterProxyModel {
        sourceModel: walletSectionSavedAddresses.model
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: areTestNetworksEnabled
            }
        ]
    }
    property string selectedAssetSymbol: walletSectionSendInst.selectedAssetSymbol
    property bool showUnPreferredChains: walletSectionSendInst.showUnPreferredChains
    property int sendType: walletSectionSendInst.sendType
    property string selectedRecipient: walletSectionSendInst.selectedRecipient

    function setSendType(sendType) {
        walletSectionSendInst.setSendType(sendType)
    }

    function setSelectedRecipient(recipientAddress) {
        walletSectionSendInst.setSelectedRecipient(recipientAddress)
    }

    function getEtherscanLink(chainID) {
        return networksModule.all.getBlockExplorerURL(chainID)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function authenticateAndTransfer(amount, uuid) {
        walletSectionSendInst.authenticateAndTransfer(amount, uuid)
    }

    function suggestedRoutes(amount) {
        const value = AmountsArithmetic.fromNumber(amount)
        walletSectionSendInst.suggestedRoutes(value.toFixed())
    }

    function resolveENS(value) {
        mainModuleInst.resolveENS(value, "")
    }

    function getWei2Eth(wei, decimals) {
        return globalUtils.wei2Eth(wei, decimals)
    }

    function plainText(text) {
        return globalUtils.plainText(text)
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

    function findTokenSymbolByAddress(address) {
        if (Global.appIsReady)
            return walletSectionAllTokens.findTokenSymbolByAddress(address)
        return ""
    }

    function getAsset(assetsList, symbol) {
        for(var i=0; i< assetsList.count;i++) {
            if(symbol === assetsList.rowData(i, "symbol")) {
                return {
                    name: assetsList.rowData(i, "name"),
                    symbol: assetsList.rowData(i, "symbol"),
                    totalBalance: JSON.parse(assetsList.rowData(i, "totalBalance")),
                    totalCurrencyBalance: JSON.parse(assetsList.rowData(i, "totalCurrencyBalance")),
                    balances: assetsList.rowData(i, "balances"),
                    decimals: assetsList.rowData(i, "decimals")
                }
            }
        }
        return {}
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
        if (holdingType === Constants.TokenType.ERC20) {
            return assetToSelectorAsset(holding)
        } else if (holdingType === Constants.TokenType.ERC721) {
            return collectibleToSelectorCollectible(holding)
        } else {
            return {}
        }
    }

    function switchSenderAccount(index) {
        walletSectionSendInst.switchSenderAccount(index)
    }

    function getNetworkShortNames(chainIds) {
       return networksModule.getNetworkShortNames(chainIds)
    }

    function toggleFromDisabledChains(chainId) {
        fromNetworksModel.toggleRouteDisabledChains(chainId)
    }

    function toggleToDisabledChains(chainId) {
        toNetworksModel.toggleRouteDisabledChains(chainId)
    }

    function setRouteDisabledChains(chainId, disabled) {
        toNetworksModel.setRouteDisabledChains(chainId, disabled)
    }

    function setSelectedTokenName(tokenName) {
        walletSectionSendInst.setSelectedTokenName(tokenName)
    }

    function setSelectedTokenIsOwnerToken(isOwnerToken) {
        walletSectionSendInst.setSelectedTokenIsOwnerToken(isOwnerToken)
    }

    function setRouteEnabledFromChains(chainId) {
        fromNetworksModel.setRouteEnabledFromChains(chainId)
    }

    function setSelectedAssetSymbol(symbol) {
        walletSectionSendInst.setSelectedAssetSymbol(symbol)
    }

    function getNetworkName(chainId) {
      return fromNetworksModel.getNetworkName(chainId)
    }

    function updateRoutePreferredChains(chainIds) {
       walletSectionSendInst.updateRoutePreferredChains(chainIds)
    }

    function toggleShowUnPreferredChains() {
        walletSectionSendInst.toggleShowUnPreferredChains()
    }

    function setAllNetworksAsRoutePreferredChains() {
        toNetworksModel.setAllNetworksAsRoutePreferredChains()
    }

    function lockCard(chainId, amount, lock) {
        fromNetworksModel.lockCard(chainId, amount, lock)
    }

    function resetStoredProperties() {
        walletSectionSendInst.resetStoredProperties()
        nestedCollectiblesModel.currentCollectionUid = ""
    }

    function splitAndFormatAddressPrefix(text, updateInStore) {
        return {
            formattedText: walletSectionSendInst.splitAndFormatAddressPrefix(text, updateInStore),
            address: walletSectionSendInst.getAddressFromFormattedString(text)
        }
    }

    function getShortChainIds(chainShortNames) {
        return walletSectionSendInst.getShortChainIds(chainShortNames)
    }
}
