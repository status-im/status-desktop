import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    property var accountsModule
    property var networksModule

    property var accountSensitiveSettings: Global.appIsReady? localAccountSensitiveSettings : null

    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    readonly property var combinedNetworks: networksModule.combinedNetworks
    property var selectedAccount

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    // TODO(alaibe): there should be no access to wallet section, create collectible in profile
    property var overview: walletSectionOverview
    property var flatCollectibles: Global.appIsReady ? walletSectionCollectibles.model : null
    property var assets: walletSectionAssets.assets
    property var accounts: Global.appIsReady? accountsModule.accounts : null
    property var originModel: accountsModule.keyPairModel
    property bool includeWatchOnlyAccount: accountsModule.includeWatchOnlyAccount

    function toggleIncludeWatchOnlyAccount() {
       accountsModule.toggleIncludeWatchOnlyAccount()
    }

    property string userProfilePublicKey: userProfile.pubKey
    
    function deleteAccount(address) {
        return accountsModule.deleteAccount(address)
    }

    function updateAccount(address, accountName, colorId, emoji) {
        return accountsModule.updateAccount(address, accountName, colorId, emoji)
    }

    function moveAccount(from, to) {
        root.accountsModule.moveAccount(from, to)
    }

    function moveAccountFinally(from, to) {
        root.accountsModule.moveAccountFinally(from, to)
    }

    function getAllNetworksSupportedPrefix() {
        return networksModule.getAllNetworksSupportedPrefix()
    }

    function runAddAccountPopup() {
        walletSection.runAddAccountPopup(false)
    }

    function evaluateRpcEndPoint(url) {
        return networksModule.fetchChainIdForUrl(url)
    }

    function updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl) {
        networksModule.updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl)
    }
}
