import QtQuick

import AppLayouts.Communities.controls

ListModel {
    readonly property var data: [
        {
            key: "socks",
            iconSource: ModelsData.assets.socks,
            name: "Unisocks",
            shortName: "SOCKS",
            symbol: "SOCKS",
            category: TokenCategories.Category.Community,
            communityId: "",
            communityImage: "",
            address: "23534tlgtu90345t"
        },
        {
            key: "zrx",
            iconSource: ModelsData.assets.zrx,
            name: "Ox",
            shortName: "ZRX",
            symbol: "ZRX",
            category: TokenCategories.Category.Community,
            communityId: "",
            communityImage: "",
            address: "23534tlgtu90345t"
        },
        {
            key: "1inch",
            iconSource: ModelsData.assets.inch,
            name: "1inch",
            shortName: "1INCH",
            symbol: "1INCH",
            category: TokenCategories.Category.Own,
            communityId: "",
            communityImage: "",
            address: "23534tlgtu90345t"
        },
        {
            key: "Aave",
            iconSource: ModelsData.assets.aave,
            name: "Aave",
            shortName: "AAVE",
            symbol: "AAVE",
            category: TokenCategories.Category.Own,
            communityId: "",
            communityImage: "",
            address: "23534tlgtu90345t"
        },
        {
            key: "Amp",
            iconSource: ModelsData.assets.amp,
            name: "Amp",
            shortName: "AMP",
            symbol: "AMP",
            category: TokenCategories.Category.Own,
            communityId: "",
            communityImage: "",
            address: "23534tlgtu90345t"
        },
        {
            key: "Dai",
            iconSource: ModelsData.assets.dai,
            name: "Dai",
            shortName: "DAI",
            symbol: "DAI",
            category: TokenCategories.Category.General,
            communityId: "0x1",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            address: "stgdrswaE2q"
        },
        {
            key: "snt",
            iconSource: ModelsData.assets.snt,
            name: "snt",
            shortName: "snt",
            symbol: "SNT",
            category: TokenCategories.Category.General,
            communityId: "",
            address: "321312wdsadas"
        },
        {
            key: "stt",
            iconSource: ModelsData.assets.snt,
            name: "stt",
            shortName: "stt",
            symbol: "STT",
            category: TokenCategories.Category.Own,
            communityId: "",
            address: "rwr32e1wqdscdwe43r34r"
        },
        {
            key: "eth",
            iconSource: ModelsData.assets.eth,
            name: "eth",
            shortName: "eth",
            symbol: "ETH",
            category: TokenCategories.Category.General,
            communityId: "000",
            communityImage: ModelsData.icons.status,
            address: "rwr43r34r"
        }
    ]

    Component.onCompleted: append(data)
}
