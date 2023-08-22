import QtQuick 2.15

import utils 1.0

ListModel {

    readonly property string image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                                                     nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
    readonly property var data: [
        {
            contactId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04",
            name: "chris.eth",
            walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579262",
            imageSource: image,
            amount: 5,
            numberOfMessages: 3123,
            remotelyDestructState: Constants.ContractTransactionStatus.None
        },
        {
            contactId: "0x043a8ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04",
            name: "carmen.eth",
            walletAddress: "0xb794f5450ba39494ce839613fffba74279579261",
            imageSource: image,
            amount: 15,
            numberOfMessages: 123,
            remotelyDestructState: Constants.ContractTransactionStatus.InProgress
        },
        {
            contactId: "0x043a7ed0e9752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04",
            name: "emily.eth",
            walletAddress: "0xb794f5ea0ba39494ce839613fffba74279579263",
            imageSource: image,
            amount: 2,
            numberOfMessages: 3,
            remotelyDestructState: Constants.ContractTransactionStatus.Completed
        },
        {
            contactId: "",
            name: "",
            walletAddress: "0xb794f5ea0ba394782634hhh3fffba74279579264",
            imageSource: "",
            amount: 1,
            numberOfMessages: 0,
            remotelyDestructState: Constants.ContractTransactionStatus.Failed
        },
        {
            contactId: "",
            name: "",
            walletAddress: "0xc794f577990jjjjjewaofherfffba74279579265",
            imageSource: "",
            amount: 11,
            numberOfMessages: 0,
            remotelyDestructState: Constants.ContractTransactionStatus.None
        },
        {
            contactId: "",
            name: "",
            walletAddress: "0xd794f5ea009fnrsehggwe7777ffba74279579266",
            imageSource: "",
            amount: 14,
            numberOfMessages: 0,
            remotelyDestructState: Constants.ContractTransactionStatus.None
        }

    ]

    Component.onCompleted: append(data)
}
