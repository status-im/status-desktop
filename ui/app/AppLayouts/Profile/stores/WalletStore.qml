import QtQuick 2.13

import shared.stores 1.0 as SharedStore
import "../../Wallet/stores"

QtObject {
    id: root

    property var accountSensitiveSettings: localAccountSensitiveSettings

    property var areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    property var accounts: walletSectionAccounts.model
    property var importedAccounts: walletSectionAccounts.imported
    property var generatedAccounts: walletSectionAccounts.generated
    property var watchOnlyAccounts: walletSectionAccounts.watchOnly

    property var currencyStore: SharedStore.RootStore.currencyStore

    property var currentAccount: walletSectionCurrent

    function switchAccountByAddress(address) {
        walletSection.switchAccountByAddress(address)
    }

    function deleteAccount(keyUid, address) {
        return walletSectionAccounts.deleteAccount(keyUid, address)
    }

    function updateCurrentAccount(address, accountName, color, emoji) {
        return walletSectionCurrent.update(address, accountName, color, emoji)
    }

    property var dappList: dappPermissionsModule.dapps

    function disconnect(dappName) {
        dappPermissionsModule.disconnect(dappName)
    }

    function accountsForDapp(dappName) {
        return dappPermissionsModule.accountsForDapp(dappName)   
    }

    function disconnectAddress(dappName, address) {
        return dappPermissionsModule.disconnectAddress(dappName, address)
    }
}
