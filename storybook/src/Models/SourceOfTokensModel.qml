import QtQuick 2.15

import Models 1.0

ListModel {
    id: root

    readonly property string uniswap: "uniswap"
    readonly property string status: "status"
    readonly property string custom: "custom"

    readonly property var data: [
        {
            key: root.uniswap,
            name: "Uniswap Labs Default",
            updatedAt: 1695720962,
            source: "https://gateway.ipfs.io/ipns/tokens.uniswap.org",
            version: "11.6.0",
            tokensCount: 731,
            image: ModelsData.assets.uni
        },
        {
            key: root.status,
            name: "Status Token List",
            updatedAt: 1661506562,
            source: "https://status.im/",
            version: "11.6.0",
            tokensCount: 250,
            image: ModelsData.assets.snt
        }
    ]

    Component.onCompleted: append(data)
}
