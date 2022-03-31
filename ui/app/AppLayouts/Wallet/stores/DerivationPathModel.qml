pragma Singleton

import QtQuick 2.13

QtObject {
    id: root
    property ListModel derivationPaths: ListModel {
        ListElement {
            name: "Default"
            path: "m/44'/60'/0'/0"
        }
        ListElement {
            name: "Ethereum Classic"
            path: "m/44'/61'/0'/0"
        }
        ListElement {
            name: "Ethereum (Ledger)"
            path: "m/44'/60'/0'"
        }
        ListElement {
            name: "Ethereum Classic (Ledger)"
            path: "m/44'/60'/160720'/0"
        }
        ListElement {
            name: "Ethereum Classic (Ledger, Vintage MEW)"
            path: "m/44'/60'/160720'/0'"
        }
        ListElement {
            name: "Ethereum (KeepKey)"
            path: "m/44'/60'"
        }
        ListElement {
            name: "Ethereum Classic (KeepKey)"
            path: "m/44'/61'"
        }
    }
}
