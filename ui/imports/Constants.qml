pragma Singleton

import QtQuick 2.13

QtObject {
    readonly property int chatTypeOneToOne: 1
    readonly property int chatTypePublic: 2
    readonly property int chatTypePrivateGroupChat: 3

    readonly property int fetchMoreMessagesButton: -2
    readonly property int chatIdentifier: -1
    readonly property int unknownContentType: 0
    readonly property int messageType: 1
    readonly property int stickerType: 2
    readonly property int statusType: 3
    readonly property int emojiType: 4
    readonly property int transactionType: 5
    readonly property int systemMessagePrivateGroupType: 6
    readonly property int imageType: 7
    readonly property int audioType: 8

    readonly property string watchWalletType: "watch"
    readonly property string keyWalletType: "key"
    readonly property string seedWalletType: "seed"
    readonly property string generatedWalletType: "generated"

    // Transaction states
    readonly property string pending: "pending"
    readonly property string confirmed: "confirmed"
    readonly property string unknown: "unknown"
    readonly property string addressRequested: "addressRequested"
    readonly property string addressReceived: "addressReceived"
    readonly property string declined: "declined"
    readonly property string shared: "shared"
    readonly property string failure: "failure"

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
