import QtQuick 2.15

import AppLayouts.Chat.controls.community 1.0

ListModel {
    readonly property var data: [
        {
            key: "socks",
            iconSource: ModelsData.assets.socks,
            name: "Unisocks",
            shortName: "SOCKS",
            category: TokenCategories.Category.Community
        },
        {
            key: "zrx",
            iconSource: ModelsData.assets.zrx,
            name: "Ox",
            shortName: "ZRX",
            category: TokenCategories.Category.Community
        },
        {
            key: "1inch",
            iconSource: ModelsData.assets.inch,
            name: "1inch",
            shortName: "1INCH",
            category: TokenCategories.Category.Own
        },
        {
            key: "Aave",
            iconSource: ModelsData.assets.aave,
            name: "Aave",
            shortName: "AAVE",
            category: TokenCategories.Category.Own
        },
        {
            key: "Amp",
            iconSource: ModelsData.assets.amp,
            name: "Amp",
            shortName: "AMP",
            category: TokenCategories.Category.Own
        },
        {
            key: "Dai",
            iconSource: ModelsData.assets.dai,
            name: "Dai",
            shortName: "DAI",
            category: TokenCategories.Category.General
        },
        {
            key: "snt",
            iconSource: ModelsData.assets.snt,
            name: "snt",
            shortName: "snt",
            category: TokenCategories.Category.General
        }
    ]

    Component.onCompleted: append(data)
}
