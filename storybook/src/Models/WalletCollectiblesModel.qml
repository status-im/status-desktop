import QtQuick 2.15

import StatusQ.Core 0.1
import utils 1.0

ListModel {
    readonly property var rootData: [
        {
            uid: "ID-Kitty1",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "1",
            name: "Furbeard",
            imageUrl: ModelsData.collectibles.kitty1Big,
            backgroundColor: "#f5f5f5",
            description: "Furbeard is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            collectionImageUrl: ModelsData.collectibles.cryptoKitties,
            traits: [
                {
                    traitType: "Fur",
                    value: "White"
                },
                {
                    traitType: "Eyes",
                    value: "Green"
                },
                {
                    traitType: "Pattern",
                    value: "Tigerpunk"
                }
            ],
            communityId: "",
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum
        },
        {
            uid: "ID-Kitty2",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "2",
            name: "Magicat",
            imageUrl: ModelsData.collectibles.kitty2Big,
            backgroundColor: "transparent",
            description: "Magicat is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            collectionImageUrl: ModelsData.collectibles.cryptoKitties,
            traits: [
                {
                    traitType: "Fur",
                    value: "White"
                },
                {
                    traitType: "Eyes",
                    value: "Blue"
                },
                {
                    traitType: "Pattern",
                    value: "Tigerpunk"
                }
            ],
            communityId: "",
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum
        },
        {
            uid: "ID-Kitty3",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "3",
            name: "Happy Meow",
            imageUrl: ModelsData.collectibles.kitty3Big,
            backgroundColor: "blue",
            description: "Happy Meow is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            collectionImageUrl: ModelsData.collectibles.cryptoKitties,
            traits: [
                {
                    traitType: "Fur",
                    value: "White"
                },
                {
                    traitType: "Eyes",
                    value: "Green"
                },
                {
                    traitType: "Pattern",
                    value: "Tigerpunk"
                }
            ],
            communityId: "",
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum
        },
        {
            uid: "ID-Kitty4",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "4",
            name: "Furbeard-2",
            imageUrl: ModelsData.collectibles.kitty4Big,
            backgroundColor: "red",
            description: "Furbeard-2 is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            collectionImageUrl: ModelsData.collectibles.cryptoKitties,
            traits: [
                {
                    traitType: "Fur",
                    value: "White"
                },
                {
                    traitType: "Eyes",
                    value: "Green"
                },
                {
                    traitType: "Pattern",
                    value: "Tigerpunk"
                }
            ],
            communityId: "",
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum
        },
        {
            uid: "ID-Kitty5",
            chainId: 1,
            contractAddress: "0x1",
            tokenId: "4",
            name: "Magicat-3",
            imageUrl: ModelsData.collectibles.kitty5Big,
            backgroundColor: "yellow",
            description: "Magicat-3 is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
            collectionUid: "cryptokitties",
            collectionName: "CryptoKitties",
            collectionImageUrl: ModelsData.collectibles.cryptoKitties,
            traits: [
                {
                    traitType: "Fur",
                    value: "White"
                },
                {
                    traitType: "Eyes",
                    value: "Blue"
                },
                {
                    traitType: "Pattern",
                    value: "Tigerpunk"
                }
            ],
            communityId: "",
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum
        },
        {
            uid: "ID-Anniversary",
            chainId: 1,
            contractAddress: "0x2",
            tokenId: "1",
            name: "Anniversary",
            imageUrl: ModelsData.collectibles.anniversary,
            backgroundColor: "black",
            description: "This is a special collectible to celebrate the anniversary of the platform.",
            collectionUid: "anniversary",
            collectionName: "Anniversary",
            collectionImageUrl: ModelsData.collectibles.anniversary,
            traits: [
                {
                    traitType: "Type",
                    value: "Special"
                }
            ],
            communityId: "",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism
        },
        {
            uid: "ID-SuperRare",
            chainId: 1,
            contractAddress: "0x3",
            tokenId: "101",
            name: "SuperRare",
            imageUrl: ModelsData.collectibles.superRare,
            backgroundColor: "transparent",
            description: "This is a very rare collectible. It's a unique piece of art.",
            collectionUid: "super-rare",
            collectionName: "SuperRare",
            collectionImageUrl: ModelsData.collectibles.doodles,
            traits: [
                {
                    traitType: "Type",
                    value: "Rare"
                }
            ],
            communityId: "",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism
        },
        {
            uid: "ID-Custom",
            chainId: 1,
            contractAddress: "0x04",
            tokenId: "403",
            name: "Custom Collectible",
            imageUrl: ModelsData.collectibles.custom,
            backgroundColor: "transparent",
            description: "This is a custom collectible. It's a unique piece of art.",
            collectionUid: "custom",
            collectionName: "Custom",
            collectionImageUrl: "",
            traits: [],
            communityId: "",
            networkShortName: "ARB",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.arbitrum
        },
        {
            uid: "ID-MissingMetadata",
            chainId: 1,
            contractAddress: "0x05",
            tokenId: "405",
            name: "",
            imageUrl: "",
            backgroundColor: "transparent",
            description: "",
            collectionUid: "missing",
            collectionName: "",
            collectionImageUrl: "",
            traits: [],
            communityId: "",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism
        },
        {
            uid: "ID-Community1",
            chainId: 1,
            contractAddress: "0x06",
            tokenId: "406",
            name: "Community Admin Token",
            imageUrl: ModelsData.collectibles.mana,
            backgroundColor: "transparent",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
            collectionUid: "community-uid-1",
            collectionName: "",
            collectionImageUrl: "",
            traits: [],
            communityId: "community-id-1",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism
        }
    ]

    Component.onCompleted: append(rootData)
}
