import QtQuick 2.15

// Required mock of: src/app/modules/main/wallet_section/accounts/view.nim

Item {
    readonly property string contextPropertyName: "walletSectionAccounts"

    // Required
    //
    function getNameByAddress(address) {
        return "Name Mock " + address.substring(0, 5)
    }

    //
    // Silence warnings
    readonly property QtObject overview: QtObject {
        readonly property string mixedcaseAddress: ""
    }
    readonly property ListModel mixedcaseAddress: ListModel {}

    signal walletAccountRemoved(string address)
}