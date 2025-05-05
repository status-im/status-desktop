import QtQuick 2.15

import Models 1.0

ListModel {

    readonly property var emptyModel: ListModel {}

    Component.onCompleted: append(entries)

    readonly property var entries: [
        {
            featured: false,
            id: "id1",
            loaded: true,
            icon: ModelsData.icons.status,
            banner: ModelsData.banners.status,
            color: "mediumblue",
            name: "Status.app",
            description: "Your portal to Web3. Secure wallet. Private messaging. Requires secret tokens to join",
            members: 130,
            activeMembers: 61,
            popularity: 4,
            available: true,
            tags: JSON.stringify([
                {
                    "name": "Activism",
                    "emoji": "✊",
                },
                {
                    "name": "Art",
                    "emoji": "🎨",
                },
                {
                    "name": "Blockchain",
                    "emoji": "🔗",
                },
                {
                    "name": "Books & blogs",
                    "emoji": "📚",
                },
                {
                    "name": "Career",
                    "emoji": "💼",
                },
            ]),
            permissionsModel: PermissionsModel.privatePermissionsMemberNotMetModel,
            allTokenRequirementsMet: false,
            hasNotification: true,
            notificationsCount: 3
        },
        {
            featured: true,
            id: "id2",
            loaded: true,
            icon: ModelsData.icons.superRare,
            banner: ModelsData.banners.superRare,
            color: "red",
            name: "SuperRare",
            description: "The future of CryptoArt markets—a network governed by artists, collectors and curators.",
            members: 12,
            activeMembers: 4,
            popularity: 4,
            available: true,
            tags: JSON.stringify([
                {
                    "name": "Activism",
                    "emoji": "✊",
                },
                {
                    "name": "Books & blogs",
                    "emoji": "📚",
                },
                {
                    "name": "Career",
                    "emoji": "💼",
                },
            ]),
            permissionsModel: PermissionsModel.twoShortPermissionsModel,
            allTokenRequirementsMet: false,
            hasNotification: true,
            notificationsCount: 0
        },
        {
            featured: true,
            id: "id3",
            loaded: true,
            icon: ModelsData.icons.coinbase,
            banner: ModelsData.banners.coinbase,
            color: "white",
            name: "Coinbase",
            description: "Jump start your crypto portfolio with the easiest place to buy and sell crypto.",
            members: 20,
            activeMembers: 20,
            popularity: 4,
            available: true,
            tags: JSON.stringify([
                {
                    "name": "Activism",
                    "emoji": "✊",
                },
                {
                    "name": "Career",
                    "emoji": "💼",
                },
            ]),
            permissionsModel: PermissionsModel.moreThanTwoInitialShortPermissionsModel,
            allTokenRequirementsMet: false
        },
        {
            featured: false,
            id: "id4",
            loaded: true,
            icon: ModelsData.icons.dragonereum,
            banner: ModelsData.banners.dragonereum,
            color: "black",
            name: "Dragonereum lorem ipsum dolor sit amet",
            description: "A community of cat lovers, meow!",
            members: 34,
            activeMembers: 20,
            popularity: 4,
            available: true,
            tags: JSON.stringify([
                {
                    "name": "Career",
                    "emoji": "💼",
                },
            ]),
            permissionsModel: PermissionsModel.longPermissionsModel,
            allTokenRequirementsMet: false
        },
        {
            featured: false,
            id: "id5",
            loaded: true,
            icon: ModelsData.icons.cryptPunks,
            banner: ModelsData.banners.cryptPunks,
            color: "grey",
            name: "CryptPunks",
            description: "A group chat full of our favorite thinkers and creators.",
            members: 10134,
            activeMembers: 2800,
            popularity: 4,
            available: true,
            tags: JSON.stringify([]),
            permissionsModel: PermissionsModel.channelsOnlyPermissionsModelNotMet,
            allTokenRequirementsMet: false,
            hasNotification: true,
            notificationsCount: 33
        },
        {
            featured: false,
            id: "id6",
            loaded: true,
            icon: ModelsData.icons.socks,
            banner: ModelsData.banners.socks,
            color: "yellow",
            name: "Socks",
            description: "A community of P2P crypto trades.",
            members: 34,
            activeMembers: 1,
            popularity: 4,
            available: true,
            tags: JSON.stringify([
                {
                    "name": "Art",
                    "emoji": "🎨",
                },
                {
                    "name": "Blockchain",
                    "emoji": "🔗",
                },
                {
                    "name": "Books & blogs",
                    "emoji": "📚",
                },
            ]),
            permissionsModel: PermissionsModel.threeShortPermissionsModel,
            allTokenRequirementsMet: false,
            hasNotification: false,
            notificationsCount: 33
        },
        {
            featured: false,
            id: "id7",
            loaded: true,
            icon: ModelsData.icons.rarible,
            banner: "",
            color: "pink",
            name: "Rarible",
            description: "Multichain community-centric NFT marketplace. Create, sell and collect NFTs.",
            members: 4,
            activeMembers: 1,
            popularity: 4,
            available: true,
            tags: JSON.stringify([]),
            permissionsModel: PermissionsModel.channelsOnlyPermissionsModel,
            allTokenRequirementsMet: false
        },
        {
            featured: false,
            id: "id8",
            loaded: true,
            icon: ModelsData.icons.spotify,
            banner: "",
            color: "green",
            name: "Spotify",
            description: "Listening is everything",
            members: 3400,
            activeMembers: 200,
            popularity: 4,
            available: true,
            tags: JSON.stringify([
                {
                    "name": "Art",
                    "emoji": "🎨",
                },
                {
                    "name": "Blockchain",
                    "emoji": "🔗",
                },
                {
                    "name": "Books & blogs",
                    "emoji": "📚",
                },
                {
                    "name": "Career",
                    "emoji": "💼",
                },
            ]),
            permissionsModel: PermissionsModel.twoLongPermissionsModel,
            allTokenRequirementsMet: true,
            hasNotification: true,
            notificationsCount: 0
        },
        {
            featured: false,
            id: "id9",
            loaded: true,
            icon: ModelsData.icons.dribble,
            banner: "",
            color: "orange",
            name: "Dribbble",
            description: "Open source platform to write and distribute decentralized applications.",
            members: 6,
            activeMembers: 0,
            popularity: 4,
            available: true,
            tags: JSON.stringify([]),
            permissionsModel: emptyModel,
            allTokenRequirementsMet: false,
            hasNotification: true,
            notificationsCount: 100
        }
    ]
}
