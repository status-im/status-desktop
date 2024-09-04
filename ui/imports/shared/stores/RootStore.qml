pragma Singleton

import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    readonly property GifStore gifStore: GifStore {}

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

    property TokenMarketValuesStore marketValueStore: TokenMarketValuesStore{}

    function resetActivityData() {
        walletSectionInst.activityController.resetActivityData()
    }

    property var flatNetworks: networksModule.flatNetworks

    function setNeverAskAboutUnfurlingAgain(value) {
        localAccountSensitiveSettings.neverAskAboutUnfurlingAgain = value;
    }

    function setGifUnfurlingEnabled(value) {
        localAccountSensitiveSettings.gifUnfurlingEnabled = value
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

    function updateTransactionFilterIfDirty() {
        if (transactionActivityStatus.isFilterDirty)
            walletSectionInst.activityController.updateFilter()
    }

    function getCurrencyAmount(amount, symbol) {
        return currencyStore.getCurrencyAmount(amount, symbol)
    }

    function getFiatValue(balance, cryptoSymbol) {
        return currencyStore.getFiatValue(balance, cryptoSymbol)
    }

    function getCryptoValue(balance, cryptoSymbol) {
        return currencyStore.getCryptoValue(balance, cryptoSymbol)
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

    function fetchTxDetails(txID) {
        walletSectionInst.activityController.fetchTxDetails(txID)
        walletSectionInst.activityDetailsController.fetchExtraTxDetails()
    }

    function getTxDetails() {
        return walletSectionInst.activityDetailsController.activityDetails
    }

    property bool marketHistoryIsLoading: Global.appIsReady? walletSectionAllTokens.marketHistoryIsLoading : false

    function fetchHistoricalBalanceForTokenAsJson(address, tokenSymbol, currencySymbol, timeIntervalEnum) {
        if (Global.appIsReady)
            walletSectionAllTokens.fetchHistoricalBalanceForTokenAsJson(address, tokenSymbol, currencySymbol, timeIntervalEnum)
    }

    property bool balanceHistoryIsLoading: Global.appIsReady? walletSectionAllTokens.balanceHistoryIsLoading : false

}
