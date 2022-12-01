import QtQuick 2.0

import QtQuick 2.14

ListModel {
    Component.onCompleted: append([
                                      {image: ModelsData.tokens.socks},
                                      {image: ModelsData.tokens.zrx},
                                      {image: ModelsData.tokens.inch},
                                      {image: ModelsData.collectibles.anniversary},
                                      {image: ModelsData.collectibles.cryptoKitties},
                                      {image: ModelsData.collectibles.kitty1},
                                      {image: ModelsData.collectibles.kitty2},
                                      {image: ModelsData.collectibles.kitty3},
                                      {image: ModelsData.collectibles.superRare},
                                      {image: ModelsData.collectibles.custom}])
}
