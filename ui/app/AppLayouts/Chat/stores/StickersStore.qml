import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var stickersModule

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


    function getStatusTokenKey() {
        if(!root.stickersModule)
            return ""
        return stickersModule.getStatusTokenKey()
    }
}

