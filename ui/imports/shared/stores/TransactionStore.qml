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

    function getEtherscanLink(chainID) {
        return networksModule.all.getBlockExplorerURL(chainID)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function getCryptoValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getCryptoValue(balance, cryptoSymbol, fiatSymbol)
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

    function suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, lockedInAmounts) {
        walletSectionTransactions.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, JSON.stringify(lockedInAmounts))
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

    function setDefaultPreferredDisabledChains() {
        let mainnetChainId = getMainnetChainId()
        preferredChainIds.push(mainnetChainId)
        addUnpreferredChainsToDisabledChains()
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

    function addPreferredChains(preferredchains, showUnpreferredNetworks) {
        for(const chain of preferredchains) {
            if(!preferredChainIds.includes(chain)) {
                preferredChainIds.push(chain)
                // remove from disabled accounts as it was added as preferred
                addRemoveDisabledToChain(chain, false)
            }
        }

        // here we are trying to remove chains that are not preferred from the list and
        // also disable them incase the showUnpreferredNetworks toggle is turned off
        for(var i = 0; i < preferredChainIds.length; i++) {
            if(!preferredchains.includes(preferredChainIds[i])) {
                if(!showUnpreferredNetworks)
                    addRemoveDisabledToChain(preferredChainIds[i], true)
                preferredChainIds.splice(i, 1)
            }
        }
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

        if(!chainFound && !isBridgeTx)
            addPreferredChains([getMainnetChainId()], showUnpreferredNetworks)
        else
            addPreferredChains(tempPreferredChains, showUnpreferredNetworks)

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
        let amount = Number.fromLocaleString(Qt.locale(), value) * Math.pow(10, decimals)
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
}
