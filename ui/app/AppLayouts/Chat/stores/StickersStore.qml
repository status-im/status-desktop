import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var stickersModule

    function getSigningPhrase() {
        if(!root.stickersModule)
            return ""
        return stickersModule.getSigningPhrase()
    }

    function getStickersMarketAddress() {
        if(!root.stickersModule)
            return ""
        return stickersModule.getStickersMarketAddress()
    }

    function getWalletDefaultAddress() {
        if(!root.stickersModule)
            return ""
        return stickersModule.getWalletDefaultAddress()
    }

    function getCurrentCurrency() {
        if(!root.stickersModule)
            return ""
        return stickersModule.getCurrentCurrency()
    }

    function getGasEthValue(gweiValue, gasLimit) {
        if(!root.stickersModule)
            return ""
        return stickersModule.getGasEthValue(gweiValue, gasLimit)
    }

    function getStatusTokenKey() {
        if(!root.stickersModule)
            return ""
        return stickersModule.getStatusTokenKey()
    }

    function estimate(packId, selectedAccount, price, uuid) {
        if(!root.stickersModule)
            return 0
        return stickersModule.estimate(packId, selectedAccount, price, uuid)
    }

    function authenticateAndBuy(packId, address, price, gasLimit, gasPrice, tipLimit, overallLimit, eip1559Enabled) {
        if(!root.stickersModule)
            return ""
        return stickersModule.authenticateAndBuy(packId, address, price, gasLimit, gasPrice, tipLimit, overallLimit, eip1559Enabled)
    }
}

