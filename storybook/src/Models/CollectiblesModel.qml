import QtQuick 2.15

import AppLayouts.Communities.controls 1.0

ListModel {
    readonly property var data: [
        {
            key: "Anniversary",
            iconSource: ModelsData.collectibles.anniversary,
            name: "Anniversary",
            category: TokenCategories.Category.Community,
            imageUrl: ModelsData.collectibles.anniversary,
            id: 1767698
        },
        {
            key: "Anniversary2",
            iconSource: ModelsData.collectibles.anniversary,
            name: "Anniversary2",
            category: TokenCategories.Category.Community,
            imageUrl: ModelsData.collectibles.anniversary,
            id: 1767699
        },
        {
            key: "CryptoKitties",
            iconSource: ModelsData.collectibles.cryptoKitties,
            name: "CryptoKitties",
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
            id: 1767700
        },
        {
            key: "SuperRare",
            iconSource: ModelsData.collectibles.superRare,
            name: "SuperRare",
            category: TokenCategories.Category.Own,
            imageUrl: ModelsData.collectibles.superRare,
            id: 1767701
        },
        {
            key: "Custom",
            iconSource: ModelsData.collectibles.custom,
            name: "Custom Collectible",
            category: TokenCategories.Category.General,
            imageUrl: ModelsData.collectibles.custom,
            id: 1767764
        }
    ]

    property bool isFetching: false

    Component.onCompleted: append(data)
}
