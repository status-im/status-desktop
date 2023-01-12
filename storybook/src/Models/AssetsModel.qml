import QtQuick 2.0

ListModel {
    Component.onCompleted:
        append([
                   {
                       key: "socks",
                       iconSource: ModelsData.assets.socks,
                       name: "Unisocks",
                       shortName: "SOCKS",
                       category: "Community assets"
                   },
                   {
                       key: "zrx",
                       iconSource: ModelsData.assets.zrx,
                       name: "Ox",
                       shortName: "ZRX",
                       category: "Listed assets"
                   },
                   {
                       key: "1inch",
                       iconSource: ModelsData.assets.inch,
                       name: "1inch",
                       shortName: "ZRX",
                       category: "Listed assets"
                   },
                   {
                       key: "Aave",
                       iconSource: ModelsData.assets.aave,
                       name: "Aave",
                       shortName: "AAVE",
                       category: "Listed assets"
                   },
                   {
                       key: "Amp",
                       iconSource: ModelsData.assets.amp,
                       name: "Amp",
                       shortName: "AMP",
                       category: "Listed assets"
                   }
               ])
}
