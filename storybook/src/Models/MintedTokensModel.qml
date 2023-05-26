pragma Singleton
import QtQuick 2.15

QtObject {
    id: root

    function changeMintingState(index, deployState) {
        model.get(index).deployState = deployState
    }

    function changeAllMintingStates(deployState) {
        for(var i = 0; i < model.count; i++) {
            changeMintingState(i, deployState)
        }
    }

    function buildMintedTokensModel(isAssets, isCollectibles) {
        model.clear()

        if(isAssets) {
            for(var i = 0; i < mintedAssetsModel.count; i++)
                model.append(mintedAssetsModel.get(i))
        }

        if(isCollectibles) {
            for(var j = 0; j < collectiblesModel.count; j++)
                model.append(collectiblesModel.get(j))
        }
    }

    readonly property ListModel mintedCollectiblesModel: ListModel {
        id: collectiblesModel

        Component.onCompleted: append([
                                          {
                                              contractUniqueKey: "0x1726362343",
                                              tokenType: 2,
                                              name: "SuperRare artwork",
                                              image: ModelsData.banners.superRare,
                                              deployState: 0,
                                              symbol: "SRW",
                                              description: "Desc",
                                              supply: 1,
                                              remainingTokens: 1,
                                              infiniteSupply: true,
                                              transferable: false,
                                              remoteSelfDestruct: true,
                                              chainId: 1,
                                              chainName: "Testnet",
                                              chainIcon: ModelsData.networks.testnet,
                                              accountName: "Status Account"
                                          },
                                          {
                                              contractUniqueKey: "0x847843",
                                              tokenType: 2,
                                              name: "Kitty artwork",
                                              image: ModelsData.collectibles.kitty1Big,
                                              deployState: 2,
                                              symbol: "KAT",
                                              description: "Desc",
                                              supply: 10,
                                              remainingTokens: 5,
                                              infiniteSupply: false,
                                              transferable: false,
                                              remoteSelfDestruct: true,
                                              chainId: 2,
                                              chainName: "Optimism",
                                              chainIcon: ModelsData.networks.optimism,
                                              accountName: "Status New Account"
                                          },
                                          {
                                              contractUniqueKey: "0x1234525",
                                              tokenType: 2,
                                              name: "More artwork",
                                              image: ModelsData.banners.status,
                                              deployState: 1,
                                              symbol: "MMM",
                                              description: "Desc",
                                              supply: 1,
                                              remainingTokens: 0,
                                              infiniteSupply: true,
                                              transferable: false,
                                              remoteSelfDestruct: true,
                                              chainId: 5,
                                              chainName: "Curstom",
                                              chainIcon: ModelsData.networks.custom,
                                              accountName: "Other Account"
                                          },
                                          {
                                              contractUniqueKey: "0x38576852",
                                              tokenType: 2,
                                              name: "Crypto Punks artwork",
                                              image: ModelsData.banners.cryptPunks,
                                              deployState: 2,
                                              symbol: "CPA",
                                              description: "Desc",
                                              supply: 5000,
                                              remainingTokens: 1500,
                                              infiniteSupply: false,
                                              transferable: false,
                                              remoteSelfDestruct: false,
                                              chainId: 1,
                                              chainName: "Hermez",
                                              chainIcon: ModelsData.networks.hermez,
                                              accountName: "Account"
                                          }
                                      ])
    }

    readonly property ListModel mintedAssetsModel: ListModel {
        id: assetsModel

        Component.onCompleted: append([
                                          {
                                              contractUniqueKey: "0x38745623865",
                                              tokenType: 1,
                                              name: "Unisocks",
                                              image: ModelsData.assets.socks,
                                              deployState: 2,
                                              symbol: "SOCKS",
                                              description: "Socks description",
                                              supply: 14,
                                              remainingTokens: 2,
                                              infiniteSupply: false,
                                              decimals: 2,
                                              chainId: 2,
                                              chainName: "Optimism",
                                              chainIcon: ModelsData.networks.optimism,
                                              accountName: "Status SNT Account"
                                          },
                                          {
                                              contractUniqueKey: "0x872364871623",
                                              tokenType: 1,
                                              name: "Dai",
                                              image: ModelsData.assets.dai,
                                              deployState: 0,
                                              symbol: "DAI",
                                              description: "Desc",
                                              supply: 1,
                                              remainingTokens: 1,
                                              infiniteSupply: true,
                                              decimals: 1,
                                              chainId: 1,
                                              chainName: "Testnet",
                                              chainIcon: ModelsData.networks.testnet,
                                              accountName: "Status Account"
                                          }
                                      ])
    }

    readonly property ListModel mintedTokensModel: ListModel {
        id: model

        Component.onCompleted: buildMintedTokensModel(true, true)
    }
}
