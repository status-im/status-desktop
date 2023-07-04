import QtQuick 2.15

import AppLayouts.Communities.controls 1.0

ListModel {
    readonly property var data: [
        {
            key: "Anniversary",
            iconSource: ModelsData.collectibles.anniversary,
            name: "Anniversary",
            symbol: "ANN",
            category: TokenCategories.Category.Community,
            imageUrl: ModelsData.collectibles.anniversary,
            id: 1767698,
            communityId: ""
        },
        {
            key: "Anniversary2",
            iconSource: ModelsData.collectibles.anniversary,
            name: "Anniversary2",
            symbol: "ANN2",
            category: TokenCategories.Category.Community,
            imageUrl: ModelsData.collectibles.anniversary,
            id: 1767699,
            communityId: ""
        },
        {
            key: "CryptoKitties",
            iconSource: ModelsData.collectibles.cryptoKitties,
            name: "CryptoKitties",
            symbol: "CK",
            category: TokenCategories.Category.Own,
            subItems: [
                {
                    key: "Kitty1",
                    iconSource: ModelsData.collectibles.kitty1,
                    imageSource: ModelsData.collectibles.kitty1Big,
                    name: "Furbeard"
                },
                {
                    key: "Kitty2",
                    iconSource: ModelsData.collectibles.kitty2,
                    imageSource: ModelsData.collectibles.kitty2Big,
                    name: "Magicat"
                },
                {
                    key: "Kitty3",
                    iconSource: ModelsData.collectibles.kitty3,
                    imageSource: ModelsData.collectibles.kitty3Big,
                    name: "Happy Meow"
                },
                {
                    key: "Kitty4",
                    iconSource: ModelsData.collectibles.kitty4,
                    imageSource: ModelsData.collectibles.kitty4Big,
                    name: "Furbeard-2"
                },
                {
                    key: "Kitty5",
                    iconSource: ModelsData.collectibles.kitty5,
                    imageSource: ModelsData.collectibles.kitty5Big,
                    name: "Magicat-3"
                },
                {
                    key: "Kitty5",
                    iconSource: ModelsData.collectibles.kitty4,
                    imageSource: ModelsData.collectibles.kitty4Big,
                    name: "Furbeard-3"
                },
                {
                    key: "Kitty6",
                    iconSource: ModelsData.collectibles.kitty5,
                    imageSource: ModelsData.collectibles.kitty5Big,
                    name: "Magicat-4"
                }
            ],
            imageUrl: ModelsData.collectibles.cryptoKitties,
            id: 1767700,
            communityId: ""
        },
        {
            key: "SuperRare",
            iconSource: ModelsData.collectibles.superRare,
            name: "SuperRare",
            symbol: "SR",
            category: TokenCategories.Category.Own,
            imageUrl: ModelsData.collectibles.superRare,
            id: 1767701,
            communityId: ""
        },
        {
            key: "Custom",
            iconSource: ModelsData.collectibles.custom,
            name: "Custom Collectible",
            symbol: "CUS",
            category: TokenCategories.Category.General,
            imageUrl: ModelsData.collectibles.custom,
            id: 1767764,
            communityId: ""
        }
    ]

    property bool isFetching: false

    Component.onCompleted: append(data)
}
