import QtQuick 2.13

import utils 1.0

import shared.stores 1.0
import "../../../app/AppLayouts/Profile/stores"
import SortFilterProxyModel 0.2

QtObject {
    id: root

    property CurrenciesStore currencyStore: CurrenciesStore {}
    property ProfileSectionStore profileSectionStore: ProfileSectionStore {}
    property var contactStore: profileSectionStore.contactsStore

    property var mainModuleInst: mainModule
    property var walletSectionSendInst: walletSectionSend
    property var walletSectionInst: walletSection

    property var tmpActivityController: walletSectionInst.tmpActivityController

    property string currentCurrency: walletSectionInst.currentCurrency
    property var allNetworks: networksModule.all
    property var overview: walletSectionOverview
    property var accounts: walletSectionSendInst.accounts
    property var senderAccounts: walletSectionSendInst.senderAccounts
    property var selectedSenderAccount: walletSectionSendInst.selectedSenderAccount
    property string signingPhrase: walletSectionInst.signingPhrase
    property var savedAddressesModel: SortFilterProxyModel {
        sourceModel: walletSectionSavedAddresses.model
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: networksModule.areTestNetworksEnabled
            }
        ]
    }
    property var disabledChainIdsFromList: []
    property var disabledChainIdsToList: []

    property var assets: walletSectionAssets.assets

    function addRemoveDisabledFromChain(chainID, isDisabled) {
        if(isDisabled) {
            if(!root.disabledChainIdsFromList.includes(chainID))
                disabledChainIdsFromList.push(chainID)
        }
        else {
            for(var i = 0; i < disabledChainIdsFromList.length;i++) {
                if(disabledChainIdsFromList[i] === chainID) {
                    disabledChainIdsFromList.splice(i, 1)
                }
            }
        }
    }

    function addRemoveDisabledToChain(chainID, isDisabled) {
        if(isDisabled) {
            if(!root.disabledChainIdsToList.includes(chainID))
                root.disabledChainIdsToList.push(chainID)
        }
        else {
            for(var i = 0; i < root.disabledChainIdsToList.length;i++) {
                if(root.disabledChainIdsToList[i] === chainID) {
                    root.disabledChainIdsToList.splice(i, 1)
                }
            }
        }
    }

    function getEtherscanLink(chainID) {
        return networksModule.all.getBlockExplorerURL(chainID)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes) {
        walletSectionSendInst.authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes)
    }

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionSendInst.suggestedFees(chainId))
    }

    function getEstimatedTime(chainId, maxFeePerGas) {
       return walletSectionSendInst.getEstimatedTime(chainId, maxFeePerGas)
    }

    function suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, lockedInAmounts) {
        walletSectionSendInst.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, JSON.stringify(lockedInAmounts))
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function resolveENS(value) {
        mainModuleInst.resolveENS(value, "")
    }

    function getWei2Eth(wei, decimals) {
        return globalUtils.wei2Eth(wei, decimals)
    }

    function getEth2Wei(eth, decimals) {
         return globalUtils.eth2Wei(eth, decimals)
    }

    function plainText(text) {
        return globalUtils.plainText(text)
    }

    function setDefaultPreferredDisabledChains() {
        let mainnetChainId = getMainnetChainId()
        preferredChainIds.push(mainnetChainId)
        addUnpreferredChainsToDisabledChains()
    }

    function setAllNetworksAsPreferredChains() {
        var preferredChains = []
        for(var i = 0; i < allNetworks.count; i++) {
            let chainId = allNetworks.rowData(i, "chainId") * 1
            if(!preferredChainIds.includes(chainId)) {
                preferredChainIds.push(chainId)
            }
        }
    }

    function resetTxStoreProperties() {
        disabledChainIdsFromList = []
        disabledChainIdsToList = []
        preferredChainIds = []
        lockedInAmounts = []
    }

    property var preferredChainIds: []

    function getMainnetChainId() {
        return networksModule.getMainnetChainId()
    }

    // We should move all this over to nim
    function addPreferredChains(preferredchains, showUnpreferredNetworks) {
        let tempPreferredChains = preferredChainIds
        for(const chain of preferredchains) {
            if(!tempPreferredChains.includes(chain)) {
                tempPreferredChains.push(chain)
                // remove from disabled accounts as it was added as preferred
                addRemoveDisabledToChain(chain, false)
            }
        }

        // here we are trying to remove chains that are not preferred from the list and
        // also disable them incase the showUnpreferredNetworks toggle is turned off
        for(var i = 0; i < tempPreferredChains.length; i++) {
            if(!preferredchains.includes(tempPreferredChains[i])) {
                if(!showUnpreferredNetworks)
                    addRemoveDisabledToChain(tempPreferredChains[i], true)
                tempPreferredChains.splice(i, 1)
            }
        }

        preferredChainIds = tempPreferredChains
    }

    function addUnpreferredChainsToDisabledChains() {
        for(var i = 0; i < allNetworks.count; i++) {
            let chainId = allNetworks.rowData(i, "chainId") * 1
            if(!preferredChainIds.includes(chainId)) {
                addRemoveDisabledToChain(chainId, true)
            }
        }
    }

    function splitAndFormatAddressPrefix(text, isBridgeTx, showUnpreferredNetworks) {
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
                let chainColor = allNetworks.getNetworkColor(word)
                if(!!chainColor) {
                    chainFound = true
                    if(!isBridgeTx)
                        tempPreferredChains.push(allNetworks.getNetworkChainId(word))
                    editedText += `<span style='color: %1'>%2</span>`.arg(chainColor).arg(word)+':'
                }
            }
        }

        if(!isBridgeTx) {
            if(!chainFound)
                addPreferredChains([getMainnetChainId()], showUnpreferredNetworks)
            else
                addPreferredChains(tempPreferredChains, showUnpreferredNetworks)
        }

        editedText +="</a></p>"
        return {
            formattedText: editedText,
            address: address
        }
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

    property var lockedInAmounts: []

    function addLockedInAmount(chainID, value, decimals, locked) {
        let amount = value * Math.pow(10, decimals)
        let index  = lockedInAmounts.findIndex(lockedItem => lockedItem !== undefined && lockedItem.chainID === chainID)
        if(index === -1) {
            lockedInAmounts.push({"chainID": chainID, "value": amount.toString(16)})
        }
        else {
            if(locked) {
                lockedInAmounts[index].value = amount.toString(16)
            } else {
                lockedInAmounts.splice(index,1)
            }
        }
    }

    function getTokenBalanceOnChain(selectedAccount, chainId: int, tokenSymbol: string) {
        if (!selectedAccount) {
            console.warn("selectedAccount invalid")
            return undefined
        }

        walletSectionSendInst.prepareTokenBalanceOnChain(selectedAccount.address, chainId, tokenSymbol)
        return walletSectionSendInst.getPreparedTokenBalanceOnChain()
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

    function getAllNetworksSupportedPrefix() {
        return networksModule.getAllNetworksSupportedPrefix()
    }

    function switchSenderAccount(index) {
        walletSectionSendInst.switchSenderAccount(index)
    }
}
