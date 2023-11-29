import QtQuick 2.15
import QtQml.Models 2.15

import Models 1.0

ListModel {
    function randomizeData() {
        // TODO
    }

    readonly property var data: [
        {
            uid: "fp#9140",
            name: "Frenly Panda #9140",
            collectionUid: "",
            collectionName: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/gae/qPfQjj4P1w0xVQXAmQJLmQ4ZtLFAJU6oiH69Lsny82LFbipLAgXhHKrcLBx2U09SmRnzeHY0ygz-3NIb-JegE_hWrZquFeL-qUPXPdw",
            isLoading: false,
            backgroundColor: "pink"
        },
        {
            uid: "123",
            name: "Punx not dead!",
            collectionUid: "",
            collectionName: "",
            communityId: "",
            communityName: "",
            imageUrl: ModelsData.collectibles.cryptoPunks,
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "pp23",
            name: "pepepunk#23",
            collectionUid: "pepepunks",
            collectionName: "Pepepunks",
            communityId: "",
            communityName: "",
            imageUrl: "https://i.seadn.io/s/raw/files/ba2811bb5cd0bed67529d69fa92ef5aa.jpg?auto=format&dpr=1&w=1000",
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "34545656768",
            name: "Kitty 1",
            collectionUid: "KT",
            collectionName: "Kitties",
            communityId: "",
            communityName: "",
            imageUrl: ModelsData.collectibles.kitty1Big,
            isLoading: true,
            backgroundColor: ""
        },
        {
            uid: "123456",
            name: "Kitty 2",
            collectionUid: "KT",
            collectionName: "Kitties",
            communityId: "",
            communityName: "",
            imageUrl: ModelsData.collectibles.kitty2Big,
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "12345645459537432",
            name: "Big Kitty",
            collectionUid: "KT",
            collectionName: "Kitties",
            communityId: "",
            communityName: "",
            imageUrl: ModelsData.collectibles.kitty3Big,
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "691",
            name: "KILLABEAR #691",
            collectionUid: "",
            collectionName: "",
            communityId: "bbrz",
            communityName: "Bearz",
            communityImage: "https://i.seadn.io/gcs/files/4a875f997063f4f3772190852c1c44f0.png?w=128&auto=format",
            imageUrl: "https://assets.killabears.com/content/killabears/gif/691-e81f892696a8ae700e0dbc62eb072060679a2046d1ef5eb2671bdb1fad1f68e3.gif",
            isLoading: true,
            backgroundColor: "navy"
        },
        {
            uid: "8876",
            name: "KILLABEAR #2385",
            collectionUid: "",
            collectionName: "",
            communityId: "bbrz",
            communityName: "Bearz with a very long name",
            communityImage: "https://i.seadn.io/gcs/files/4a875f997063f4f3772190852c1c44f0.png?w=128&auto=format",
            imageUrl: "https://assets.killabears.com/content/killabears/transparent-512/2385-86ba13cc6945ed0aea7c32a363a96be2f218898358745ae07b947452cb7e4e79.png",
            isLoading: false,
            backgroundColor: "pink"
        },
        {
            uid: "fp#3195",
            name: "Frenly Panda #3195324354654756756756784234523",
            collectionUid: "",
            collectionName: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/s/raw/files/59ad1f2e3c5eb5d4b62c06e200076514.png",
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "fp#4297",
            name: "Frenly Panda #4297",
            collectionUid: "",
            collectionName: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/gae/K4_vmYtXAqU6LTnGDliLtJZc4UPmf9jUlk09_FDbXvSKKyUARyyV9RQEgXdb5bjje5OE9j9ZryC5pzcwBwH7TDOIl8oq7D2tSJ7p",
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "fp#909",
            name: "Frenly Panda #909",
            collectionUid: "",
            collectionName: "",
            communityId: "fpan",
            communityName: "Frenly Pandas",
            communityImage: "https://pbs.twimg.com/profile_images/1599347398769143808/C6qG3RQv_400x400.jpg",
            imageUrl: "https://i.seadn.io/gae/cR-Bjmb6DsrywCJMOqEBPkkrMHjbTzeRSAKIvLpd7i8ss6raYZ3-doh8oF2z8bJsnmfC1oR3kllz6UxMfFaYAKdXYzXlhfVsDHo6bg",
            isLoading: false,
            backgroundColor: ""
        },
        {
            uid: "pp21",
            name: "pepepunk#21",
            collectionUid: "pepepunks",
            collectionName: "Pepepunks",
            communityId: "",
            communityName: "",
            imageUrl: "https://i.seadn.io/s/raw/files/cfa559bb63e4378f17649c1e3b8f18fe.jpg?auto=format&dpr=1&w=1000",
            isLoading: false,
            backgroundColor: ""
        },
    ]

    Component.onCompleted: append(data)
}
