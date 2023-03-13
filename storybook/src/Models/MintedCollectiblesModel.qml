import QtQuick 2.15

ListModel {

    readonly property var data: [
        {
            name: "SuperRare artwork",
            image: ModelsData.banners.superRare,
            deployState: 1
        },
        {
            name: "Kitty artwork",
            image: ModelsData.collectibles.kitty1Big,
            deployState: 2
        },
        {
            name: "More artwork",
            image: ModelsData.banners.status,
            deployState: 2
        },
        {
            name: "Crypto Punks artwork",
            image: ModelsData.banners.cryptPunks,
            deployState: 1
        }
    ]

    Component.onCompleted: append(data)
}
