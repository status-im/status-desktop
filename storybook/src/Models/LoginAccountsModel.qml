import QtQuick
import QtQml.Models

import Models

import StatusQ.Core.Theme

ListModel {
    readonly property var data: [
        {
            order: 2,
            keycardCreatedAccount: false,
            colorId: 1,
            username: "Bob",
            thumbnailImage: ModelsData.icons.dribble,
            keyUid: "uid_1"
        },
        {
            order: 1,
            keycardCreatedAccount: false,
            colorId: 2,
            username: "John",
            thumbnailImage: ModelsData.icons.cryptPunks,
            keyUid: "uid_2"
        },
        {
            order: 3,
            keycardCreatedAccount: true,
            colorId: 3,
            username: "8️⃣6️⃣.eth",
            thumbnailImage: "",
            keyUid: "uid_4"
        },
        {
            order: 4,
            keycardCreatedAccount: true,
            colorId: 4,
            username: "Very long username that should eventually elide on the right side",
            thumbnailImage: ModelsData.icons.superRare,
            keyUid: "uid_3"
        }
    ]
    Component.onCompleted: append(data)
}
