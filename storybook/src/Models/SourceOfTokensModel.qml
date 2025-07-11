import QtQuick

import Models

ListModel {
    id: root

    readonly property string uniswap: "uniswap"
    readonly property string status: "status"
    readonly property string custom: "custom"

    readonly property var data: [
        {
            key: root.uniswap,
            name: "Uniswap Labs Default",
            source: "https://gateway.ipfs.io/ipns/tokens.uniswap.org",
            version: "11.6.0",
            tokensCount: 731,
            image: ModelsData.assets.uni,
            updatedAt: 1710538948
        },
        {
            key: root.status,
            name: "Status Token List",
            source: "https://status.im/",
            version: "11.6.0",
            tokensCount: 250,
            image: ModelsData.assets.snt,
            updatedAt: 1710538948
        }
    ]

    Component.onCompleted: append(data)
}
