import QtQuick 2.15

QtObject {

    readonly property var savedAddresses: ListModel {

        ListElement {
            name: "John"
            address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
            ens: ""
            favourite: true
            chainShortNames: "eth:arb:opt"
            isTest: false
            checked: true
            allChecked: true
        }

        ListElement {
            name: "Anthony"
            address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756ccx"
            ens: "anthony.statusofus.eth"
            favourite: true
            chainShortNames: ""
            isTest: false
            checked: true
            allChecked: true
        }

        ListElement {
            name: "Iuri"
            address: "0xb794f5ea0ba39494ce839613fffba74279579268"
            ens: ""
            favourite: true
            chainShortNames: "eth:"
            isTest: false
            checked: true
            allChecked: true
        }
    }

    readonly property var recents: ListModel {
        ListElement {
            from: "0x2a4baa88a3924c2c99072918688032c2142cd9f6"
            to: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            checked: true
            allChecked: true
        }

        ListElement {
            from: "0x0910a46b3b99d4781e9841df0fd02ea1b95178c6"
            to: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            checked: true
            allChecked: true
        }

        ListElement {
            from: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            to: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            checked: true
            allChecked: true
        }
    }
}
