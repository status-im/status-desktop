import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusAssetSelector {
        getCurrencyBalanceString: function (currencyBalance) {
            return currencyBalance.toFixed(2) + " USD"
        }
        tokenAssetSourceFn: function (symbol) {
            return "../../assets/img/icons/snt.svg"
        }
        assets: ListModel {
            ListElement {
                address: "0x1234"
                name: "Status Network Token"
                balance: "20"
                symbol: "SNT"
                totalCurrencyBalance: 9992.01
                totalBalance: 9992.01
            }
            ListElement {
                address: "0x1234"
                name: "DAI Token"
                balance: "15"
                symbol: "DAI"
                totalCurrencyBalance: 20.00001
                totalBalance: 20.00001
            }
            ListElement {
                address: "0x1234"
                name: "ABYSS Token"
                balance: "25"
                symbol: "ABYSS"
                totalCurrencyBalance: 24.1
                totalBalance: 24.1
            }
        }
    }
}

