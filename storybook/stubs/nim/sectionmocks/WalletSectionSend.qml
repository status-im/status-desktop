import QtQuick

// Required mock of: src/app/modules/main/wallet_section/send/view.nim

Item {
    readonly property string contextPropertyName: "walletSectionSend"

    // Silence warnings
    readonly property ListModel accounts: ListModel {}
    readonly property QtObject selectedReceiveAccount: QtObject {}

}