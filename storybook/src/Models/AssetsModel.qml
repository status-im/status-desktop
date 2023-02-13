import QtQuick 2.15

import AppLayouts.Chat.controls.community 1.0

ListModel {
    Component.onCompleted:
        append([
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
                       category: TokenCategories.Category.Own
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
                   }
               ])
}
