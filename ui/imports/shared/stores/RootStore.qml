pragma Singleton

import QtQuick 2.12

QtObject {
    id: root
//    property var utilsModelInst: !!utilsModel ? utilsModel :  null
//    property var chatsModelInst: !!chatsModel ?chatsModel : null
//    property var walletModelInst: !!walletModel ? walletModel : null
//    property var profileModelInst: !!profileModel ? profileModel : null

    /// Contex properties wrappers ///
    property var gifProvider:                       !!chatSectionChatContentInputArea ? chatSectionChatContentInputArea : null
    property var walletSectionAccountsProvider:     !!walletSectionAccounts ? walletSectionAccounts : null
    property var currentAccount:                    !!walletSectionCurrent ? walletSectionCurrent : null
    property var walletTokensModule:                !!walletSectionAllTokens ? walletSectionAllTokens : null
    property var history:                           !!walletSectionTransactions ? walletSectionTransactions : null
    property var profileSectionModuleInst:          !!profileSectionModule ? profileSectionModule : null
    property var walletSectionInst:                 !!walletSection ? walletSection : null
    property var userProfileInst:                   !!userProfile ? userProfile : null
    property var appSettings:                       !!localAppSettings ? localAppSettings : null
    property var accountSensitiveSettings:          !!localAccountSensitiveSettings ? localAccountSensitiveSettings : null
    property var networksModuleInst:                !!networksModule ? networksModule : null
    property var globalUtilsInst:                   !!globalUtils ? globalUtils : null
    property var walletSectionSavedAddressesInst:   !!walletSectionSavedAddresses ? walletSectionSavedAddresses : null
    /// end of context propertyies wrappers ///

    property var privacyModule: profileSectionModuleInst.privacyModule
    property real volume: !!accountSensitiveSettings ? accountSensitiveSettings.volume * 0.1 : 0.2
    property bool isWalletEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.isWalletEnabled : false
    property bool notificationSoundsEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.notificationSoundsEnabled : false
    property bool neverAskAboutUnfurlingAgain: !!accountSensitiveSettings ? accountSensitiveSettings.neverAskAboutUnfurlingAgain : false
    property bool isGifWidgetEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.isGifWidgetEnabled : false
    property bool isTenorWarningAccepted: !!accountSensitiveSettings ? accountSensitiveSettings.isTenorWarningAccepted : false
    property bool displayChatImages: !!accountSensitiveSettings ? accountSensitiveSettings.displayChatImages : false

    property string locale: !!appSettings ? appSettings.locale : ""
//    property string signingPhrase: !!walletModelInst ? walletModelInst.utilsView.signingPhrase : ""
//    property string gasPrice: !!walletModelInst ? walletModelInst.gasView.gasPrice : "0"
//    property string gasEthValue: !!walletModelInst ? walletModelInst.gasView.getGasEthValue : "0"

    property CurrenciesStore currencyStore: CurrenciesStore { }
    property string currentCurrency: walletSectionInst.currentCurrency
//    property string defaultCurrency: !!walletModelInst ? walletModelInst.balanceView.defaultCurrency : "0"
//    property string fiatValue: !!walletModelInst ? walletModelInst.balanceView.getFiatValue : "0"
//    property string cryptoValue: !!walletModelInst ? walletModelInst.balanceView.getCryptoValue : "0"

    property var historyTransactions: history.model
    property bool isNonArchivalNode:  history.isNonArchivalNode

    property var marketValueStore: TokenMarketValuesStore{}

    function getNetworkColor(chainId) {
        return networksModuleInst.all.getChainColor(chainId)
    }

    function getNetworkIcon(chainId) {
        return networksModuleInst.all.getIconUrl(chainId)
    }

    function getNetworkShortName(chainId) {
        return networksModuleInst.all.getNetworkShortName(chainId)
    }

    function getNetworkIconUrl(symbol) {
        return networksModuleInst.all.getNetworkIconUrl(symbol)
    }

    function getNetworkName(symbol) {
        return networksModuleInst.all.getNetworkName(symbol)
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionModuleInst.ensUsernamesModule.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function hex2Dec(value) {
        return globalUtilsInst.hex2Dec(value)
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
        accountSensitiveSettings.neverAskAboutUnfurlingAgain = value;
    }

    function enableWallet() {
        accountSensitiveSettings.isWalletEnabled = true;
    }

    function setIsTenorWarningAccepted(value) {
        accountSensitiveSettings.isTenorWarningAccepted = value;
    }

    function copyToClipboard(text) {
        globalUtilsInst.copyToClipboard(text)
    }

    property var gifColumnA: gifProvider.gifColumnA
    property var gifColumnB: gifProvider.gifColumnB
    property var gifColumnC: gifProvider.gifColumnC

    function searchGifs(query) {
        gifProvider.searchGifs(query)
    }

    function getTrendingsGifs() {
        gifProvider.getTrendingsGifs()
    }

    function updateWhitelistedUnfurlingSites(hostname, whitelisted) {
        // no way to send update notification for individual array entries
        let settings = accountSensitiveSettings.whitelistedUnfurlingSites

        if (!settings)
            settings = {}

        if (settings[hostname] === whitelisted)
            return

        settings[hostname] = whitelisted
        accountSensitiveSettings.whitelistedUnfurlingSites = settings
        if(hostname === "media.tenor.com" && whitelisted === false)
            RootStore.setIsTenorWarningAccepted(false)
    }

    function getRecentsGifs() {
        gifProvider.getRecentsGifs()
    }

    function getFavoritesGifs() {
        return gifProvider.getFavoritesGifs()
    }

    function isFavorite(id) {
        return gifProvider.isFavorite(id)
    }

    function toggleFavoriteGif(id, reload) {
        gifProvider.toggleFavoriteGif(id, reload)
    }

    function addToRecentsGif(id) {
        gifProvider.addToRecentsGif(id)
    }

    function getPasswordStrengthScore(password) {
        return root.privacyModule.getPasswordStrengthScore(password);
    }

    function isFetchingHistory(address) {
        return history.isFetchingHistory(address)
    }

    function loadTransactionsForAccount(address, pageSize) {
        history.loadTransactionsForAccount(address, historyTransactions.getLastTxBlockNumber(), pageSize, true)
    }

    function hex2Eth(value) {
        return globalUtilsInst.hex2Eth(value)
    }

    function hex2Gwei(value) {
        return globalUtilsInst.hex2Gwei(value)
    }

    function findTokenSymbolByAddress(address) {
        return  walletTokensModule.findTokenSymbolByAddress(address)
    }

    function getNameForSavedWalletAddress(address) {
        return walletSectionSavedAddressesInst.getNameByAddress(address)
    }

    function createOrUpdateSavedAddress(name, address, favourite) {
        return walletSectionSavedAddressesInst.createOrUpdateSavedAddress(name, address, favourite)
    }

    function deleteSavedAddress(address) {
        return walletSectionSavedAddressesInst.deleteSavedAddress(address)
    }

    function getLatestBlockNumber() {
        return history.getLastTxBlockNumber()
    }

    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionModuleInst.ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
    }

    function getHistoricalDataForToken(symbol, currency) {
        walletTokensModule.getHistoricalDataForToken(symbol,currency)
    }

    // TODO: range until we optimize to cache the data and abuse the requests
    function fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum) {
        walletTokensModule.fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum)
    }
}
