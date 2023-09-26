import QtQuick 2.15

import utils 1.0

ListModel {
    property ListModel assetsModel: WalletAssetsModel {}
    readonly property var data: [
        {
            name: "helloworld",
            emoji: "😋",
            colorId: Constants.walletAccountColors.primary,
            color: "#2A4AF5",
            address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            walletType: "",
            position: 0,
            assets: assetsModel
        },
        {
            name: "Hot wallet (generated)",
            emoji: "🚗",
            colorId: Constants.walletAccountColors.army,
            color: "#216266",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
            walletType: Constants.generatedWalletType,
            position: 3,
            assets: assetsModel
        },
        {
            name: "Family (seed)",
            emoji: "🎨",
            colorId: Constants.walletAccountColors.magenta,
            color: "#EC266C",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
            walletType: Constants.seedWalletType,
            position: 1,
            assets: assetsModel
        },
        {
            name: "Tag Heuer (watch)",
            emoji: "⌚",
            colorId: Constants.walletAccountColors.copper,
            color: "#CB6256",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
            walletType: Constants.watchWalletType,
            position: 2,
            assets: []
        },
        {
            name: "Fab (key)",
            emoji: "⌚",
            colorId: Constants.walletAccountColors.camel,
            color: "#C78F67",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8884",
            walletType: Constants.keyWalletType,
            position: 4,
            assets: assetsModel
        }
    ]

    Component.onCompleted: append(data)
}
