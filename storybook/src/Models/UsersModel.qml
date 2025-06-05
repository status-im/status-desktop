import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property var data: [
        {
            pubKey: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04",
            compressedPubKey: "zQ3shQBu4PRDX17vewYyvSczbTj344viTXxcMNvQLeyQsBDF4",
            emojiHash: JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"]),
            onlineStatus: Constants.onlineStatus.online,
            isContact: true,
            isBlocked: false,
            isVerified: false,
            isAdmin: false,
            isUntrustworthy: false,
            displayName: "Mike has a very long name that should elide " +
                         "eventually and result in a tooltip displayed instead",
            alias: "",
            localNickname: "",
            ensName: "",
            preferredDisplayName: "Mike has a very long name that should elide " +
                                  "eventually and result in a tooltip displayed instead",
            icon: ModelsData.icons.cryptPunks,
            colorId: 7,
            isEnsVerified: false,
            colorHash: [
                { colorId: 0, segmentLength: 2 },
                { colorId: 17, segmentLength: 2}
            ],
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.unknown
        },
        {
            pubKey: "0x043a8ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04",
            emojiHash: JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️","🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎"]),
            compressedPubKey: "zQ3shQBAAPRDX17vewYyvSczbTj344viTXxcMNvQLeyQsBDF4",
            onlineStatus: Constants.onlineStatus.inactive,
            isContact: false,
            contactRequest: Constants.ContactRequestState.Sent,
            isBlocked: false,
            isVerified: false,
            isAdmin: false,
            isUntrustworthy: false,
            displayName: "Jane",
            alias: "",
            localNickname: "",
            ensName: "",
            preferredDisplayName: "Jane",
            icon: "",
            colorId: 9,
            isEnsVerified: false,
            colorHash: [
                { colorId: 0, segmentLength: 1 },
                { colorId: 19, segmentLength: 2 }
            ],
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.owner,
            trustStatus: Constants.trustStatus.unknown
        },
        {
            pubKey: "0x043a7ed0e9752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04",
            emojiHash: JSON.stringify(["🏮","🤷🏻‍♂️", "🤦🏻", "📣", "👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"]),
            compressedPubKey: "zQ3shQ7u3PRDX17vewYyvSczbTj344viTXxcMNvQLeyQsCDF4",
            onlineStatus: Constants.onlineStatus.inactive,
            isContact: false,
            isBlocked: true,
            isVerified: false,
            isAdmin: false,
            isUntrustworthy: true,
            displayName: "John",
            alias: "",
            localNickname: "Johnny Johny",
            ensName: "",
            preferredDisplayName: "Johnny Johny",
            icon: ModelsData.icons.dragonereum,
            colorId: 4,
            isEnsVerified: false,
            colorHash: [
                { colorId: 7, segmentLength: 3 },
                { colorId: 12, segmentLength: 1 }
            ],
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.untrustworthy
        },
        {
            pubKey: "0x04d1bed192343f470f1257",
            emojiHash: JSON.stringify(["👨🏻‍🍼", "📣", "🤎", "👷🏽", "😺", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "🥞", "🔃", "🧝🏽‍♂️"]),
            compressedPubKey: "zQ3shQAL4PRDX17vewYyvSczbTj344viTXxcMNvQLeyQsBDF4",
            onlineStatus: Constants.onlineStatus.online,
            isContact: true,
            isBlocked: false,
            isVerified: false,
            isAdmin: false,
            isUntrustworthy: true,
            displayName: "Maria",
            alias: "meth",
            localNickname: "",
            ensName: "",
            preferredDisplayName: "Maria",
            icon: "",
            colorId: 5,
            isEnsVerified: false,
            colorHash: [
                { colorId: 7, segmentLength: 3 },
                { colorId: 12, segmentLength: 1 }
            ],
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.untrustworthy
        },
        {
            pubKey: "0x04d1bed192343f470f1255",
            emojiHash: JSON.stringify(["🥞", "🔃", "🧝🏽‍♂️", "👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺"]),
            compressedPubKey: "zQ3shQBu4PGDX17vewYyvSczbTj344viTXxcMNvQLeyQsBD1A",
            onlineStatus: Constants.onlineStatus.online,
            isContact: false,
            contactRequest: Constants.ContactRequestState.Received,
            isBlocked: false,
            isVerified: false,
            isAdmin: true,
            isUntrustworthy: true,
            displayName: "",
            alias: "Richard The Lionheart",
            localNickname: "",
            ensName: "richard-the-lionheart.eth",
            preferredDisplayName: "richard-the-lionheart.eth",
            icon: "",
            colorId: 3,
            isEnsVerified: true,
            colorHash: [],
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.untrustworthy
        },
        {
            pubKey: "0x04d1bed192343f470fabc",
            emojiHash: JSON.stringify(["🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🥞", "🔃", "🧝🏽‍♂️"]),
            compressedPubKey: "zQ3shQBk4PRDX17vewYyvSczbTj344viTXxcMNvQLeyQsB994",
            onlineStatus: Constants.onlineStatus.inactive,
            isContact: true,
            isBlocked: false,
            isVerified: true,
            isAdmin: false,
            isUntrustworthy: false,
            displayName: "",
            alias: "",
            localNickname: "",
            ensName: "8⃣6⃣.sth.eth",
            preferredDisplayName: "8⃣6⃣.sth.eth",
            icon: "",
            colorId: 7,
            isEnsVerified: true,
            colorHash: [],
            isAwaitingAddress: true,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.trusted
        }
    ]

    Component.onCompleted: append(data)
}
