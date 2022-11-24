import QtQuick 2.0

ListModel {
    Component.onCompleted:
        append([
                   {
                       key: "socks",
                       iconSource: ModelsData.tokens.socks,
                       name: "Unisocks",
                       shortName: "SOCKS",
                       category: "Community tokens"
                   },
                   {
                       key: "zrx",
                       iconSource: ModelsData.tokens.zrx,
                       name: "Ox",
                       shortName: "ZRX",
                       category: "Listed tokens"
                   },
                   {
                       key: "1inch",
                       iconSource: ModelsData.tokens.inch,
                       name: "1inch",
                       shortName: "ZRX",
                       category: "Listed tokens"
                   },
                   {
                       key: "Aave",
                       iconSource: ModelsData.tokens.aave,
                       name: "Aave",
                       shortName: "AAVE",
                       category: "Listed tokens"
                   },
                   {
                       key: "Amp",
                       iconSource: ModelsData.tokens.amp,
                       name: "Amp",
                       shortName: "AMP",
                       category: "Listed tokens"
                   }
               ])
}
