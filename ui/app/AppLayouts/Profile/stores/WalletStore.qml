import QtQuick 2.13

import "../../Wallet/stores"
import utils 1.0

QtObject {
    id: root

    property var accountSensitiveSettings: Global.appIsReady? localAccountSensitiveSettings : null

    property var areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    property var accounts: Global.appIsReady? walletSectionAccounts.model : null
    property var importedAccounts: Global.appIsReady? walletSectionAccounts.imported : null
    property var generatedAccounts: Global.appIsReady? walletSectionAccounts.generated : null
    property var watchOnlyAccounts: Global.appIsReady? walletSectionAccounts.watchOnly : null
    
    property var currentAccount: Global.appIsReady? walletSectionCurrent : null

    function switchAccountByAddress(address) {
        walletSection.switchAccountByAddress(address)
    }

    function deleteAccount(keyUid, address) {
        return walletSectionAccounts.deleteAccount(keyUid, address)
    }

    function updateCurrentAccount(address, accountName, color, emoji) {
        return walletSectionCurrent.update(address, accountName, color, emoji)
    }

    property var dappList: Global.appIsReady? dappPermissionsModule.dapps : null

    function disconnect(dappName) {
        dappPermissionsModule.disconnect(dappName)
    }

    function accountsForDapp(dappName) {
        return dappPermissionsModule.accountsForDapp(dappName)   
    }

    function disconnectAddress(dappName, address) {
        return dappPermissionsModule.disconnectAddress(dappName, address)
    }

    function loadDapps() {
        dappPermissionsModule.loadDapps()
    }
}
