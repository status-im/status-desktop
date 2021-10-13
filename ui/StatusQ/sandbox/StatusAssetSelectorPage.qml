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
        assets: ListModel {
            ListElement {
                address: "0x1234"
                name: "Status Network Token"
                value: "20"
                symbol: "SNT"
                fiatBalance: "9992.01"
                fiatBalanceDisplay: "9992.01"
            }
            ListElement {
                address: "0x1234"
                name: "DAI Token"
                value: "20"
                symbol: "DAI"
                fiatBalance: "20"
                fiatBalanceDisplay: "20"
            }
        }
    }
}

