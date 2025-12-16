import QtQuick

ListModel {
    id: root

    ListElement {
        tokenKey: "1-0xbbc2000000000000000000000000000000550567"
        symbol: "DAI"
        amount: "0.00017"
        receiver: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
        logoUri: ""
    }
    ListElement {
        tokenKey: "10-0x0000000000000000000000000000000000000000"
        symbol: "ETH"
        amount: "12345.6789"
        receiver: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"
        logoUri: ""
    }
}
