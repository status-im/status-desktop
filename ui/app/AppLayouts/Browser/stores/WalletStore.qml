pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var dappBrowserAccount: walletSectionAccounts.current
    property var accounts: walletSectionAccounts.model
    property string defaultCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase
    property string etherscanString: walletModel.utilsView.etherscanLink

    function setDappBrowserAddress() {
        walletModel.setDappBrowserAddress()
    }

    function getGasPrice(){
        walletModel.gasView.getGasPrice()
    }

}
