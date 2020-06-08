pragma Singleton

import QtQuick 2.8

QtObject {
    readonly property int chatTypeOneToOne: 1
    readonly property int chatTypePublic: 2
    readonly property int chatTypePrivateGroupChat: 3

    readonly property int chatIdentifier: -1
    readonly property int messageType: 1
    readonly property int stickerType: 2

    readonly property var accountColors: [
        "#9B832F",
        "#D37EF4",
        "#1D806F",
        "#FA6565",
        "#7CDA00",
        "#887af9",
        "#8B3131"
    ]
}
