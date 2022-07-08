import QtQuick 2.13

import "../../Wallet/stores"

QtObject {
    id: root

    property var accountSensitiveSettings: localAccountSensitiveSettings

    property var areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    property var accounts: walletSectionAccounts.model
    property var importedAccounts: walletSectionAccounts.imported
    property var generatedAccounts: walletSectionAccounts.generated
    property var watchOnlyAccounts: walletSectionAccounts.watchOnly
    property var walletTokensModule: walletSectionAllTokens
    property var defaultTokenList: walletSectionAllTokens.default
    property var customTokenList: walletSectionAllTokens.custom


    property var currencyStore: CurrenciesStore {}

    function addCustomToken(chainId, address, name, symbol, decimals) {
        return walletSectionAllTokens.addCustomToken(chainId, address, name, symbol, decimals)
    }

    function toggleVisible(chainId, address) {
        walletSectionAllTokens.toggleVisible(chainId, address)
    }

    function removeCustomToken(chainId, address) {
        walletSectionAllTokens.removeCustomToken(chainId, address)
    }

    property var currentAccount: walletSectionCurrent

    function switchAccountByAddress(address) {
        walletSection.switchAccountByAddress(address)
    }

    function deleteAccount(address) {
        return walletSectionAccounts.deleteAccount(address)
    }

    function updateCurrentAccount(address, accountName, color, emoji) {
        return walletSectionCurrent.update(address, accountName, color, emoji)
    }

    property var dappList: dappPermissionsModule.dapps

    function disconnect(dappName) {
        dappPermissionsModule.disconnect(dappName)
    }

    function accountsForDapp(dappName) {
        return dappPermissionsModule.accountsForDapp(dappName)   
    }

    function disconnectAddress(dappName, address) {
        return dappPermissionsModule.disconnectAddress(dappName, address)
    }
}
