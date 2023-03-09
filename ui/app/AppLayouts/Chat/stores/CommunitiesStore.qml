import QtQuick 2.15


QtObject {
    id: root

    property var communityTokensModuleInst: communityTokensModule ?? null

    // Minting tokens:
    function deployCollectible(communityId, address, name, symbol, description, supply,
                             infiniteSupply, transferable, selfDestruct, chainId, artworkSource)
    {
        communityTokensModuleInst.deployCollectible(communityId, address, name, symbol, description, supply,
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
