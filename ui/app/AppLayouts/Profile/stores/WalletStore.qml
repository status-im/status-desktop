import QtQuick 2.13

QtObject {
    id: root

    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test


    property var importedAccounts: walletSectionAccounts.imported
    property var generatedAccounts: walletSectionAccounts.generated
    property var watchOnlyAccounts: walletSectionAccounts.watchOnly
    property var walletTokensModule: walletSectionAllTokens
    property var defaultTokenList: walletSectionAllTokens.default
    property var customTokenList: walletSectionAllTokens.custom

    function addCustomToken(chainId, address, name, symbol, decimals) {
        return walletSectionAllTokens.addCustomToken(chainId, address, name, symbol, decimals)
    }

    function toggleVisible(chainId, symbol) {
        walletSectionAllTokens.toggleVisible(chainId, symbol)
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
}
