import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property var data: [
        {
            communityId: "ddls",
            communityName: "Doodles",
            communityImage: ModelsData.collectibles.doodles
        },
        {
            communityId: "sox",
            communityName: "Socks",
            communityImage: ModelsData.icons.socks
        },
        {
            communityId: "ast",
            communityName: "Astafarians",
            communityImage: ModelsData.icons.dribble
        }
    ]

    Component.onCompleted: append(data)
}
