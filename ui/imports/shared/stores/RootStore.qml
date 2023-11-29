pragma Singleton

import QtQuick 2.12
import utils 1.0

QtObject {
    id: root

    property var profileSectionModuleInst: profileSectionModule
    property var privacyModule: profileSectionModuleInst.privacyModule
    property var userProfileInst: !!Global.userProfile? Global.userProfile : null
    property var walletSectionInst: Global.appIsReady && !!walletSection? walletSection : null
    property var appSettingsInst: Global.appIsReady && !!appSettings? appSettings : null
    property var accountSensitiveSettings: Global.appIsReady && !!localAccountSensitiveSettings? localAccountSensitiveSettings : null
    property real volume: !!appSettingsInst ? appSettingsInst.volume * 0.01 : 0.5
    property bool isWalletEnabled: Global.appIsReady? mainModule.sectionsModel.getItemEnabledBySectionType(Constants.appSection.wallet) : true

    property bool notificationSoundsEnabled: !!appSettingsInst ? appSettingsInst.notificationSoundsEnabled : true
    property bool neverAskAboutUnfurlingAgain: !!accountSensitiveSettings ? accountSensitiveSettings.neverAskAboutUnfurlingAgain : false
    property bool gifUnfurlingEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.gifUnfurlingEnabled : false

    property CurrenciesStore currencyStore: CurrenciesStore {}
    property string currentCurrency: Global.appIsReady? walletSectionInst.currentCurrency : ""

    readonly property var transactionActivityStatus: Global.appIsReady ? walletSectionInst.activityController.status : null

    property var historyTransactions: Global.appIsReady? walletSectionInst.activityController.model : null
    readonly property bool loadingHistoryTransactions: Global.appIsReady && walletSectionInst.activityController.status.loadingData
    readonly property bool newDataAvailable: Global.appIsReady && walletSectionInst.activityController.status.newDataAvailable
    property bool isNonArchivalNode: Global.appIsReady && walletSectionInst.isNonArchivalNode

    property var marketValueStore: TokenMarketValuesStore{}
    property var allNetworks: networksModule.all

    function resetFilter() {
        walletSectionInst.activityController.updateFilter()
    }

    // TODO remove all these by linking chainId for networks and activity using LeftJoinModel
    // not possible currently due to the current structure of the activity model
    function getNetworkColor(chainId) {
        return networksModule.all.getChainColor(chainId)
    }

    function getNetworkIcon(chainId) {
        return networksModule.all.getIconUrl(chainId)
    }

    function getNetworkShortName(chainId) {
        return networksModule.all.getNetworkShortName(chainId)
    }

    function getNetworkFullName(chainId) {
        return networksModule.all.getNetworkFullName(chainId)
    }

    function getNetworkLayer(chainId) {
        return networksModule.all.getNetworkLayer(chainId)
    }

    function getNetworkIconUrl(symbol) {
        return networksModule.all.getNetworkIconUrl(symbol)
    }

    function getNetworkName(symbol) {
        return networksModule.all.getNetworkName(symbol)
    }

    function hex2Dec(value) {
        return globalUtils.hex2Dec(value)
    }

    readonly property var formationChars: (["*", "`", "~"])
    function getSelectedTextWithFormationChars(messageInputField) {
        let i = 1
        let text = ""
        while (true) {
            if (messageInputField.selectionStart - i < 0 && messageInputField.selectionEnd + i > messageInputField.length) {
                break
            }

            text = messageInputField.getText(messageInputField.selectionStart - i, messageInputField.selectionEnd + i)

            if (!formationChars.includes(text.charAt(0)) ||
                    !formationChars.includes(text.charAt(text.length - 1))) {
                break
            }
            i++
        }
        return text
    }

    function setNeverAskAboutUnfurlingAgain(value) {
        localAccountSensitiveSettings.neverAskAboutUnfurlingAgain = value;
    }

    function setGifUnfurlingEnabled(value) {
        localAccountSensitiveSettings.gifUnfurlingEnabled = value
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    property var chatSectionChatContentInputAreaInst: typeof chatSectionChatContentInputArea !== "undefined" ? chatSectionChatContentInputArea
                                                                                                             : null
    property var gifColumnA: chatSectionChatContentInputAreaInst ? chatSectionChatContentInputArea.gifColumnA
                                                                 : null
    property var gifColumnB: chatSectionChatContentInputAreaInst ? chatSectionChatContentInputArea.gifColumnB
                                                                 : null
    property var gifColumnC: chatSectionChatContentInputAreaInst ? chatSectionChatContentInputArea.gifColumnC
                                                                 : null
    property bool gifLoading: chatSectionChatContentInputAreaInst ? chatSectionChatContentInputArea.gifLoading
                                                                 : false

    function searchGifs(query) {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.searchGifs(query)
    }

    function getTrendingsGifs() {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.getTrendingsGifs()
    }

    function getRecentsGifs() {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.getRecentsGifs()
    }

    function getFavoritesGifs() {
        return chatSectionChatContentInputAreaInst ? chatSectionChatContentInputAreaInst.getFavoritesGifs()
                                                   : null
    }

    function isFavorite(id) {
        return chatSectionChatContentInputAreaInst ? chatSectionChatContentInputAreaInst.isFavorite(id)
                                                   : null
    }

    function toggleFavoriteGif(id, reload) {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.toggleFavoriteGif(id, reload)
    }

    function addToRecentsGif(id) {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.addToRecentsGif(id)
    }

    function getPasswordStrengthScore(password) {
        return root.privacyModule.getPasswordStrengthScore(password);
    }

    function fetchMoreTransactions() {
        if (RootStore.historyTransactions.count === 0
                || !RootStore.historyTransactions.hasMore
                || loadingHistoryTransactions)
            return
        walletSectionInst.activityController.loadMoreItems()
    }

    function updateTransactionFilter() {
        if (transactionActivityStatus.isFilterDirty)
            walletSectionInst.activityController.updateFilter()
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function hex2Gwei(value) {
        return globalUtils.hex2Gwei(value)
    }

    function findTokenSymbolByAddress(address) {
        if (Global.appIsReady)
            return walletSectionAllTokens.findTokenSymbolByAddress(address)
        return ""
    }

    function getNameForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getNameByAddress(address)
    }

    function getChainShortNamesForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getChainShortNamesForAddress(address)
    }

    function getEnsForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getEnsForAddress(address)
    }

    function createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens) {
        return walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens)
    }

    function deleteSavedAddress(addresse, ens) {
        return walletSectionSavedAddresses.deleteSavedAddress(address, ens)
    }

    function getCurrencyAmount(amount, symbol) {
        return currencyStore.getCurrencyAmount(amount, symbol)
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return currencyStore.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function getCryptoValue(balance, cryptoSymbol, fiatSymbol) {
        return currencyStore.getCryptoValue(balance, cryptoSymbol, fiatSymbol)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        return currencyStore.getGasEthValue(gweiValue, gasLimit)
    }

    function getFeeEthValue(feeCurrency) {
        if (!feeCurrency || feeCurrency.symbol !== "Gwei")
            return 0
        return currencyStore.getGasEthValue(feeCurrency.amount / Math.pow(10, feeCurrency.displayDecimals), 1)
    }

    function formatCurrencyAmount(amount, symbol, options = null, locale = null) {
        return currencyStore.formatCurrencyAmount(amount, symbol, options, locale)
    }

    function getHistoricalDataForToken(symbol, currency) {
        if (Global.appIsReady)
            walletSectionAllTokens.getHistoricalDataForToken(symbol,currency)
    }

    function fetchDecodedTxData(txHash, input) {
        walletSectionInst.fetchDecodedTxData(txHash, input)
    }

    function fetchTxDetails(modelIndex) {
        walletSectionInst.activityController.fetchTxDetails(modelIndex)
    }

    function getTxDetails() {
        return walletSectionInst.activityController.activityDetails
    }

    property bool marketHistoryIsLoading: Global.appIsReady? walletSectionAllTokens.marketHistoryIsLoading : false

    function fetchHistoricalBalanceForTokenAsJson(address, allAddresses, tokenSymbol, currencySymbol, timeIntervalEnum) {
        if (Global.appIsReady)
            walletSectionAllTokens.fetchHistoricalBalanceForTokenAsJson(address, allAddresses, tokenSymbol, currencySymbol, timeIntervalEnum)
    }

    property bool balanceHistoryIsLoading: Global.appIsReady? walletSectionAllTokens.balanceHistoryIsLoading : false

}
