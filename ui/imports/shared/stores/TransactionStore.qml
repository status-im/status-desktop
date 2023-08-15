import QtQuick 2.13

import SortFilterProxyModel 0.2

import shared.stores 1.0

import utils 1.0

QtObject {
    id: root

    property CurrenciesStore currencyStore: CurrenciesStore {}

    property var mainModuleInst: mainModule
    property var walletSectionSendInst: walletSectionSend

    property var fromNetworksModel: walletSectionSendInst.fromNetworksModel
    property var toNetworksModel: walletSectionSendInst.toNetworksModel
    property var senderAccounts: walletSectionSendInst.senderAccounts
    property var selectedSenderAccount: walletSectionSendInst.selectedSenderAccount
    property var accounts: walletSectionSendInst.accounts
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

    function getEtherscanLink(chainID) {
        return networksModule.all.getBlockExplorerURL(chainID)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function authenticateAndTransfer(from, to, tokenSymbol, amount, uuid) {
        walletSectionSendInst.authenticateAndTransfer(from, to, tokenSymbol, amount, uuid)
    }

    function suggestedRoutes(amount, sendType) {
        walletSectionSendInst.suggestedRoutes(amount, sendType)
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
            if(symbol === assetsList.rowData(i, "symbol"))
                return {
                    name: assetsList.rowData(i, "name"),
                    symbol: assetsList.rowData(i, "symbol"),
                    totalBalance: JSON.parse(assetsList.rowData(i, "totalBalance")),
                    totalCurrencyBalance: JSON.parse(assetsList.rowData(i, "totalCurrencyBalance")),
                    balances: assetsList.rowData(i, "balances"),
                    decimals: assetsList.rowData(i, "decimals")
                }
        }
        return {}
    }

    function switchSenderAccount(index) {
        walletSectionSendInst.switchSenderAccount(index)
    }

    function getNetworkShortNames(chainIds) {
       return networksModule.getNetworkShortNames(chainIds)
    }

    function toggleFromDisabledChains(chainId) {
        fromNetworksModel.toggleDisabledChains(chainId)
    }

    function toggleToDisabledChains(chainId) {
        toNetworksModel.toggleDisabledChains(chainId)
    }

    function setDisabledChains(chainId, disabled) {
        toNetworksModel.setDisabledChains(chainId, disabled)
    }

    function setSelectedAssetSymbol(symbol) {
        walletSectionSendInst.setSelectedAssetSymbol(symbol)
    }

    function getNetworkName(chainId) {
      return fromNetworksModel.getNetworkName(chainId)
    }

    function updatePreferredChains(chainIds) {
       walletSectionSendInst.updatePreferredChains(chainIds)
    }

    function toggleShowUnPreferredChains() {
        walletSectionSendInst.toggleShowUnPreferredChains()
    }

    function setAllNetworksAsPreferredChains() {
        toNetworksModel.setAllNetworksAsPreferredChains()
    }

    function lockCard(chainId, amount, lock) {
        fromNetworksModel.lockCard(chainId, amount, lock)
    }

    function resetStoredProperties() {
        walletSectionSendInst.resetStoredProperties()
    }

    // TODO: move to nim
    function splitAndFormatAddressPrefix(text, isBridgeTx) {
        let address = ""
        let tempPreferredChains = []
        let chainFound = false
        let splitWords = plainText(text).split(':')
        let editedText = ""

        for(var i=0; i<splitWords.length; i++) {
            const word = splitWords[i]
            if(word.startsWith("0x")) {
                address = word
                editedText += word
            } else {
                let chainColor = fromNetworksModel.getNetworkColor(word)
                if(!!chainColor) {
                    chainFound = true
                    if(!isBridgeTx)
                        tempPreferredChains.push(fromNetworksModel.getNetworkChainId(word))
                    editedText += `<span style='color: %1'>%2</span>`.arg(chainColor).arg(word)+':'
                }
            }
        }

        if(!isBridgeTx) {
            if(!chainFound)
                updatePreferredChains(networksModule.getMainnetChainId())
            else
                updatePreferredChains(tempPreferredChains.join(":"))
        }

        editedText +="</a></p>"
        return {
            formattedText: editedText,
            address: address
        }
    }
}
