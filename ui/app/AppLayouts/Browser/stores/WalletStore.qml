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
    }

    function getGasPrice(){
        // Not Refactored Yet
//        walletModel.gasView.getGasPrice()
    }

    function isEIP1559Enabled() {
        return walletSection.isEIP1559Enabled()
    }

}
