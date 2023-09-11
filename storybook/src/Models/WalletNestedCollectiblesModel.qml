import QtQuick 2.15

ListModel {
    readonly property var rootData: [
        {
            uid: "ID-Anniversary",
            chainId: 1,
            name: "Anniversary",
            iconUrl: ModelsData.collectibles.anniversary,
            collectionUid: "anniversary",
            collectionName: "Anniversary",
            isCollection: false,
        },
        {
            uid: "ID-SuperRare",
            chainId: 1,
            name: "SuperRare",
            iconUrl: ModelsData.collectibles.superRare,
            collectionUid: "super-rare",
            collectionName: "SuperRare",
            isCollection: false,
        },
        {
            uid: "cryptokitties",
            chainId: 1,
            name: "CryptoKitties",
            iconUrl: ModelsData.collectibles.cryptoKitties,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            isCollection: true,
        },
        {
            uid: "ID-Custom",
            chainId: 1,
            name: "Custom Collectible",
            iconUrl: ModelsData.collectibles.custom,
            collectionUid: "custom",
            collectionName: "Custom",
            isCollection: false,
        }
    ]

    readonly property var criptoKittiesData: [
        {
            uid: "ID-Kitty1",
            chainId: 1,
            name: "Furbeard",
            iconUrl: ModelsData.collectibles.kitty1Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            isCollection: false,
        },
        {
            uid: "ID-Kitty2",
            chainId: 1,
            name: "Magicat",
            iconUrl: ModelsData.collectibles.kitty2Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            isCollection: false,
        },
        {
            uid: "ID-Kitty3",
            chainId: 1,
            name: "Happy Meow",
            iconUrl: ModelsData.collectibles.kitty3Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            isCollection: false,
        },
        {
            uid: "ID-Kitty4",
            chainId: 1,
            name: "Furbeard-2",
            iconUrl: ModelsData.collectibles.kitty4Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            isCollection: false,
        },
        {
            uid: "ID-Kitty5",
            chainId: 1,
            name: "Magicat-3",
            iconUrl: ModelsData.collectibles.kitty5Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            isCollection: false,
        }
    ]

    property string currentCollectionUid

    onCurrentCollectionUidChanged: {
        clear()
        if (currentCollectionUid === "") {
            append(rootData)
        } else if (currentCollectionUid === "cryptokitties") {
            append(criptoKittiesData)
        }
    }

    Component.onCompleted: append(rootData)
}
