pragma Singleton

import QtQuick 2.13

import utils 1.0
import shared.stores 1.0 as SharedStore

import "../panels"

QtObject {
    id: root

    readonly property int defaultSelectedType: SelectGeneratedAccount.AddAccountType.GenerateNew
    readonly property string defaultSelectedKeyUid: userProfile.keyUid
    readonly property bool defaultSelectedKeyUidMigratedToKeycard: userProfile.isKeycardUser

    property bool loggedInUserAuthenticated: false

    property string backButtonName: ""
    property var currentAccount: Constants.isCppApp ? walletSectionAccounts.currentAccount: walletSectionCurrent
    property var accounts: walletSectionAccounts.model
    property var generatedAccounts: walletSectionAccounts.generated
    property var appSettings: localAppSettings
    property var accountSensitiveSettings: localAccountSensitiveSettings
    property string locale: Qt.locale().name
    property bool hideSignPhraseModal: accountSensitiveSettings.hideSignPhraseModal

    property var currencyStore: SharedStore.RootStore.currencyStore
    property string currentCurrency: currencyStore.currentCurrency
    property string totalCurrencyBalance: walletSection.totalCurrencyBalance
    property string signingPhrase: walletSection.signingPhrase
    property string mnemonicBackedUp: walletSection.isMnemonicBackedUp

    property var collections: walletSectionCollectibles.model
    property var currentCollectible: walletSectionCurrentCollectible

    property var savedAddresses: walletSectionSavedAddresses.model

    // Used for new wallet account generation
    property var generatedAccountsViewModel: walletSectionAccounts.generatedAccounts
    property var derivedAddressesList: walletSectionAccounts.derivedAddresses

    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all
    property var layer1NetworksProxy: networksModule.layer1Proxy
    property var layer2NetworksProxy: networksModule.layer2Proxy

    property var cryptoRampServicesModel: walletSectionBuySellCrypto.model

    // This should be exposed to the UI via "walletModule", WalletModule should use
    // Accounts Service which keeps the info about that (isFirstTimeAccountLogin).
    // Then in the View of WalletModule we may have either QtProperty or
    // Q_INVOKABLE function (proc marked as slot) depends on logic/need.
    // The only need for onboardingModel here is actually to check if an account
    // has been just created or an old one.

    //property bool firstTimeLogin: onboardingModel.isFirstTimeLogin

    property ListModel exampleSavedAddresses: ListModel {
        ListElement {
            name: "Saved address 1"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            favourite: false
            ens: "ens 1"
        }

        ListElement {
            name: "Saved address 2"
            address: "0xadfaf08bbcbcb80760e8cb9a3c1232d19662adfa"
            favourite: true
            ens: "ens 2"
        }

        ListElement {
            name: "Saved address 3"
            address: "0xccccf08bbcbcb80760e8cb9a3c1232d19662cccc"
            favourite: true
            ens: "ens 3"
        }
    }

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

    function addNewWalletAccountGeneratedFromKeycard(accountType, accountName, color, emoji) {
        return walletSectionAccounts.addNewWalletAccountGeneratedFromKeycard(accountType, accountName, color, emoji)
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

    function fetchCollectibles(slug) {
        walletSectionCollectibles.fetchCollectibles(slug)
    }

    function getCollectionMaxValue(traitType, value, maxValue, collectionIndex) {
        // Not Refactored Yet
//        if(maxValue !== "")
//            return parseInt(value) + qsTr(" of ") + maxValue;
//        else
//            return parseInt(value) + qsTr(" of ") +
//            walletModelV2Inst.collectiblesView.collections.getCollectionTraitMaxValue(collectionIndex, traitType).toString();
    }

    function selectCollectible(slug, id) {
        walletSectionCurrentCollectible.update(slug, id)
    }

    function createOrUpdateSavedAddress(name, address, favourite) {
        return walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address, favourite)
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

    function getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber, hashPassword) {
        walletSectionAccounts.getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber, hashPassword)
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

    function validSeedPhrase(mnemonic) {
        return walletSectionAccounts.validSeedPhrase(mnemonic)
    }

    function getNextSelectableDerivedAddressIndex() {
        return walletSectionAccounts.getNextSelectableDerivedAddressIndex()
    }

    function authenticateUser() {
        walletSectionAccounts.authenticateUser()
    }

    function loggedInUserUsesBiometricLogin() {
        return userProfile.usingBiometricLogin
    }

    function loggedInUserIsKeycardUser() {
        return userProfile.isKeycardUser
    }

    function createSharedKeycardModule() {
        walletSectionAccounts.createSharedKeycardModule()
    }

    function destroySharedKeycarModule() {
        walletSectionAccounts.destroySharedKeycarModule()
    }

    function authenticateUserAndDeriveAddressOnKeycardForPath(keyUid, derivationPath) {
        walletSectionAccounts.authenticateUserAndDeriveAddressOnKeycardForPath(keyUid, derivationPath)
    }
}
