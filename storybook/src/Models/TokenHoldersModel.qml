import QtQuick 2.15

ListModel {

    readonly property string image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                                                     nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
    readonly property var data: [
        {
            ensName: "carmen.eth",
            walletAddress: "0xb794f5450ba39494ce839613fffba74279579268",
            imageSource: image,
            amount: 3
        },
        {
            ensName: "chris.eth",
            walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
            imageSource: image,
            amount: 2
        },
        {
            ensName: "emily.eth",
            walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
            imageSource: image,
            amount: 2
        },
        {
            ensName: "",
            walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579268",
            imageSource: "",
            amount: 1
        }
    ]

    Component.onCompleted: append(data)
}
