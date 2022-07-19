pragma Singleton

import QtQuick 2.13

import utils 1.0

QtObject {
    id: root
    property var currentAccount: Constants.isCppApp ? walletSectionAccounts.currentAccount: walletSectionCurrent
    property var accounts: walletSectionAccounts.model
    property var generatedAccounts: walletSectionAccounts.generated
    property var appSettings: localAppSettings
    property var accountSensitiveSettings: localAccountSensitiveSettings
    property string locale: appSettings.locale
    property bool hideSignPhraseModal: accountSensitiveSettings.hideSignPhraseModal

    property string currentCurrency: walletSection.currentCurrency
    property string totalCurrencyBalance: walletSection.totalCurrencyBalance
    property string signingPhrase: walletSection.signingPhrase
    property string mnemonicBackedUp: walletSection.isMnemonicBackedUp

    property var walletTokensModule: walletSectionAllTokens
    property var tokens: walletSectionAllTokens.all

    property CollectiblesStore collectiblesStore: CollectiblesStore { }
    property var collectionList: walletSectionCollectiblesCollections.model

    property var savedAddresses: walletSectionSavedAddresses.model

    // Used for new wallet account generation
    property var generatedAccountsViewModel: walletSectionAccounts.generatedAccounts
    property var derivedAddressesList: walletSectionAccounts.derivedAddresses

    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all

    property var cryptoRampServicesModel: walletSectionBuySellCrypto.model

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
            color: "#7CDA00"
        }

        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            color: "#FA6565"
        }
        ListElement {
            name: "Status account"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            color: "#7CDA00"
        }
    }

    property ListModel exampleAssetModel: ListModel {
        ListElement {
            name: "Ethereum"
            symbol: "ETH"
            balance: "3423 ETH"
            address: "token-icons/eth"
            currencyBalance: "123 USD"
        }
    }

    property bool derivedAddressesLoading: walletSectionAccounts.derivedAddressesLoading
    property string derivedAddressesError: walletSectionAccounts.derivedAddressesError

    function setHideSignPhraseModal(value) {
        localAccountSensitiveSettings.hideSignPhraseModal = value;
    }

    function getLatestBlockNumber() {
        // TODO: Move to transaction root module and not wallet
        // Not Refactored Yet
//        return walletModel.getLatestBlockNumber()
    }

    function setInitialRange() {
        // Not Refactored Yet
//        walletModel.setInitialRange()
    }

    function switchAccount(newIndex) {
        if(Constants.isCppApp)
            walletSectionAccounts.switchAccount(newIndex)
        else
            walletSection.switchAccount(newIndex)
    }

    function generateNewAccount(password, accountName, color, emoji, path, derivedFrom) {
        return walletSectionAccounts.generateNewAccount(password, accountName, color, emoji, path, derivedFrom)
    }

    function addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji) {
        return walletSectionAccounts.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)
    }

    function addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path) {
        return walletSectionAccounts.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path)
    }

    function addWatchOnlyAccount(address, accountName,color, emoji) {
        return walletSectionAccounts.addWatchOnlyAccount(address, accountName, color, emoji)
    }

    function deleteAccount(address) {
        return walletSectionAccounts.deleteAccount(address)
    }

    function updateCurrentAccount(address, accountName, color, emoji) {
        return walletSectionCurrent.update(address, accountName, color, emoji)
    }

    function updateCurrency(newCurrency) {
        walletSection.updateCurrency(newCurrency)
    }

    function getQrCode(address) {
        return globalUtils.qrCode(address)
    }

    function hex2Dec(value) {
        return globalUtils.hex2Dec(value)
    }

    function checkRecentHistory() {
        walletSection.checkRecentHistory()
    }

     function fetchCollectionCollectiblesList(slug) {
        walletSectionCollectiblesCollectibles.fetch(slug)
    }

    function getCollectionCollectiblesList(slug) {
        return walletSectionCollectiblesCollectibles.getModelForCollection(slug)
    }

    function getCollectionMaxValue(traitType, value, maxValue, collectionIndex) {
        // Not Refactored Yet
//        if(maxValue !== "")
//            return parseInt(value) + qsTr(" of ") + maxValue;
//        else
//            return parseInt(value) + qsTr(" of ") +
//            walletModelV2Inst.collectiblesView.collections.getCollectionTraitMaxValue(collectionIndex, traitType).toString();
    }

    function createOrUpdateSavedAddress(name, address) {
        return walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address)
    }

    function deleteSavedAddress(address) {
        return walletSectionSavedAddresses.deleteSavedAddress(address)
    }

    function toggleNetwork(chainId) {
        networksModule.toggleNetwork(chainId)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function getDerivedAddressList(password, derivedFrom, path, pageSize , pageNumber) {
        walletSectionAccounts.getDerivedAddressList(password, derivedFrom, path, pageSize , pageNumber)
    }

    function getDerivedAddressData(index) {
        return walletSectionAccounts.getDerivedAddressAtIndex(index)
    }

    function getDerivedAddressPathData(index) {
        return walletSectionAccounts.getDerivedAddressPathAtIndex(index)
    }

    function getDerivedAddressHasActivityData(index) {
        return walletSectionAccounts.getDerivedAddressHasActivityAtIndex(index)
    }

    function getDerivedAddressAlreadyCreatedData(index) {
        return walletSectionAccounts.getDerivedAddressAlreadyCreatedAtIndex(index)
    }

    function getDerivedAddressListForMnemonic(mnemonic, path, pageSize , pageNumber) {
        walletSectionAccounts.getDerivedAddressListForMnemonic(mnemonic, path, pageSize , pageNumber)
    }

    function getDerivedAddressForPrivateKey(privateKey) {
        walletSectionAccounts.getDerivedAddressForPrivateKey(privateKey)
    }

    function resetDerivedAddressModel() {
        walletSectionAccounts.resetDerivedAddressModel()
    }

    function vaildateMnemonic(mnemonic) {
        return onboardingModule.validateMnemonic(mnemonic)
    }

    function getNextSelectableDerivedAddressIndex() {
        return walletSectionAccounts.getNextSelectableDerivedAddressIndex()
    }
}
