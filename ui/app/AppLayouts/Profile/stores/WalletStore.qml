import QtQuick 2.15

import utils 1.0

import StatusQ 0.1
import StatusQ.Models 0.1

import SortFilterProxyModel 0.2

QtObject {
    id: root

    property var walletModule
    property var accountsModule: root.walletModule.accountsModule
    property var networksModuleInst: networksModule
    property var collectibles: _jointCollectiblesBySymbolModel

    property var accountSensitiveSettings: Global.appIsReady? localAccountSensitiveSettings : null

    readonly property bool areTestNetworksEnabled: networksModuleInst.areTestNetworksEnabled

    readonly property var combinedNetworks: networksModuleInst.combinedNetworks

    property var flatNetworks: networksModuleInst.flatNetworks
    property SortFilterProxyModel filteredFlatModel: SortFilterProxyModel {
        sourceModel: root.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled }
    }

    property var rpcProviders: networksModuleInst.rpcProviders

    property var selectedAccount

    property var networkRPCChanged: ({}) // add network id to the object if changed

    function toggleTestNetworksEnabled(){
        networksModuleInst.toggleTestNetworksEnabled()
    }
    // TODO(alaibe): there should be no access to wallet section, create collectible in profile
    property var overview: walletSectionOverview
    property var accounts: Global.appIsReady? accountsModule.accounts : null
    property var originModel: accountsModule.keyPairModel
    property var ownAccounts: SortFilterProxyModel {
        sourceModel: root.accounts
        proxyRoles: [
            FastExpressionRole {
                name: "color"

                function getColor(colorId) {
                    return Utils.getColorForId(colorId)
                }

                // Direct call for singleton function is not handled properly by
                // SortFilterProxyModel that's why helper function is used instead.
                expression: { return getColor(model.colorId) }
                expectedRoles: ["colorId"]
            }
        ]
        filters: ValueFilter {
            roleName: "walletType"
            value: Constants.watchWalletType
            inverted: true
        }
    }

    /* PRIVATE: This model renames the roles
        1. "id" to "communityId"
        2. "name" to "communityName"
        3. "image" to "communityImage"
        4. "description" to "communityDescription"
        in communitiesModule.model so that it can be easily
        joined with the Collectibles model */
    readonly property var _renamedCommunitiesModel: RolesRenamingModel {
        sourceModel: communitiesModule.model
        mapping: [
            RoleRename {
                from: "id"
                to: "communityId"
            },
            RoleRename {
                from: "name"
                to: "communityName"
            },
            RoleRename {
                from: "image"
                to: "communityImage"
            },
            RoleRename {
                from: "description"
                to: "communityDescription"
            }
        ]
    }

    /* PRIVATE: This model joins the "Tokens By Symbol Model" and "Communities Model" by communityId */
    property LeftJoinModel _jointCollectiblesBySymbolModel: LeftJoinModel {
        leftModel: root.walletModule.collectiblesModel
        rightModel: _renamedCommunitiesModel
        joinRole: "communityId"
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

    function setSelectedAccount(address) {
        root.accountsModule.setSelectedAccount(address)
    }

    function runAddAccountPopup() {
        // TODO:
        // - `runAddAccountPopup` should be part of `root.walletModule`
        // - `AddAccountPopup {}` should be moved from `MainView` to `WalletView`
        // - `Edit account` popup opened from the wallet settings should be the same as one opened from the wallet section
        // - `walletSection` should not be used in the context of wallet settings
        walletSection.runAddAccountPopup(false)
    }

    function runKeypairImportPopup(keyUid, mode) {
        root.walletModule.runKeypairImportPopup(keyUid, mode)
    }

    function evaluateRpcEndPoint(url, isMainUrl) {
        return networksModuleInst.fetchChainIdForUrl(url, isMainUrl)
    }

    function updateNetworkEndPointValues(chainId, testNetwork, newMainRpcInput, newFailoverRpcUrl) {
        networksModuleInst.updateNetworkEndPointValues(chainId, testNetwork, newMainRpcInput, newFailoverRpcUrl)
    }

    function updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance) {
        accountsModule.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
    }

    function getRpcStats() {
        return root.walletModule.getRpcStats()
    }

    function resetRpcStats() {
        root.walletModule.resetRpcStats()
    }
}
