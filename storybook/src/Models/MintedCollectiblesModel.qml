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

    readonly property ListModel mintedCollectibleModel: ListModel {
        id: model

        Component.onCompleted: append([
                                          {
                                              name: "SuperRare artwork",
                                              image: ModelsData.banners.superRare,
                                              deployState: 1,
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
}
