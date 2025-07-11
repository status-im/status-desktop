import QtQuick

ListModel {
    id: root

    ListElement {
        symbol: "WBTC"
        amount: "0.00017"
        address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
        chainId: 1 // main
    }
    ListElement {
        symbol: "ETH"
        amount: "12345.6789"
        address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"
        chainId: 10 // Opti
    }
}
