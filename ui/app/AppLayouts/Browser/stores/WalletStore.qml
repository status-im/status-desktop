pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var dappBrowserAccount: browserSectionCurrentAccount
    property var accounts: walletSectionAccounts.model
    property string defaultCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase
    
    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
    }


    function switchAccountByAddress(address) {
        browserSectionCurrentAccount.switchAccountByAddress(address)
        walletSectionTransactions.setModel(address)
    }

}
