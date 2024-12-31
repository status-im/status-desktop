import QtQuick 2.15
import SortFilterProxyModel 0.2

import utils 1.0

QtObject {
    id: root

    property CurrenciesStore currencyStore

    property var communityTokensModuleInst: communityTokensModule ?? null
    property var mainModuleInst: mainModule ?? null

    // Network selection properties:
    property var flatNetworks: networksModule.flatNetworks
    property SortFilterProxyModel filteredFlatModel: SortFilterProxyModel {
        sourceModel: root.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: networksModule.areTestNetworksEnabled }
    }

    // set by asyncGetOwnerTokenDetails
    readonly property var ownerTokenDetails: {
        JSON.parse(communityTokensModuleInst.ownerTokenDetails)
    }

    signal selfDestructFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)
    signal burnFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)
    signal setSignerFeeUpdated(var ethCurrency, var fiatCurrency, int error, string responseId)

    signal remoteDestructStateChanged(string communityId, string tokenName, int status, string url)
    signal burnStateChanged(string communityId, string tokenName, int status, string url)
    signal airdropStateChanged(string communityId, string tokenName, string chainName, int status, string url)
    signal setSignerStateChanged(string communityId, string communityName, int status, string url)
    signal ownershipLost(string communityId, string communityName)
    signal communityOwnershipDeclined(string communityName)
    signal sendOwnerTokenStateChanged(string tokenName, int status, string url)
    signal ownerTokenReceived(string communityId, string communityName)
    signal communityTokenReceived(string name, string symbol, string image,
                                  string communityId, string communityName,
                                  string balance, int chainId,
                                  string txHash, bool isFirst,
                                  int tokenType, string walletAccountName,
                                  string walletAddress)

    function authenticateAndTransfer() {
        communityTokensModuleInst.authenticateAndTransfer()
    }

    function computeDeployCollectiblesFee(subscriptionId, communityId, cKey, cChainId, cAccountAddress, cName, cSymbol,
                                          cDescription, cSupply, cInfiniteSupply, cTransferable, cRemotelyDestruct, cArtworkSource, cArtworkCropRect) {
        if (cKey !== "")
            deleteToken(communityId, cKey)

        const jsonArtworkFile = Utils.getImageAndCropInfoJson(cArtworkSource, cArtworkCropRect)
        communityTokensModuleInst.computeDeployCollectiblesFee(subscriptionId, communityId, cAccountAddress, cName,
                                                    cSymbol, cDescription, cSupply, cInfiniteSupply,
                                                    cTransferable, cRemotelyDestruct, cChainId, jsonArtworkFile)
    }

    function computeDeployAssetsFee(subscriptionId, communityId, aKey, aChainId, aAccountAddress, aName, aSymbol,
                                    aDescription, aSupply, aInfiniteSupply, aDecimals, aArtworkSource, aArtworkCropRect) {
        if (aKey !== "")
            deleteToken(communityId, aKey)

        const jsonArtworkFile = Utils.getImageAndCropInfoJson(aArtworkSource, aArtworkCropRect)
        communityTokensModuleInst.computeDeployAssetsFee(subscriptionId, communityId, aAccountAddress, aName,
                                               aSymbol, aDescription, aSupply,
                                               aInfiniteSupply, aDecimals, aChainId, jsonArtworkFile)
    }


    function computeDeployTokenOwnerFee(subscriptionId, communityId,
                                        otChainId, otAccountAddress, otName, otSymbol, otDescription, otArtworkSource, otArtworkCropRect,
                                        tmtName, tmtSymbol, tmtDescription) {

        function deployOwnerTokenWithArtwork (subscriptionId, communityId, artworkSource,
                                              otChainId, otAccountAddress, otName, otSymbol, otDescription, otArtworkCropRect,
                                              tmtName, tmtSymbol, tmtDescription) {
            const jsonArtworkFile = Utils.getImageAndCropInfoJson(artworkSource, otArtworkCropRect)
            communityTokensModuleInst.computeDeployTokenOwnerFee(subscriptionId, communityId, otAccountAddress, otName, otSymbol, otDescription,
                                                       tmtName, tmtSymbol, tmtDescription, otChainId, jsonArtworkFile)
        }

        if (String(otArtworkSource).startsWith("https://localhost:")) {
            Utils.fetchImageBase64(otArtworkSource, (dataUrl) => {
                deployOwnerTokenWithArtwork(subscriptionId, communityId, dataUrl,
                                            otChainId, otAccountAddress, otName, otSymbol, otDescription, otArtworkCropRect,
                                            tmtName, tmtSymbol, tmtDescription)
            })
        } else {
            deployOwnerTokenWithArtwork(subscriptionId, communityId, otArtworkSource,
                                        otChainId, otAccountAddress, otName, otSymbol, otDescription, otArtworkCropRect,
                                        tmtName, tmtSymbol, tmtDescription)
        }
    }

    function computeAirdropFee(subscriptionId, communityId, contractKeysAndAmounts, addresses, feeAccountAddress) {
        communityTokensModuleInst.computeAirdropFee(subscriptionId, communityId, JSON.stringify(contractKeysAndAmounts),
                                                    JSON.stringify(addresses), feeAccountAddress)
    }

    function deleteToken(communityId, contractUniqueKey) {
        let parts = contractUniqueKey.split("_");
        communityTokensModuleInst.removeCommunityToken(communityId, parts[0], parts[1])
    }

    function refreshToken(contractUniqueKey) {
        let parts = contractUniqueKey.split("_");
        communityTokensModuleInst.refreshCommunityToken(parts[0], parts[1])
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


        function onSelfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.selfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
        }


        function onBurnFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.burnFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
        }

        function onSetSignerFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
            root.setSignerFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId)
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

        function onCommunityTokenReceived(name, symbol, image, communityId, communityName, balance, chainId, txHash, isFirst, tokenType, walletAccountName, walletAccountName, walletAddress) {
            root.communityTokenReceived(name, symbol, image, communityId, communityName, balance, chainId, txHash, isFirst, tokenType, walletAccountName, walletAccountName, walletAddress)
        }

        function onSetSignerStateChanged(communityId, communityName, status, url) {
            root.setSignerStateChanged(communityId, communityName, status, url)
        }

        function onOwnershipNodeLost(communityId, communityName) {
            root.ownershipLost(communityId, communityName)
        }

        function onSendOwnerTokenStateChanged(tokenName, status, url) {
            root.sendOwnerTokenStateChanged(tokenName, status, url)
        }
    }

    function stopUpdatesForSuggestedRoute() {
        communityTokensModuleInst.stopUpdatesForSuggestedRoute()
    }

    // Burn:
    function computeBurnFee(tokenKey, amount, accountAddress, requestId) {
        console.assert(typeof amount === "string")
        communityTokensModuleInst.computeBurnFee(tokenKey, amount, accountAddress, requestId)
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


    function asyncGetOwnerTokenDetails(communityId) {
        communityTokensModuleInst.asyncGetOwnerTokenDetails(communityId)
    }

    function startTokenHoldersManagement(communityId, chainId, contractAddress) {
        mainModuleInst.startTokenHoldersManagement(communityId, chainId, contractAddress)
    }

    function stopTokenHoldersManagement() {
        mainModuleInst.stopTokenHoldersManagement()
    }
}
