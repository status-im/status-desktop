pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var currentAccount: walletModel.accountsView.currentAccount
    property var accounts: walletSectionAccounts.model

    property string defaultCurrency: walletModel.balanceView.defaultCurrency
    property string totalFiatBalance: walletModel.balanceView.totalFiatBalance

    property var transactions: walletModel.transactionsView.transactions

    property var defaultTokenList: walletSectionAllTokens.default
    property var customTokenList: walletSectionAllTokens.custom
    property var tokens: walletSectionAllTokens.all

    property var assets: walletSectionAccountTokens.model

    property string signingPhrase: walletModel.utilsView.signingPhrase

    property bool mnemonicBackedUp: mnemonicModule.isBackedUp

    property var collectiblesList: walletModel.collectiblesView.collectiblesLists

    property var historyView: walletModel.historyView

    // This should be exposed to the UI via "walletModule", WalletModule should use
    // Accounts Service which keeps the info about that (isFirstTimeAccountLogin).
    // Then in the View of WalletModule we may have either QtProperty or
    // Q_INVOKABLE function (proc marked as slot) depends on logic/need.
    // The only need for onboardingModel here is actually to check if an account
    // has been just created or an old one.

    //property bool firstTimeLogin: onboardingModel.isFirstTimeLogin

    // example wallet model
    property ListModel exampleWalletModel: ListModel {
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            balance: "12.00 USD"
            iconColor: "#7CDA00"
        }

        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            iconColor: "#FA6565"
        }
        ListElement {
            name: "Status account"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            iconColor: "#7CDA00"
        }
    }

    property ListModel exampleAssetModel: ListModel {
        ListElement {
            value: "123 USD"
            symbol: "ETH"
            fullTokenName: "Ethereum"
            fiatBalanceDisplay: "3423 ETH"
            image: "token-icons/eth"
        }
    }

    function getLatestBlockNumber() {
        return walletModel.getLatestBlockNumber()
    }

    function isNonArchivalNode() {
        return walletModel.isNonArchivalNode
    }

    function setCurrentAccountByIndex(newIndex) {
        walletModel.setCurrentAccountByIndex(newIndex)
    }

    function setInitialRange() {
        walletModel.setInitialRange()
    }

    function generateNewAccount(password , accountName, color) {
        return walletModel.accountsView.generateNewAccount(password, accountName, color)
    }

    function changeAccountSettings(address, accountName, color) {
        return walletModel.accountsView.changeAccountSettings(address, accountName, color)
    }

    function deleteAccount(address) {
        return walletModel.accountsView.deleteAccount(address)
    }

    function addAccountsFromPrivateKey(privateKey, password, accountName, color) {
        return walletModel.accountsView.addAccountsFromPrivateKey(privateKey, password, accountName, color)
    }

    function addAccountsFromSeed(seedPhrase, password, accountName, color) {
        return walletModel.accountsView.addAccountsFromSeed(seedPhrase, password, accountName, color)
    }

    function addWatchOnlyAccount(address, accountName, color) {
        return walletModel.accountsView.addWatchOnlyAccount(address, accountName, color)
    }

    function setDefaultCurrency(key) {
        walletModel.balanceView.setDefaultCurrency(key)
    }

    function addCustomToken(address, name, symbol, decimals) {
        return walletModel.tokensView.addCustomToken(address, name, symbol, decimals)
    }

    function toggleAsset(symbol) {
        walletModel.tokensView.toggleAsset(symbol)
    }

    function removeCustomToken(address) {
        walletModel.tokensView.removeCustomToken(address)
    }

    function getQrCode(address) {
        return profileModel.qrCode(address)
    }

    function hex2Dec(value) {
        return utilsModel.hex2Dec(value)
    }

    function hex2Eth(value) {
        return utilsModel.hex2Eth(value)
    }

    function reloadCollectible(collectibleType) {
        walletModel.collectiblesView.reloadCollectible(collectibleType)
    }

    function checkRecentHistory() {
        walletModel.transactionsView.checkRecentHistory()
    }

    function isFetchingHistory() {
        return walletModel.historyView.isFetchingHistory(walletModel.accountsView.currentAccount.address)
    }

    function loadTransactionsForAccount(pageSize) {
        walletModel.historyView.loadTransactionsForAccount(walletModel.accountsView.currentAccount.address,
                                                           walletModel.transactionsView.transactions.getLastTxBlockNumber(),
                                                           pageSize, true)
    }
}
