import QtQuick 2.15

import AppLayouts.Chat.controls.community 1.0

import StatusQ.Core.Utils 0.1

QtObject {
    id: root

    property var mainModuleInst: mainModule
    property var communitiesModuleInst: communitiesModule
    readonly property bool isOwner: false

    property var mintingModuleInst: mintingModule ?? null

    property var permissionConflict: QtObject { // Backend conflicts object model assignment. Now mocked data.
        property bool exists: false
        property string holdings: qsTr("1 ETH")
        property string permissions: qsTr("View and Post")
        property string channels: qsTr("#general")

    }

    property var assetsModel: chatCommunitySectionModule.tokenList
    property var collectiblesModel: chatCommunitySectionModule.collectiblesModel

    // TODO: Replace to real data, now dummy model
    property var  channelsModel: ListModel {
        ListElement { key: "welcome"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#welcome"}
        ListElement { key: "general"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#general"}
    }

    readonly property QtObject _d: QtObject {
        id: d

        property int keyCounter: 0

        function createPermissionEntry(holdings, permissionType, isPrivate, channels) {
            const permission = {
                holdingsListModel: holdings,
                channelsListModel: channels,
                permissionType,
                isPrivate
            }

            return permission
        }
    }

    function createPermission(holdings, permissionType, isPrivate, channels, index = null) {
        const permissionEntry = d.createPermissionEntry(
                                  holdings, permissionType, isPrivate, channels)
        chatCommunitySectionModule.createOrEditCommunityTokenPermission(root.mainModuleInst.activeSection.id, "", permissionEntry.permissionType, JSON.stringify(permissionEntry.holdingsListModel), permissionEntry.isPrivate)
    }

    function editPermission(key, holdings, permissionType, channels, isPrivate) {
        const permissionEntry = d.createPermissionEntry(
                                  holdings, permissionType, isPrivate, channels)

        chatCommunitySectionModule.createOrEditCommunityTokenPermission(root.mainModuleInst.activeSection.id, key, permissionEntry.permissionType, JSON.stringify(permissionEntry.holdingsListModel), permissionEntry.isPrivate)
    }

    function removePermission(key) {
        chatCommunitySectionModule.deleteCommunityTokenPermission(root.mainModuleInst.activeSection.id, key)
    }

    // Minting tokens:
    function mintCollectible(communityId, address, name, symbol, description, supply,
                             infiniteSupply, transferable, selfDestruct, chainId, artworkSource)
    {
        mintingModuleInst.mintCollectible(communityId, address, name, symbol, description, supply,
                                          infiniteSupply, transferable, selfDestruct, chainId, artworkSource)
    }

    // Network selection properties:
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all
}
