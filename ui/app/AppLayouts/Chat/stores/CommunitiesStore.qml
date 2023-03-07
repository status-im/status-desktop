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

    function getChainName(chainId) {
        return allNetworks.getNetworkFullName(chainId)
    }

    function getChainIcon(chainId) {
        return allNetworks.getIconUrl(chainId)
    }

    // Token holders model: MOCKED DATA -> TODO: Update with real data
    readonly property var holdersModel: ListModel {

        readonly property string image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                                         nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"

        Component.onCompleted:
            append([
                       {
                           ensName: "carmen.eth",
                           walletAddress: "0xb794f5450ba39494ce839613fffba74279579268",
                           imageSource:image,
                           amount: 3
                       },
                       {
                           ensName: "chris.eth",
                           walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
                           imageSource: image,
                           amount: 2
                       },
                       {
                           ensName: "emily.eth",
                           walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
                           imageSource: image,
                           amount: 2
                       },
                       {
                           ensName: "",
                           walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
                           imageSource: "",
                           amount: 1
                       }
                   ])
    }
}
