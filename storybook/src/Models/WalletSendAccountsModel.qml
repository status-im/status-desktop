import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property var data: [
        {
            name: "helloworld",
            emoji: "😋",
            colorId: Constants.walletAccountColors.primary,
            color: "#2A4AF5",
            address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            preferredSharingChainIds: "5:420:421613",
            walletType: "",
            position: 0,
            canSend: true,
            migratedToKeycard: false
        },
        {
            name: "Hot wallet (generated)",
            emoji: "🚗",
            colorId: Constants.walletAccountColors.army,
            color: "#216266",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
            preferredSharingChainIds: "5:420:421613",
            walletType: Constants.generatedWalletType,
            position: 3,
            canSend: true,
            migratedToKeycard: false
        },
        {
            name: "Family (seed)",
            emoji: "🎨",
            colorId: Constants.walletAccountColors.magenta,
            color: "#EC266C",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
            preferredSharingChainIds: "5:420:421613",
            walletType: Constants.seedWalletType,
            position: 1,
            canSend: true,
            migratedToKeycard: false
        },
        {
            name: "Tag Heuer (watch)",
            emoji: "⌚",
            colorId: Constants.walletAccountColors.copper,
            color: "#CB6256",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
            preferredSharingChainIds: "5:420:421613",
            walletType: Constants.watchWalletType,
            position: 2,
            canSend: false,
            migratedToKeycard: false
        },
        {
            name: "Fab (key)",
            emoji: "⌚",
            colorId: Constants.walletAccountColors.camel,
            color: "#C78F67",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8884",
            preferredSharingChainIds: "5:420:421613",
            walletType: Constants.keyWalletType,
            position: 4,
            canSend: true,
            migratedToKeycard: true
        }
    ]

    Component.onCompleted: append(data)
}
