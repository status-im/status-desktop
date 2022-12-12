pragma Singleton

import QtQuick 2.12

QtObject {
    id: root
//    property var utilsModelInst: !!utilsModel ? utilsModel :  null
//    property var chatsModelInst: !!chatsModel ?chatsModel : null
//    property var walletModelInst: !!walletModel ? walletModel : null
//    property var profileModelInst: !!profileModel ? profileModel : null

    property var profileSectionModuleInst: profileSectionModule
    property var privacyModule: profileSectionModuleInst.privacyModule
    property var userProfileInst: !!userProfile ? userProfile : null
    property var walletSectionInst: !!walletSection ? walletSection : null
    property var appSettingsInst: !!appSettings ? appSettings : null
    property var accountSensitiveSettings: !!localAccountSensitiveSettings ? localAccountSensitiveSettings : null
    property real volume: !!appSettingsInst ? appSettingsInst.volume * 0.01 : 0.5
    property bool isWalletEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.isWalletEnabled : false
    property bool notificationSoundsEnabled: !!appSettingsInst ? appSettingsInst.notificationSoundsEnabled : true
    property bool neverAskAboutUnfurlingAgain: !!accountSensitiveSettings ? accountSensitiveSettings.neverAskAboutUnfurlingAgain : false
    property bool isGifWidgetEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.isGifWidgetEnabled : false
    property bool isTenorWarningAccepted: !!accountSensitiveSettings ? accountSensitiveSettings.isTenorWarningAccepted : false
    property bool displayChatImages: !!accountSensitiveSettings ? accountSensitiveSettings.displayChatImages : false

    property string locale: Qt.locale().name
//    property string signingPhrase: !!walletModelInst ? walletModelInst.utilsView.signingPhrase : ""
//    property string gasPrice: !!walletModelInst ? walletModelInst.gasView.gasPrice : "0"
//    property string gasEthValue: !!walletModelInst ? walletModelInst.gasView.getGasEthValue : "0"

    property CurrenciesStore currencyStore: CurrenciesStore { }
    property string currentCurrency: walletSection.currentCurrency
//    property string defaultCurrency: !!walletModelInst ? walletModelInst.balanceView.defaultCurrency : "0"
//    property string fiatValue: !!walletModelInst ? walletModelInst.balanceView.getFiatValue : "0"
//    property string cryptoValue: !!walletModelInst ? walletModelInst.balanceView.getCryptoValue : "0"

    property var history: typeof walletSectionTransactions !== "undefined" ? walletSectionTransactions
                                                                          : null
    property var historyTransactions: walletSectionTransactions.model
    property bool isNonArchivalNode: history ? history.isNonArchivalNode
                                             : false

    property var currentAccount: walletSectionCurrent
    property var marketValueStore: TokenMarketValuesStore{}

    function getNetworkColor(chainId) {
        return networksModule.all.getChainColor(chainId)
    }

    function getNetworkIcon(chainId) {
        return networksModule.all.getIconUrl(chainId)
    }

    function getNetworkShortName(chainId) {
        return networksModule.all.getNetworkShortName(chainId)
    }

    function getNetworkIconUrl(symbol) {
        return networksModule.all.getNetworkIconUrl(symbol)
    }

    function getNetworkName(symbol) {
        return networksModule.all.getNetworkName(symbol)
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionModule.ensUsernamesModule.getFiatValue(balance, cryptoSymbol, fiatSymbol)
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

    function enableWallet() {
        localAccountSensitiveSettings.isWalletEnabled = true;
    }

    function setIsTenorWarningAccepted(value) {
        localAccountSensitiveSettings.isTenorWarningAccepted = value;
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

    function searchGifs(query) {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.searchGifs(query)
    }

    function getTrendingsGifs() {
        if (chatSectionChatContentInputAreaInst)
            chatSectionChatContentInputAreaInst.getTrendingsGifs()
    }

    function updateWhitelistedUnfurlingSites(hostname, whitelisted) {
        // no way to send update notification for individual array entries
        let settings = localAccountSensitiveSettings.whitelistedUnfurlingSites

        if (!settings)
            settings = {}

        if (settings[hostname] === whitelisted)
            return

        settings[hostname] = whitelisted
        localAccountSensitiveSettings.whitelistedUnfurlingSites = settings
        if(hostname === "media.tenor.com" && whitelisted === false)
            RootStore.setIsTenorWarningAccepted(false)
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

    function isFetchingHistory(address) {
        return history.isFetchingHistory(address)
    }

    function loadTransactionsForAccount(address, pageSize) {
        history.loadTransactionsForAccount(address, historyTransactions.getLastTxBlockNumber(), pageSize, true)
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function hex2Gwei(value) {
        return globalUtils.hex2Gwei(value)
    }

    function findTokenSymbolByAddress(address) {
        return  walletSectionAllTokens.findTokenSymbolByAddress(address)
    }

    function getNameForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getNameByAddress(address)
    }

    function createOrUpdateSavedAddress(name, address, favourite) {
        return walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address, favourite)
    }

    function deleteSavedAddress(address) {
        return walletSectionSavedAddresses.deleteSavedAddress(address)
    }

    function getLatestBlockNumber() {
        return walletSectionTransactions.getLastTxBlockNumber()
    }

    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionModule.ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
    }

    function getHistoricalDataForToken(symbol, currency) {
        walletSectionAllTokens.getHistoricalDataForToken(symbol,currency)
    }

    // TODO: range until we optimize to cache the data and abuse the requests
    function fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum) {
        walletSectionAllTokens.fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum)
    }
}
