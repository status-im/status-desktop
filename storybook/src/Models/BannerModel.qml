import QtQuick 2.14

ListModel {
    Component.onCompleted: append([
        {image: ModelsData.banners.status},
        {image: ModelsData.banners.superRare},
        {image: ModelsData.banners.coinbase},
        {image: ModelsData.banners.dragonereum},
        {image: ModelsData.banners.cryptPunks},
        {image: ModelsData.banners.socks}])
}
