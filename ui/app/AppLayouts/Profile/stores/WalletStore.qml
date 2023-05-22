import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    property var accountsModule
    property var networksModule

    property var accountSensitiveSettings: Global.appIsReady? localAccountSensitiveSettings : null

    property var areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var networks: networksModule.networks

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    // TODO(alaibe): there should be no access to wallet section, create collectible in profile
    property var overview: walletSectionOverview
    property var flatCollectibles: Global.appIsReady ? walletSectionCollectibles.model : null

    property var accounts: Global.appIsReady? accountsModule.accounts : null
    
    function deleteAccount(address) {
        return accountsModule.deleteAccount(address)
    }

    function updateAccount(address, accountName, colorId, emoji) {
        return accountsModule.updateAccount(address, accountName, colorId, emoji)
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
