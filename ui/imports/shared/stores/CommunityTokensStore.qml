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
    signal selfDestructFeeUpdated(var ethCurrency, var fiatCurrency, int error)

    signal deploymentStateChanged(string communityId, int status, string url)

    signal burnFeeUpdated(string value) // TO BE REMOVED

    signal remoteDestructStateChanged(string communityId, string tokenName, int status, string url)

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

    function deployAsset(communityId, accountAddress, name, symbol, description, supply,
                         infiniteSupply, decimals, chainId, artworkSource, accountName, artworkCropRect)
    {
        // TODO: Backend needs to create new role `accountName` and update this call accordingly
        // TODO: Backend needs to modify the call to expect an image JSON file with cropped artwork information:
        const jsonArtworkFile = Utils.getImageAndCropInfoJson(artworkSource, artworkCropRect)
        console.log("TODO: Deploy Asset backend!")
    }

    function deleteToken(communityId, contractUniqueKey) {
        console.log("TODO: Delete token bakend!")
    }

    function retryMintToken(communityId, contractUniqueKey) {
        console.log("TODO: Retry mint token bakend!")
    }

    readonly property Connections connections: Connections {
      target: communityTokensModuleInst
      function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
          root.deployFeeUpdated(ethCurrency, fiatCurrency, errorCode)
      }
      function onSelfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
          root.selfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode)
      }
      function onDeploymentStateChanged(communityId, status, url) {
          root.deploymentStateChanged(communityId, status, url)
      }
      function onRemoteDestructStateChanged(communityId, tokenName, status, url) {
          root.remoteDestructStateChanged(communityId, tokenName, status, url)
      }
    }

    function computeDeployFee(chainId, accountAddress) {
        communityTokensModuleInst.computeDeployFee(chainId, accountAddress)
    }

    function computeSelfDestructFee(selfDestructTokensList, tokenKey) {
        communityTokensModuleInst.computeSelfDestructFee(JSON.stringify(selfDestructTokensList), tokenKey)
    }

    function remoteSelfDestructCollectibles(communityId, selfDestructTokensList, tokenKey) {
        communityTokensModuleInst.selfDestructCollectibles(communityId, JSON.stringify(selfDestructTokensList), tokenKey)
    }

    // Burn:
    function computeBurnFee(chainId) {
        // TODO BACKEND
        root.burnFeeUpdated("0,0010 ETH")
        console.warn("TODO: Compute burn fee backend")
    }

    function burnCollectibles(tokenKey, burnAmount) {
        // TODO BACKEND
        console.warn("TODO: Burn collectible backend")
    }

    // Airdrop tokens:
    function airdrop(communityId, airdropTokens, addresses) {
        communityTokensModuleInst.airdropCollectibles(communityId, JSON.stringify(airdropTokens), JSON.stringify(addresses))
    }
}
