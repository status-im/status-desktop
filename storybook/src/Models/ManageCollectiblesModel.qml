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
            collectionName: "",
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
            ]
        },
        {
            uid: "pp23",
            chainId: 5,
            userHas: 0,
            name: "pepepunk#23",
            collectionUid: "pepepunks",
            collectionName: "Pepepunks",
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
            ]
        },
        {
            uid: "34545656768",
            chainId: 420,
            userHas: 1,
            name: "Kitty 1",
            collectionUid: "KT",
            collectionName: "Kitties",
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
            ]
        },
        {
            uid: "123456",
            chainId: 420,
            userHas: 0,
            name: "Kitty 2",
            collectionUid: "KT",
            collectionName: "Kitties",
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
            ]
        },
        {
            uid: "12345645459537432",
            chainId: 421613,
            userHas: 0,
            name: "Big Kitty",
            collectionUid: "KT",
            collectionName: "Kitties",
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
            ]
        },
        {
            uid: "pp21",
            chainId: 421613,
            userHas: 0,
            name: "pepepunk#21",
            collectionUid: "pepepunks",
            collectionName: "Pepepunks",
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
            ]
        },
        {
            uid: "lp#666a",
            chainId: 421613,
            userHas: 0,
            name: "Lonely Panda #666",
            collectionUid: "lpan_collection",
            collectionName: "Lonely Panda Collection",
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
            ]
        },
    ]

    readonly property var communityData: [
        {
            uid: "fp#9140",
            chainId: 5,
            name: "Frenly Panda #9140",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "691",
            chainId: 421613,
            name: "KILLABEAR #691",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "8876",
            chainId: 421613,
            name: "KILLABEAR #2385",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "fp#3195",
            chainId: 5,
            name: "Frenly Panda #3195324354654756756756784234523",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "fp#4297",
            chainId: 5,
            name: "Frenly Panda #4297",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "fp#909",
            chainId: 5,
            name: "Frenly Panda #909",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "lb#666",
            chainId: 420,
            name: "Lonely Bear #666",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
        {
            uid: "lb#777",
            chainId: 420,
            name: "Lonely Turtle #777",
            collectionUid: "",
            collectionName: "",
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
            ]
        },
    ]

    Component.onCompleted: {
        fillData()
    }
}
