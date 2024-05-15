import QtQuick 2.15

QtObject {
    id: root

    /* TODO: all of these should come from their respective stores once the stores are reworked and
       streamlined. This store should contain only swap specific properties/methods if any */
    readonly property var accounts: walletSectionAccounts.accounts
    readonly property var flatNetworks: networksModule.flatNetworks
    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
}
