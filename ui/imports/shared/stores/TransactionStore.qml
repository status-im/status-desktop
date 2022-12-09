import QtQuick 2.13

import utils 1.0

import shared.stores 1.0
import "../../../app/AppLayouts/Profile/stores"

QtObject {
    id: root

    property CurrenciesStore currencyStore: CurrenciesStore { }
    property ProfileSectionStore profileSectionStore: ProfileSectionStore {}
    property var contactStore: profileSectionStore.contactsStore

    property var mainModuleInst: mainModule
    property var walletSectionTransactionsInst: walletSectionTransactions

    property string locale: localAppSettings.language
    property string currentCurrency: walletSection.currentCurrency
    property var allNetworks: networksModule.all
    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    property string signingPhrase: walletSection.signingPhrase
    property var savedAddressesModel: walletSectionSavedAddresses.model
    property var disabledChainIdsFromList: []
    property var disabledChainIdsToList: []

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

    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function estimateGas(from_addr, to, assetSymbol, value, chainId, data) {
        return walletSectionTransactions.estimateGas(from_addr, to, assetSymbol, value, chainId, data)
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionStore.ensUsernamesStore.getGasEthValue(gweiValue, gasLimit)
    }

    function authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes) {
        walletSectionTransactions.authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes)
    }

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionTransactions.suggestedFees(chainId))
    }

    function getEstimatedTime(chainId, maxFeePerGas) {
       return walletSectionTransactions.getEstimatedTime(chainId, maxFeePerGas)
    }

    function getChainIdForChat() {
        return walletSectionTransactions.getChainIdForChat()
    }

    function getChainIdForBrowser() {
        return walletSectionTransactions.getChainIdForBrowser()
    }

    function suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType) {
        walletSectionTransactions.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType)
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function switchAccount(newIndex) {
        if(Constants.isCppApp)
            walletSectionAccounts.switchAccount(newIndex)
        else
            walletSection.switchAccount(newIndex)
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

    property var preferredChainIds: []

    function addPreferredChain(chainID) {
        if(!chainID)
            return

        if(preferredChainIds.includes(chainID))
            return

        preferredChainIds.push(chainID)
    }

    function getMainnetChainId() {
        return networksModule.getMainnetChainId()
    }

    function addUnpreferredChainsToDisabledChains() {
        let mainnetChainId = getMainnetChainId()
        for(var i = 0; i < allNetworks.count; i++) {
            let chainId = allNetworks.rowData(i, "chainId") * 1
            if(mainnetChainId !== chainId) {
                addRemoveDisabledToChain(chainId, true)
            }
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
}
