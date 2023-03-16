import QtQuick 2.0

ListModel {
    Component.onCompleted:
        append([
                   {
                       key: "Anniversary",
                       iconSource: ModelsData.collectibles.anniversary,
                       name: "Anniversary",
                       category: "Community collectibles"
                   },
                   {
                       key: "CryptoKitties",
                       iconSource: ModelsData.collectibles.cryptoKitties,
                       name: "CryptoKitties",
                       category: "Your collectibles",
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
                       ]
                   },
                   {
                       key: "SuperRare",
                       iconSource: ModelsData.collectibles.superRare,
                       name: "SuperRare",
                       category: "Your collectibles"
                   },
                   {
                       key: "Custom",
                       iconSource: ModelsData.collectibles.custom,
                       name: "Custom Collectible",
                       category: "All collectibles"
                   }
               ])
}
