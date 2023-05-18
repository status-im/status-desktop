import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    property var communityTokensModuleInst: communityTokensModule ?? null

    // Network selection properties:
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all

    signal deployFeeUpdated(var ethCurrency, var fiatCurrency, int error)
    signal deploymentStateChanged(string communityId, int status, string url)
    signal selfDestructFeeUpdated(string value) // TO BE REMOVED
    signal burnFeeUpdated(string value) // TO BE REMOVED

    // Minting tokens:
    function deployCollectible(communityId, accountAddress, name, symbol, description, supply,
                             infiniteSupply, transferable, selfDestruct, chainId, artworkSource, accountName, artworkCropRect)
    {
        // TODO: Backend needs to create new role `accountName` and update this call accordingly
        // TODO: Backend needs to modify the call to expect an image JSON file with cropped artwork information:
        const jsonArtworkFile = Utils.getImageAndCropInfoJson(artworkSource, artworkCropRect)
        communityTokensModuleInst.deployCollectible(communityId, accountAddress, name, symbol, description, supply,
                                                    infiniteSupply, transferable, selfDestruct, chainId, artworkSource/*instead: jsonArtworkFile*/)
    }

    readonly property Connections connections: Connections {
      target: communityTokensModuleInst
      function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
          root.deployFeeUpdated(ethCurrency, fiatCurrency, errorCode)
      }
      function onDeploymentStateChanged(communityId, status, url) {
          root.deploymentStateChanged(communityId, status, url)
      }
    }

    function computeDeployFee(chainId, accountAddress) {
        communityTokensModuleInst.computeDeployFee(chainId, accountAddress)
    }

    // Remotely destruct:
    function computeSelfDestructFee(chainId) {
        // TODO BACKEND
        root.selfDestructFeeUpdated("0,0005 ETH")
        console.warn("TODO: Compute self-destruct fee backend")
    }

    function remoteSelfDestructCollectibles(selfDestructTokensList, chainId, accountName, accountAddress) {
        // TODO BACKEND
        // selfDestructTokensList is a js array with properties: `walletAddress` and `amount`
        console.warn("TODO: Remote self-destruct collectible backend")
    }

    // Burn:
    function computeBurnFee(chainId) {
        // TODO BACKEND
        root.burnFeeUpdated("0,0010 ETH")
        console.warn("TODO: Compute burn fee backend")
    }

    function burnCollectibles(tokenKey,burnAmount) {
        // TODO BACKEND
        console.warn("TODO: Burn collectible backend")
    }

    // Airdrop tokens:
    function airdrop(communityId, airdropTokens, addresses) {
        communityTokensModuleInst.airdropCollectibles(communityId, JSON.stringify(airdropTokens), JSON.stringify(addresses))
    }
}
