import QtQuick

// Required mock of: src/app/modules/main/wallet_section/accounts/view.nim

Item {
    readonly property string contextPropertyName: "walletSectionAccounts"

    // Required
    //
    function getNameByAddress(address) {
        return "Name Mock " + address.substring(0, 5)
    }
}