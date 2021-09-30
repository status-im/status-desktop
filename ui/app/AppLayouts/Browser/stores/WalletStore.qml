pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var dappBrowserAccount: walletModel.dappBrowserView.dappBrowserAccount
    property var accounts: walletModel.accountsView.accounts
    property string defaultCurrency: walletModel.balanceView.defaultCurrency
    property string signingPhrase: walletModel.utilsView.signingPhrase
    property string etherscanString: walletModel.utilsView.etherscanLink

    function setDappBrowserAddress() {
        walletModel.setDappBrowserAddress()
    }

    function getGasPrice(){
        walletModel.gasView.getGasPrice()
    }

}
