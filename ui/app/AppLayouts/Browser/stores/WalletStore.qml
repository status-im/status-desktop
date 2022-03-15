pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var dappBrowserAccount: walletSectionCurrent
    property var accounts: walletSectionAccounts.model
    property string defaultCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase
    // Not Refactored Yet
    
    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
    }


    function setDappBrowserAddress() {
        // Not Refactored Yet
//        walletModel.setDappBrowserAddress()
    }

    function getGasPrice(){
        // Not Refactored Yet
//        walletModel.gasView.getGasPrice()
    }

    function isEIP1559Enabled() {
        return walletSection.isEIP1559Enabled()
    }

}
