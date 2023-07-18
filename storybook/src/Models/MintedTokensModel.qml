import QtQuick 2.15

ListModel {
    id: root

    readonly property ListModel tokenOwnersModel: TokenHoldersModel {}

    readonly property var data: [
        {
            isPrivilegedToken: true,
            isOwner: true,
            contractUniqueKey: "0x15a23414a3",
            tokenType: 2,
            name: "Owner-Doodles",
            image: ModelsData.collectibles.doodles,
            deployState: 0,
            symbol: "OWNDOO",
            description: "Owner doodles desc",
            supply: 1,
            remainingSupply: 1,
            infiniteSupply: false,
            transferable: true,
            remoteSelfDestruct: false,
            chainId: 2,
            chainName: "Optimism",
            chainIcon: ModelsData.networks.optimism,
            accountName: "Another account - generated"
        },
        {
            isPrivilegedToken: true,
            isOwner: false,
            contractUniqueKey: "0x23124443",
            tokenType: 2,
            name: "TMaster-Doodles",
            image: ModelsData.collectibles.doodles,
            deployState: 0,
            symbol: "TMDOO",
            description: "Doodles Token master token description",
            supply: 1,
            remainingSupply: 1,
            infiniteSupply: true,
            transferable: false,
            remoteSelfDestruct: true,
            chainId: 2,
            chainName: "Optimism",
            chainIcon: ModelsData.networks.optimism,
            accountName: "Another account - generated"
        },
        {
            isPrivilegedToken: false,
            isOwner: false,
            contractUniqueKey: "0x1726362343",
            tokenType: 2,
            name: "SuperRare artwork",
            image: ModelsData.banners.superRare,
            deployState: 0,
            symbol: "SRW",
            description: "Desc",
            supply: 1,
            remainingSupply: 1,
            infiniteSupply: true,
            transferable: false,
            remoteSelfDestruct: true,
            chainId: 1,
            chainName: "Testnet",
            chainIcon: ModelsData.networks.testnet,
            accountName: "Status Account"
        },
        {
            isPrivilegedToken: false,
            isOwner: false,
            contractUniqueKey: "0x847843",
            tokenType: 2,
            name: "Kitty artwork",
            image: ModelsData.collectibles.kitty1Big,
            deployState: 0,
            symbol: "KAT",
            description: "Desc",
            supply: 10,
            remainingSupply: 5,
            infiniteSupply: false,
            transferable: false,
            remoteSelfDestruct: true,
            chainId: 2,
            chainName: "Optimism",
            chainIcon: ModelsData.networks.optimism,
            accountName: "Status New Account"
        },
        {
            isPrivilegedToken: false,
            isOwner: false,
            contractUniqueKey: "0x1234525",
            tokenType: 2,
            name: "More artwork",
            image: ModelsData.banners.status,
            deployState: 1,
            symbol: "MMM",
            description: "Desc",
            supply: 1,
            remainingSupply: 0,
            infiniteSupply: true,
            transferable: false,
            remoteSelfDestruct: true,
            chainId: 5,
            chainName: "Custom",
            chainIcon: ModelsData.networks.custom,
            accountName: "Other Account"
        },
        {
            isPrivilegedToken: false,
            isOwner: false,
            contractUniqueKey: "0x38576852",
            tokenType: 2,
            name: "Crypto Punks artwork",
            image: ModelsData.banners.cryptPunks,
            deployState: 2,
            symbol: "CPA",
            description: "Desc",
            supply: 5,
            remainingSupply: 0,
            infiniteSupply: false,
            transferable: false,
            remoteSelfDestruct: true,
            chainId: 1,
            chainName: "Hermez",
            chainIcon: ModelsData.networks.hermez,
            accountName: "Account",
            tokenOwnersModel: root.tokenOwnersModel
        },
        {
            isPrivilegedToken: false,
            isOwner: false,
            contractUniqueKey: "0x38745623865",
            tokenType: 1,
            name: "Unisocks",
            image: ModelsData.assets.socks,
            deployState: 2,
            symbol: "SOCKS",
            description: "Socks description",
            supply: 14,
            remainingSupply: 2,
            infiniteSupply: false,
            decimals: 2,
            chainId: 2,
            chainName: "Optimism",
            chainIcon: ModelsData.networks.optimism,
            accountName: "Status SNT Account"
        },
        {
            isPrivilegedToken: false,
            isOwner: false,
            contractUniqueKey: "0x872364871623",
            tokenType: 1,
            name: "Dai",
            image: ModelsData.assets.dai,
            deployState: 0,
            symbol: "DAI",
            description: "Desc",
            supply: 1,
            remainingSupply: 1,
            infiniteSupply: true,
            decimals: 1,
            chainId: 1,
            chainName: "Testnet",
            chainIcon: ModelsData.networks.testnet,
            accountName: "Status Account"
        }
    ]

    function changeMintingState(index, deployState) {
        get(index).deployState = deployState
    }

    function changeAllMintingStates(deployState) {
        for(let i = 0; i < count; i++)
            changeMintingState(i, deployState)
    }

    Component.onCompleted: append(data)
}
