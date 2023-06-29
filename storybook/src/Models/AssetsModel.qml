import QtQuick 2.15

import AppLayouts.Communities.controls 1.0

ListModel {
    readonly property var data: [
        {
            key: "socks",
            iconSource: ModelsData.assets.socks,
            name: "Unisocks",
            shortName: "SOCKS",
            symbol: "SOCKS",
            category: TokenCategories.Category.Community,
            communityId: ""
        },
        {
            key: "zrx",
            iconSource: ModelsData.assets.zrx,
            name: "Ox",
            shortName: "ZRX",
            symbol: "ZRX",
            category: TokenCategories.Category.Community,
            communityId: ""
        },
        {
            key: "1inch",
            iconSource: ModelsData.assets.inch,
            name: "1inch",
            shortName: "1INCH",
            symbol: "1INCH",
            category: TokenCategories.Category.Own,
            communityId: ""
        },
        {
            key: "Aave",
            iconSource: ModelsData.assets.aave,
            name: "Aave",
            shortName: "AAVE",
            symbol: "AAVE",
            category: TokenCategories.Category.Own,
            communityId: ""
        },
        {
            key: "Amp",
            iconSource: ModelsData.assets.amp,
            name: "Amp",
            shortName: "AMP",
            symbol: "AMP",
            category: TokenCategories.Category.Own,
            communityId: ""
        },
        {
            key: "Dai",
            iconSource: ModelsData.assets.dai,
            name: "Dai",
            shortName: "DAI",
            symbol: "DAI",
            category: TokenCategories.Category.General,
            communityId: ""
        },
        {
            key: "snt",
            iconSource: ModelsData.assets.snt,
            name: "snt",
            shortName: "snt",
            symbol: "snt",
            category: TokenCategories.Category.General,
            communityId: ""
        }
    ]

    Component.onCompleted: append(data)
}
