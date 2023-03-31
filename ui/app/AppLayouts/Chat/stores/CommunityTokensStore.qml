import QtQuick 2.15

QtObject {
    id: root

    property var rootStore
    property var communityTokensModuleInst: communityTokensModule ?? null

    // Network selection properties:
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all

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
                           amount: 3,
                           selfDestructAmount: 0,
                           selfDestruct: false
                       },
                       {
                           ensName: "chris.eth",
                           walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
                           imageSource: image,
                           amount: 2,
                           selfDestructAmount: 0,
                           selfDestruct: false
                       },
                       {
                           ensName: "emily.eth",
                           walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
                           imageSource: image,
                           amount: 2,
                           selfDestructAmount: 0,
                           selfDestruct: false
                       },
                       {
                           ensName: "",
                           walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
                           imageSource: "",
                           amount: 1,
                           selfDestructAmount: 0,
                           selfDestruct: false
                       }
                   ])
    }

    signal deployFeeUpdated(var ethCurrency, var fiatCurrency, int error)
    signal selfDestructFeeUpdated(string value) // TO BE REMOVED

    // Minting tokens:
    function deployCollectible(communityId, accountAddress, name, symbol, description, supply,
                             infiniteSupply, transferable, selfDestruct, chainId, artworkSource, accountName)
    {
        // TODO: Backend needs to create new role `accountName` and update this call accordingly
        communityTokensModuleInst.deployCollectible(communityId, accountAddress, name, symbol, description, supply,
                                                    infiniteSupply, transferable, selfDestruct, chainId, artworkSource)
    }

    readonly property Connections connections: Connections {
      target: communityTokensModuleInst
      function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
          root.deployFeeUpdated(ethCurrency, fiatCurrency, errorCode)
      }
    }

    function computeDeployFee(chainId, accountAddress) {
        communityTokensModuleInst.computeDeployFee(chainId, accountAddress)
    }

    function computeSelfDestructFee(chainId) {
        // TODO BACKEND
        root.selfDestructFeeUpdated("0,0005 ETH")
        console.warn("TODO: Compute self-destruct fee backend")
    }

    function remoteSelfDestructCollectibles(holdersModel, chainId, accountName, accountAddress) {
        // TODO BACKEND
        console.warn("TODO: Remote self-destruct collectible backend")
    }

    // Airdrop tokens:
    function airdrop(communityId, airdropTokens, addresses) {
        const addrArray = []
        for(var i = 0; i < addresses.length; i++) {
            addrArray.push(addresses[i]["text"])
        }
        communityTokensModuleInst.airdropCollectibles(communityId, JSON.stringify(airdropTokens), JSON.stringify(addrArray))
    }
}
