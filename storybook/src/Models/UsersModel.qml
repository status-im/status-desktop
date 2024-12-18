import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property var data: [
        {
            pubKey: "0x043a7ed0e8d1012cf04",
            compressedPubKey: "zQ3shQBu4PRDX17vewYyvSczbTj344viTXxcMNvQLeyQsBDF4",
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
            pubKey: "0x04df12f12f12f12f1234",
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
            pubKey: "0x04d1b7cc0ef3f470f1238",
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
            icon: "",
            colorId: 5,
            isEnsVerified: false,
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.untrustworthy
        },
        {
            pubKey: "0x04d1bed192343f470f1255",
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
            icon: "",
            colorId: 3,
            isEnsVerified: true,
            isAwaitingAddress: false,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.untrustworthy
        },
        {
            pubKey: "0x04d1bed192343f470fabc",
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
            icon: "",
            colorId: 7,
            isEnsVerified: true,
            isAwaitingAddress: true,
            memberRole: Constants.memberRole.none,
            trustStatus: Constants.trustStatus.trusted
        }
    ]

    Component.onCompleted: append(data)
}
