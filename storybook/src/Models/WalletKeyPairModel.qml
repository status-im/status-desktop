import QtQuick 2.15

ListModel {
    readonly property var data: [
        {
            keyPair: {
                keyUid: "",
                pubKey: "zq3shfrgk6swgrrnc7wmwun1gvgact9iaevv9xwirumimhbyf",
                name: "Mike",
                image: "",
                icon: "",
                pairType: 0,
                migratedToKeycard: false,
                accounts: accountsList
            }
        },
        {
            keyPair: {
                keyUid: "",
                pubKey: "",
                name: "Seed Phrase",
                image: "",
                icon: "key_pair_private_key",
                pairType: 1,
                migratedToKeycard: true,
                accounts: accountsList
            }
        },
        {
            keyPair: {
                keyUid: "",
                pubKey: "",
                name: "",
                image: "",
                icon: "show",
                pairType: 3,
                migratedToKeycard: false,
                accounts: accountsList
            }
        }
    ]

    property var accountsList: ListModel {
        readonly property var data1: [
            {account: { name: "Test account", emoji: "😋", colorId: "primary", address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240" }},
            {account: { name: "Another account", emoji: "🚗", colorId: "army", address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"}}
        ]
        Component.onCompleted: append(data1)
    }

    Component.onCompleted: append(data)
}
