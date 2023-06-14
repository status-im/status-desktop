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
    signal airdropFeeUpdated(var airdropFees)
    signal burnFeeUpdated(var ethCurrency, var fiatCurrency, int error)

    signal deploymentStateChanged(string communityId, int status, string url)
    signal remoteDestructStateChanged(string communityId, string tokenName, int status, string url)
    signal burnStateChanged(string communityId, string tokenName, int status, string url)
    signal airdropStateChanged(string communityId, string tokenName, string chainName, int status, string url)

    // Minting tokens:
    function deployCollectible(communityId, collectibleItem)
    {        
        // TODO: Backend needs to create new role `accountName` and update this call accordingly
        // TODO: Backend will need to check if the collectibleItem has a valid tokenKey, so it means a deployment retry,
        // otherwise, it is a new deployment.
        // TODO: Backend needs to modify the call to expect an image JSON file with cropped artwork information:
        const jsonArtworkFile = Utils.getImageAndCropInfoJson(collectibleItem.artworkSource, collectibleItem.artworkCropRect)
        communityTokensModuleInst.deployCollectible(communityId, collectibleItem.accountAddress, collectibleItem.name,
                                                    collectibleItem.symbol, collectibleItem.description, collectibleItem.supply,
                                                    collectibleItem.infiniteSupply, collectibleItem.transferable, collectibleItem.remotelyDestruct,
                                                    collectibleItem.chainId, collectibleItem.artworkSource/*instead: jsonArtworkFile*/)
    }

    function deployAsset(communityId, assetItem)
    {
        // TODO: Backend needs to create new role `accountName` and update this call accordingly
        // TODO: Backend will need to check if the collectibleItem has a valid tokenKey, so it means a deployment retry,
        // otherwise, it is a new deployment.
        // TODO: Backend needs to modify the call to expect an image JSON file with cropped artwork information:
        const jsonArtworkFile = Utils.getImageAndCropInfoJson(assetItem.artworkSource, assetItem.artworkCropRect)
        communityTokensModuleInst.deployAssets(communityId, assetItem.accountAddress, assetItem.name,
                                               assetItem.symbol, assetItem.description, assetItem.supply,
                                               assetItem.infiniteSupply, assetItem.decimals, assetItem.chainId, assetItem.artworkSource/*instead: jsonArtworkFile*/)
    }

    function deleteToken(communityId, contractUniqueKey) {
        console.log("TODO: Delete token bakend!")
    }

    readonly property Connections connections: Connections {
        target: communityTokensModuleInst

        function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
            root.deployFeeUpdated(ethCurrency, fiatCurrency, errorCode)
        }

        function onSelfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
            root.selfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode)
        }

        function onAirdropFeesUpdated(jsonFees) {
            root.airdropFeeUpdated(JSON.parse(jsonFees))
        }

        function onDeploymentStateChanged(communityId, status, url) {
            root.deploymentStateChanged(communityId, status, url)
        }

        function onRemoteDestructStateChanged(communityId, tokenName, status, url) {
            root.remoteDestructStateChanged(communityId, tokenName, status, url)
        }

        function onAirdropStateChanged(communityId, tokenName, chainName, status, url) {
            root.airdropStateChanged(communityId, tokenName, chainName, status, url)
        }

        function onBurnStateChanged(communityId, tokenName, status, url) {
            root.burnStateChanged(communityId, tokenName, status, url)
        }

        function onBurnFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
            root.burnFeeUpdated(ethCurrency, fiatCurrency, errorCode)
        }
    }

    function computeDeployFee(chainId, accountAddress, tokenType) {
        communityTokensModuleInst.computeDeployFee(chainId, accountAddress, tokenType)
    }

    function computeSelfDestructFee(selfDestructTokensList, tokenKey) {
        communityTokensModuleInst.computeSelfDestructFee(JSON.stringify(selfDestructTokensList), tokenKey)
    }

    function remoteSelfDestructCollectibles(communityId, selfDestructTokensList, tokenKey) {
        communityTokensModuleInst.selfDestructCollectibles(communityId, JSON.stringify(selfDestructTokensList), tokenKey)
    }

    // Burn:
    function computeBurnFee(tokenKey, amount) {
        communityTokensModuleInst.computeBurnFee(tokenKey, amount)
    }

    function burnToken(communityId, tokenKey, burnAmount) {
        communityTokensModuleInst.burnCollectibles(communityId, tokenKey, burnAmount)
    }

    // Airdrop tokens:
    function airdrop(communityId, airdropTokens, addresses) {
        communityTokensModuleInst.airdropCollectibles(communityId, JSON.stringify(airdropTokens), JSON.stringify(addresses))
    }

    function computeAirdropFee(communityId, contractKeysAndAmounts, addresses) {
        communityTokensModuleInst.computeAirdropCollectiblesFee(
                    communityId, JSON.stringify(contractKeysAndAmounts),
                    JSON.stringify(addresses))
    }
}
