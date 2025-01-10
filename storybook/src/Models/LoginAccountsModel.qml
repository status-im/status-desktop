import QtQuick 2.15
import QtQml.Models 2.15

import StatusQ.Core.Theme 0.1

ListModel {
    readonly property var data: [
        {
            order: 2,
            keycardCreatedAccount: false,
            colorId: 1,
            colorHash: [{colorId: 3, segmentLength: 2}, {colorId: 7, segmentLength: 1}, {colorId: 4, segmentLength: 2}],
            username: "Bob",
            thumbnailImage: Theme.png("collectibles/Doodles"),
            keyUid: "uid_1"
        },
        {
            order: 1,
            keycardCreatedAccount: false,
            colorId: 2,
            colorHash: [{colorId: 9, segmentLength: 1}, {colorId: 7, segmentLength: 3}, {colorId: 10, segmentLength: 2}],
            username: "John",
            thumbnailImage: Theme.png("collectibles/CryptoPunks"),
            keyUid: "uid_2"
        },
        {
            order: 3,
            keycardCreatedAccount: true,
            colorId: 3,
            colorHash: [],
            username: "8️⃣6️⃣.eth",
            thumbnailImage: "",
            keyUid: "uid_4"
        },
        {
            order: 4,
            keycardCreatedAccount: true,
            colorId: 4,
            colorHash: [{colorId: 2, segmentLength: 4}, {colorId: 6, segmentLength: 3}, {colorId: 11, segmentLength: 1}],
            username: "Very long username that should eventually elide on the right side",
            thumbnailImage: Theme.png("collectibles/SuperRare"),
            keyUid: "uid_3"
        }
    ]
    Component.onCompleted: append(data)
}
