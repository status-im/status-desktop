import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    property var accountsModule
    property var networksModule

    property var accountSensitiveSettings: Global.appIsReady? localAccountSensitiveSettings : null

    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    readonly property var networks: networksModule.networks
    readonly property var combinedNetworks: networksModule.combinedNetworks
    property var selectedAccount

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    // TODO(alaibe): there should be no access to wallet section, create collectible in profile
    property var overview: walletSectionOverview
    property var assets: walletSectionAssets.assets
    property var collectibles: Global.appIsReady ? walletSection.collectiblesController.model : null // To-do: Fetch profile collectibles separately
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

    function deleteKeypair(keyUid) {
        return accountsModule.deleteKeypair(keyUid)
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

    function getAllNetworksChainIds() {
        return networksModule.getAllNetworksChainIds()
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

    function updateWalletAccountPreferredChains(address, preferredChainIds) {
        if(areTestNetworksEnabled) {
            accountsModule.updateWalletAccountTestPreferredChains(address, preferredChainIds)
        }
        else {
            accountsModule.updateWalletAccountProdPreferredChains(address, preferredChainIds)
        }
    }

    function getNetworkShortNames(chainIds) {
       return networksModule.getNetworkShortNames(chainIds)
    }

    function processPreferredSharingNetworkToggle(preferredSharingNetworks, toggledNetwork) {
        let prefChains = preferredSharingNetworks
        if(prefChains.length === networks.count) {
            prefChains = [toggledNetwork.chainId.toString()]
        }
        else if(!prefChains.includes(toggledNetwork.chainId.toString())) {
            prefChains.push(toggledNetwork.chainId.toString())
        }
        else {
            if(prefChains.length === 1) {
                prefChains = getAllNetworksChainIds().split(":")
            }
            else {
                for(var i = 0; i < prefChains.length;i++) {
                    if(prefChains[i] === toggledNetwork.chainId.toString()) {
                        prefChains.splice(i, 1)
                    }
                }
            }
        }
        return prefChains
    }
}
