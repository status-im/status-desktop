import QtQuick 2.15
import QtQml.Models 2.15

ListModel {
    property bool includeRegularCollectibles: true
    onIncludeRegularCollectiblesChanged: fillData()
    property bool includeCommunityCollectibles: true
    onIncludeCommunityCollectiblesChanged: fillData()

    function fillData() {
        clear()
        if (includeRegularCollectibles)
            append(data)
        if (includeCommunityCollectibles)
            append(communityData)
    }

    readonly property var data: [
        {
            uid: "123",
            chainId: 5,
            userHas: 9,
            name: "Punx not dead!",
            collectionUid: "",
            collectionName: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            collectionImageUrl: ModelsData.collectibles.cryptoPunks,
            communityId: "",
            communityName: "",
            communityImage: ModelsData.icons.status,
            imageUrl: ModelsData.collectibles.cryptoPunks,
            isLoading: false,
            backgroundColor: "",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 1
                },
                {
                    accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                    balance: "1",
                    txTimestamp: 2
                },
            ],
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum,
            description: "Punx not dead is a very rare CryptoKitty. It's a Gen 0 and has a lot of special traits.",
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
            tokenId: "403",
            twitterHandle: "@punxNotDead",
            website: "www.punxnotdead.com",
            isMetadataValid: true
        },
        {
            uid: "pp23",
            chainId: 5,
            userHas: 0,
            name: "pepepunk#23",
            collectionUid: "pepepunks",
            collectionName: "Pepepunks",
            collectionImageUrl: "https://i.seadn.io/s/raw/files/ba2811bb5cd0bed67529d69fa92ef5aa.jpg?auto=format&dpr=1&w=1000",
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: "https://i.seadn.io/s/raw/files/ba2811bb5cd0bed67529d69fa92ef5aa.jpg?auto=format&dpr=1&w=1000",
            isLoading: false,
            backgroundColor: "",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "8",
                    txTimestamp: 3
                },
            ],
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum,
            description: "pepepunk not dead is a very rare CryptoKitty. It's a Gen 0 and has a lot of special traits.",
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
            tokenId: "123",
            twitterHandle: "@pepepunks",
            website: "www.pepepunks.com",
            isMetadataValid: true
        },
        {
            uid: "34545656768",
            chainId: 11155420,
            userHas: 1,
            name: "Kitty 1",
            collectionUid: "KT",
            collectionName: "Kitties",
            collectionImageUrl: ModelsData.collectibles.kitty1Big,
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: ModelsData.collectibles.kitty1Big,
            isLoading: true,
            backgroundColor: "",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                    balance: "1",
                    txTimestamp: 3
                },
            ],
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum,
            description: "Furbeard is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
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
            tokenId: "7123",
            twitterHandle: "@kitties",
            website: "www.kitties.com",
            isMetadataValid: true
        },
        {
            uid: "123456",
            chainId: 11155420,
            userHas: 0,
            name: "Kitty 2",
            collectionUid: "KT",
            collectionName: "Kitties",
            collectionImageUrl: ModelsData.collectibles.kitty2Big,
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: ModelsData.collectibles.kitty2Big,
            isLoading: false,
            backgroundColor: "",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 6
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Furbeard is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
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
            tokenId: "403123",
            twitterHandle: "",
            website: "www.kitties.com",
            isMetadataValid: true
        },
        {
            uid: "12345645459537432",
            chainId: 421614,
            userHas: 0,
            name: "Big Kitty",
            collectionUid: "KT",
            collectionName: "Kitties",
            collectionImageUrl: ModelsData.collectibles.kitty3Big,
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: ModelsData.collectibles.kitty3Big,
            isLoading: false,
            backgroundColor: "",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 50
                },
                {
                    accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                    balance: "1",
                    txTimestamp: 10
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Big Kitty is a very rare CryptoKitty. It's a Gen 0 cat and has a lot of special traits.",
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
            tokenId: "1",
            twitterHandle: "@kitties",
            website: "",
            isMetadataValid: true
        },
        {
            uid: "pp21",
            chainId: 421614,
            userHas: 0,
            name: "pepepunk#21",
            collectionUid: "pepepunks",
            collectionName: "Pepepunks",
            collectionImageUrl: "https://i.seadn.io/s/raw/files/cfa559bb63e4378f17649c1e3b8f18fe.jpg?auto=format&dpr=1&w=1000",
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: "https://i.seadn.io/s/raw/files/cfa559bb63e4378f17649c1e3b8f18fe.jpg?auto=format&dpr=1&w=1000",
            isLoading: false,
            backgroundColor: "",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                    balance: "1",
                    txTimestamp: 16
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "pepepunk not dead is a very rare nft. It's a Gen 0 and has a lot of special traits.",
            traits: [
                {
                    traitType: "Type",
                    value: "Special"
                }
            ],
            tokenId: "12568",
            twitterHandle: "@pepepunks",
            website: "www.pepepunks.com",
            isMetadataValid: true
        },
        {
            uid: "lp#666a",
            chainId: 421614,
            userHas: 0,
            name: "Lonely Panda #666",
            collectionUid: "lpan_collection",
            collectionName: "Lonely Panda Collection",
            collectionImageUrl: "",
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: "",
            isLoading: false,
            backgroundColor: "ivory",
            permalink:"opensea.com",
            domain:"opensea",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 19
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Lonely Panda #666 is a very rare NFT. It's a Gen 0 and has a lot of special traits.likie sjasja sajhash jhasjas",
            traits: [
                {
                    traitType: "Type",
                    value: "Rare"
                }
            ],
            tokenId: "1445",
            twitterHandle: "@lonelyPanda",
            website: "www.lonelyPanda.com",
            isMetadataValid: true
        },
        {
            uid: "invalid#123",
            chainId: 421614,
            userHas: 0,
            name: "",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "",
            communityName: "",
            communityImage: "",
            imageUrl: "",
            isLoading: false,
            backgroundColor: "",
            permalink:"",
            domain:"",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 19
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "",
            traits: [],
            tokenId: "2121",
            twitterHandle: "",
            website: "",
            isMetadataValid: false
        }
    ]

    readonly property var communityData: [
        {
            uid: "fp#9140",
            chainId: 5,
            name: "Frenly Panda #9140",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/gae/qPfQjj4P1w0xVQXAmQJLmQ4ZtLFAJU6oiH69Lsny82LFbipLAgXhHKrcLBx2U09SmRnzeHY0ygz-3NIb-JegE_hWrZquFeL-qUPXPdw",
            isLoading: false,
            backgroundColor: "pink",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "15",
                    txTimestamp: 20
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Frenly Pandas is a community for all the fiendly pandas! Welcome onboard and enjoy :)",
            traits: [],
            tokenId: "4",
            isMetadataValid: true
        },
        {
            uid: "691",
            chainId: 421614,
            name: "KILLABEAR #691",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "bbrz",
            communityName: "Bearz",
            communityImage: "https://i.seadn.io/gcs/files/4a875f997063f4f3772190852c1c44f0.png?w=128&auto=format",
            imageUrl: "https://assets.killabears.com/content/killabears/gif/691-e81f892696a8ae700e0dbc62eb072060679a2046d1ef5eb2671bdb1fad1f68e3.gif",
            isLoading: true,
            backgroundColor: "navy",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "4",
                    txTimestamp: 21
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Bearz is a community for all the ferocious Bearz! Welcome onboard and enjoy :)",
            traits: [],
            tokenId: "3",
            isMetadataValid: true
        },
        {
            uid: "8876",
            chainId: 421614,
            name: "KILLABEAR #2385",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "bbrz",
            communityName: "Bearz",
            communityImage: "https://i.seadn.io/gcs/files/4a875f997063f4f3772190852c1c44f0.png?w=128&auto=format",
            imageUrl: "https://assets.killabears.com/content/killabears/transparent-512/2385-86ba13cc6945ed0aea7c32a363a96be2f218898358745ae07b947452cb7e4e79.png",
            isLoading: false,
            backgroundColor: "pink",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 22
                },
            ],
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum,
            description: "Bearz is a community for all the ferocious Bearz! Welcome onboard and enjoy :)",
            traits: [],
            tokenId: "341",
            isMetadataValid: true
        },
        {
            uid: "fp#3195",
            chainId: 5,
            name: "Frenly Panda #3195324354654756756756784234523",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/s/raw/files/59ad1f2e3c5eb5d4b62c06e200076514.png",
            isLoading: false,
            backgroundColor: "",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 23
                },
            ],
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum,
            description: "Frenly Pandas is a community for all the fiendly pandas! Welcome onboard and enjoy :)",
            traits: [],
            tokenId: "765",
            isMetadataValid: true
        },
        {
            uid: "fp#4297",
            chainId: 5,
            name: "Frenly Panda #4297",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/gae/K4_vmYtXAqU6LTnGDliLtJZc4UPmf9jUlk09_FDbXvSKKyUARyyV9RQEgXdb5bjje5OE9j9ZryC5pzcwBwH7TDOIl8oq7D2tSJ7p",
            isLoading: false,
            backgroundColor: "",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1000",
                    txTimestamp: 25
                },
            ],
            networkShortName: "ETH",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.ethereum,
            description: "Frenly Pandas is a community for all the fiendly pandas! Welcome onboard and enjoy :)",
            traits: [],
            tokenId: "166",
            isMetadataValid: true
        },
        {
            uid: "fp#909",
            chainId: 5,
            name: "Frenly Panda #909",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/gae/cR-Bjmb6DsrywCJMOqEBPkkrMHjbTzeRSAKIvLpd7i8ss6raYZ3-doh8oF2z8bJsnmfC1oR3kllz6UxMfFaYAKdXYzXlhfVsDHo6bg",
            isLoading: false,
            backgroundColor: "",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 26
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Frenly Pandas is a community for all the fiendly pandas! Welcome onboard and enjoy :)",
            traits: [],
            tokenId: "1111",
            isMetadataValid: true
        },
        {
            uid: "lb#666",
            chainId: 11155420,
            name: "Lonely Bear #666",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "lbear",
            communityName: "Lonely Bearz Community 0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            communityImage: "",
            imageUrl: "",
            isLoading: false,
            backgroundColor: "pink",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "60",
                    txTimestamp: 27
                },
                {
                    accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                    balance: "70",
                    txTimestamp: 60
                }
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Bearz is a community for all the ferocious Bearz! Welcome onboard and enjoy",
            traits: [],
            tokenId: "6",
            isMetadataValid: true
        },
        {
            uid: "lb#777",
            chainId: 11155420,
            name: "Lonely Turtle #777",
            collectionUid: "",
            collectionName: "",
            collectionImageUrl: "",
            communityId: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            communityName: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            communityImage: "",
            imageUrl: "",
            isLoading: false,
            backgroundColor: "pink",
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 27
                },
            ],
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            description: "Lonely Turtle is a community for all of us to talk and communicate! Welcome onboard and enjoy",
            traits: [],
            tokenId: "7",
            isMetadataValid: true
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
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 27
                },
            ],
            communityId: "",
            networkShortName: "ARB",
            networkColor: "blue",
            networkIconUrl: ModelsData.networks.arbitrum,
            isMetadataValid: true
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
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 27
                },
            ],
            communityId: "",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            isMetadataValid: true
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
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 27
                },
            ],
            communityId: "community-id-1",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            isMetadataValid: true
        },
        {
            uid: "ID-Community-Unknown",
            chainId: 1,
            contractAddress: "0x07",
            tokenId: "407",
            name: "Removed community token",
            imageUrl: ModelsData.collectibles.mana,
            backgroundColor: "transparent",
            description: "This is unkown community community token",
            collectionUid: "community-uid-unknown",
            collectionName: "",
            collectionImageUrl: "",
            traits: [],
            ownership: [
                {
                    accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    balance: "1",
                    txTimestamp: 27
                },
            ],
            communityId: "community-id-unknown",
            networkShortName: "OPT",
            networkColor: "red",
            networkIconUrl: ModelsData.networks.optimism,
            isMetadataValid: true
        }
    ]

    Component.onCompleted: {
        fillData()
    }
}
