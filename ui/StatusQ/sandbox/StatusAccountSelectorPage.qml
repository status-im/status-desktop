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

    StatusAccountSelector {
        accounts: ListModel {
            ListElement {
                name: "Pascal"
                address: "0x1234567891011"
                iconColor: "red"
                balance: "0"
                walletType: "generated"
                assets: []
                fiatBalance: "1199.02"
            }
            ListElement {
                name: "Boris"
                address: "0x123"
                iconColor: "red"
                balance: "0"
                walletType: "generated"
                assets: []
                fiatBalance: "0"
            }
            ListElement {
                name: "Alexandra"
                address: "0x123"
                iconColor: "yellow"
                balance: "0"
                walletType: "generated"
                assets: []
                fiatBalance: "0"
            }
            ListElement {
                name: "Khushboo"
                address: "0x123"
                iconColor: "blue"
                balance: "0"
                walletType: "generated"
                assets: []
                fiatBalance: "0"
            }
        }
    }
}
