import QtQuick 2.15

import Models 1.0

ListModel {
    readonly property string uniswap: "uniswap" //SourceOfTokensModel.uniswap
    readonly property string status: "status" //SourceOfTokensModel.status
    readonly property string custom: "custom" //SourceOfTokensModel.custom


    readonly property var data: [
        {
            key: "0",
            name: "Unisocks",
            symbol: "SOCKS",
            sources: ";" + uniswap + ";" + status + ";",
            chainId: NetworksModel.ethNet,
            address: "0x0000000000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.socks,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "1",
            name: "Unisocks",
            symbol: "SOCKS",
            sources: ";" + uniswap + ";" + status + ";",
            chainId: NetworksModel.optimismNet,
            address: "0x00000000000000000000000000000000000ade21",
            decimals: "18",
            image: ModelsData.assets.socks,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "2",
            name: "Ox",
            symbol: "ZRX",
            sources: ";" + uniswap + ";" + status + ";",
            chainId: NetworksModel.ethNet,
            address: "0x1230000000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.zrx,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "3",
            name: "1inch",
            symbol: "1INCH",
            sources: ";" + uniswap + ";" + status + ";",
            chainId: NetworksModel.ethNet,
            address: "0x4321000000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.inch,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "4",
            name: "Aave",
            symbol: "AAVE",
            sources: ";" + uniswap + ";" + status + ";",
            chainId: NetworksModel.arbitrumNet,
            address: "0x6543000000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.aave,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "5",
            name: "Amp",
            symbol: "AMP",
            sources: ";" + uniswap + ";",
            chainId: NetworksModel.arbitrumNet,
            address: "0x6543700000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.amp,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "6",
            name: "Dai",
            symbol: "DAI",
            sources: ";" + uniswap + ";",
            chainId: NetworksModel.optimismNet,
            address: "0xabc2000000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.dai,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "7",
            name: "snt",
            symbol: "SNT",
            sources: ";" + status + ";",
            chainId: NetworksModel.optimismNet,
            address: "0xbbc2000000000000000000000000000000000123",
            decimals: "18",
            image: ModelsData.assets.snt,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        },
        {
            key: "8",
            name: "snt",
            symbol: "SNT",
            sources: ";" + status + ";",
            chainId: NetworksModel.ethNet,
            address: "0xbbc200000000000000000000000000000000abcd",
            decimals: "18",
            image: ModelsData.assets.snt,
            type: 1,
            communityId: "",
            description: "",
            websiteUrl: ""
        }
    ]

    Component.onCompleted: append(data)
}
