import QtQuick

QtObject {
    id: root

    property var dappBrowserAccount: browserSectionCurrentAccount
    property var accounts: walletSectionAccounts.accounts
    property string defaultCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase // FIXME

    function getEtherscanLink(chainID) {
        return networksModule.getBlockExplorerTxURL(chainID)
    }

    function switchAccountByAddress(address) {
        browserSectionCurrentAccount.switchAccountByAddress(address)
    }
}
