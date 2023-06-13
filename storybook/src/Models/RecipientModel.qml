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
            from: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756ccx"
            to: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
            checked: true
            allChecked: true
        }

        ListElement {
            from: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756ccx"
            to: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
            checked: true
            allChecked: true
        }

        ListElement {
            from: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756ccx"
            to: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
            checked: true
            allChecked: true
        }
    }
}
