import QtQuick 2.15

ListModel {
    readonly property var rootData: [
        {
            uid: "ID-Kitty1",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "1",
            name: "Furbeard",
            imageUrl: ModelsData.collectibles.kitty1Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
        },
        {
            uid: "ID-Kitty2",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "2",
            name: "Magicat",
            imageUrl: ModelsData.collectibles.kitty2Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
        },
        {
            uid: "ID-Kitty3",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "3",
            name: "Happy Meow",
            imageUrl: ModelsData.collectibles.kitty3Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
        },
        {
            uid: "ID-Kitty4",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "4",
            name: "Furbeard-2",
            imageUrl: ModelsData.collectibles.kitty4Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
        },
        {
            uid: "ID-Kitty5",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "4",
            name: "Magicat-3",
            imageUrl: ModelsData.collectibles.kitty5Big,
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties"
        },
        {
            uid: "ID-Anniversary",
            chainId: 1,
            contractAddress: "0x2",
            tokenId: "1",
            name: "Anniversary",
            imageUrl: ModelsData.collectibles.anniversary,
            collectionUid: "anniversary",
            collectionName: "Anniversary",
        },
        {
            uid: "ID-SuperRare",
            chainId: 1,
            contractAddress: "0x3",
            tokenId: "101",
            name: "SuperRare",
            imageUrl: ModelsData.collectibles.superRare,
            collectionUid: "super-rare",
            collectionName: "SuperRare",
        },
        {
            uid: "ID-Custom",
            chainId: 1,
            contractAddress: "0x04",
            tokenId: "403",
            name: "Custom Collectible",
            imageUrl: ModelsData.collectibles.custom,
            collectionUid: "custom",
            collectionName: "Custom",
        }
    ]

    Component.onCompleted: append(rootData)
}
