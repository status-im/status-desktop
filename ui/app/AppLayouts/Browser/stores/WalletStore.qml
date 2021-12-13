pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var dappBrowserAccount: walletSectionCurrent
    property var accounts: walletSectionAccounts.model
    property string defaultCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase
    // Not Refactored Yet
    property string etherscanString: ""// walletModel.utilsView.etherscanLink

    function setDappBrowserAddress() {
        // Not Refactored Yet
//        walletModel.setDappBrowserAddress()
    }

    function getGasPrice(){
        // Not Refactored Yet
//        walletModel.gasView.getGasPrice()
    }

}
