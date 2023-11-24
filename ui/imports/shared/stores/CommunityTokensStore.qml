import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    property var communityTokensModuleInst: communityTokensModule ?? null

    // Network selection properties:
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all

    // set by asyncGetOwnerTokenDetails
    readonly property var ownerTokenDetails: {
        JSON.parse(communityTokensModuleInst.ownerTokenDetails)
    }

    signal deployFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)
    signal selfDestructFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)
    signal airdropFeeUpdated(var airdropFees)
    signal burnFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)
    signal setSignerFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)

    signal deploymentStateChanged(string communityId, int status, string url)
    signal ownerTokenDeploymentStateChanged(string communityId, int status, string url)
    signal remoteDestructStateChanged(string communityId, string tokenName, int status, string url)
    signal burnStateChanged(string communityId, string tokenName, int status, string url)
    signal airdropStateChanged(string communityId, string tokenName, string chainName, int status, string url)
    signal ownerTokenDeploymentStarted(string communityId, string url)
    signal setSignerStateChanged(string communityId, string communityName, int status, string url)
    signal ownershipLost(string communityId, string communityName)
    signal communityOwnershipDeclined(string communityName)
    signal sendOwnerTokenStateChanged(string tokenName, int status, string url)
    signal ownerTokenReceived(string communityId, string communityName)

    // Minting tokens:
    function deployCollectible(communityId, collectibleItem)
    {
        if (collectibleItem.key !== "")
            deleteToken(communityId, collectibleItem.key)

        const jsonArtworkFile = Utils.getImageAndCropInfoJson(collectibleItem.artworkSource, collectibleItem.artworkCropRect)
        communityTokensModuleInst.deployCollectible(communityId, collectibleItem.accountAddress, collectibleItem.name,
                                                    collectibleItem.symbol, collectibleItem.description, collectibleItem.supply,
                                                    collectibleItem.infiniteSupply, collectibleItem.transferable, collectibleItem.remotelyDestruct,
                                                    collectibleItem.chainId, jsonArtworkFile)
    }

    function deployAsset(communityId, assetItem)
    {
        if (assetItem.key !== "")
            deleteToken(communityId, assetItem.key)

        const jsonArtworkFile = Utils.getImageAndCropInfoJson(assetItem.artworkSource, assetItem.artworkCropRect)
        communityTokensModuleInst.deployAssets(communityId, assetItem.accountAddress, assetItem.name,
                                               assetItem.symbol, assetItem.description, assetItem.supply,
                                               assetItem.infiniteSupply, assetItem.decimals, assetItem.chainId, jsonArtworkFile)
    }

    function deployOwnerToken(communityId, ownerToken, tMasterToken)
    {
        const jsonArtworkFile = Utils.getImageAndCropInfoJson(ownerToken.artworkSource, ownerToken.artworkCropRect)
        communityTokensModuleInst.deployOwnerToken(communityId, ownerToken.accountAddress, ownerToken.name, ownerToken.symbol, ownerToken.description,
                                                   tMasterToken.name, tMasterToken.symbol, tMasterToken.description, ownerToken.chainId, jsonArtworkFile)
    }

    function deleteToken(communityId, contractUniqueKey) {
        let parts = contractUniqueKey.split("_");
        communityTokensModuleInst.removeCommunityToken(communityId, parts[0], parts[1])
    }

    function updateSmartContract(communityId, chainId, contractAddress, accountAddress) {
        communityTokensModuleInst.setSigner(communityId, chainId, contractAddress, accountAddress)
    }

    function ownershipDeclined(communityId, communityName) {
            communityTokensModuleInst.declineOwnership(communityId)
            root.communityOwnershipDeclined(communityName)
        }

    readonly property Connections connections: Connections {
        target: communityTokensModuleInst

        function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.deployFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
        }

        function onSelfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.selfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
        }

        function onAirdropFeesUpdated(jsonFees) {
            root.airdropFeeUpdated(JSON.parse(jsonFees))
        }

        function onBurnFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.burnFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
        }

        function onSetSignerFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.setSignerFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
        }

        function onDeploymentStateChanged(communityId, status, url) {
            root.deploymentStateChanged(communityId, status, url)
        }

        function onOwnerTokenDeploymentStateChanged(communityId, status, url) {
            root.ownerTokenDeploymentStateChanged(communityId, status, url)
        }

        function onOwnerTokenDeploymentStarted(communityId, url) {
            root.ownerTokenDeploymentStarted(communityId, url)
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

        function onOwnerTokenReceived(communityId, communityName, chainId, communityAddress) {
            root.ownerTokenReceived(communityId, communityName)
        }

        function onSetSignerStateChanged(communityId, communityName, status, url) {
            root.setSignerStateChanged(communityId, communityName, status, url)
        }

        function onOwnershipLost(communityId, communityName) {
            root.ownershipLost(communityId, communityName)
        }

        function onSendOwnerTokenStateChanged(tokenName, status, url) {
            root.sendOwnerTokenStateChanged(tokenName, status, url)
        }
    }

    // Burn:
    function computeBurnFee(tokenKey, amount, accountAddress, requestId) {
        console.assert(typeof amount === "string")
        communityTokensModuleInst.computeBurnFee(tokenKey, amount, accountAddress, requestId)
    }

    function computeAirdropFee(communityId, contractKeysAndAmounts, addresses, feeAccountAddress, requestId) {
        communityTokensModuleInst.computeAirdropFee(
                    communityId, JSON.stringify(contractKeysAndAmounts),
                    JSON.stringify(addresses), feeAccountAddress, requestId)
    }

    function computeDeployFee(communityId, chainId, accountAddress, tokenType, isOwnerDeployment, requestId) {
        communityTokensModuleInst.computeDeployFee(communityId, chainId, accountAddress, tokenType, isOwnerDeployment, requestId)
    }

    function computeSetSignerFee(chainId, contractAddress, accountAddress, requestId) {
        communityTokensModuleInst.computeSetSignerFee(chainId, contractAddress, accountAddress, requestId)
    }

    /**
      * walletsAndAmounts - array of following structure is expected:
      * [
      *   {
      *      walletAddress: string
      *      amount: int
      *   }
      * ]
      */
    function computeSelfDestructFee(walletsAndAmounts, tokenKey, accountAddress, requestId) {
        communityTokensModuleInst.computeSelfDestructFee(JSON.stringify(walletsAndAmounts), tokenKey, accountAddress, requestId)
    }

    function remoteSelfDestructCollectibles(communityId, walletsAndAmounts, tokenKey, accountAddress) {
        communityTokensModuleInst.selfDestructCollectibles(communityId, JSON.stringify(walletsAndAmounts), tokenKey, accountAddress)
    }

    function remotelyDestructAndBan(communityId, contactId, tokenKey, accountAddress, deleteMessages) {
        console.warn("remotelyDestructAndBan, not implemented yet!")
    }

    function remotelyDestructAndKick(communityId, contactId, tokenKey, accountAddress) {
        console.warn("remotelyDestructAndKick, not implemented yet!")
    }

    function burnToken(communityId, tokenKey, burnAmount, accountAddress) {
        console.assert(typeof burnAmount === "string")
        communityTokensModuleInst.burnTokens(communityId, tokenKey, burnAmount, accountAddress)
    }

    // Airdrop tokens:
    function airdrop(communityId, airdropTokens, addresses, feeAccountAddress) {
        communityTokensModuleInst.airdropTokens(communityId, JSON.stringify(airdropTokens), JSON.stringify(addresses), feeAccountAddress)
    }

    function asyncGetOwnerTokenDetails(communityId) {
        communityTokensModuleInst.asyncGetOwnerTokenDetails(communityId)
    }
}
