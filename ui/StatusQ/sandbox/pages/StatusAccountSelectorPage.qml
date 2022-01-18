import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Sandbox 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1


Column {
    spacing: 8

    StatusAccountSelector {
        id: accountSelector
        accounts: ListModel {
            ListElement {
                name: "Pascal"
                address: "0x1234567891011"
                path: ""
                color: "red"
                publicKey: ""
                walletType: "generated"
                isChat: ""
                currencyBalance:  "1199.02"
                assets: []
            }
            ListElement {
                name: "Boris"
                address: "0x123"
                path: ""
                color: "red"
                publicKey: ""
                walletType: "generated"
                isChat: ""
                currencyBalance:  "0"
                assets: []
            }
            ListElement {
                name: "Alexandra"
                address: "0x123"
                path: ""
                color: "yellow"
                publicKey: ""
                walletType: "generated"
                isChat: ""
                currencyBalance:  "0"
                assets: []
            }
            ListElement {
                name: "Khushboo"
                address: "0x123"
                path: ""
                color: "blue"
                publicKey: ""
                walletType: "generated"
                isChat: ""
                currencyBalance:  "0"
                assets: []
            }
        }
    }
}
