import QtQuick 2.15

import AppLayouts.Communities.controls 1.0

ListModel {
    readonly property var data: [
        {
            // This key will be tokenKey + account address
            key: "0",
            // This will correspond to a token in the flatTokensModel
            // here it corresponds to Unisocks in FlatTokensModel.qml
            tokenKey: "0",
            // This can be got via the LeftJoinModel with FlatTokensModel using "tokenKey"
            chainId: NetworksModel.ethNet,
            account: ModelsData.walletAccounts.account1Address,
            balance: "10"
        },
        {
            key: "1",
            tokenKey: "0",
            account: ModelsData.walletAccounts.account2Address,
            chainId: NetworksModel.ethNet,
            balance: "12"
        },
        {
            key: "2",
            tokenKey: "0",
            account: ModelsData.walletAccounts.account3Address,
            chainId: NetworksModel.ethNet,
            balance: "100"
        },
        {
            key: "3",
            tokenKey: "0",
            account: ModelsData.walletAccounts.account4Address,
            chainId: NetworksModel.ethNet,
            balance: "234234234"
        },
        {
            key: "4",
            tokenKey: "0",
            account: ModelsData.walletAccounts.account5Address,
            chainId: NetworksModel.ethNet,
            balance: "1000"
        },
        // Unisocks on opt
        {
            key: "5",
            tokenKey: "1",
            chainId: NetworksModel.optimismNet,
            account: ModelsData.walletAccounts.account1Address,
            balance: "100"
        },
        {
            key: "6",
            tokenKey: "1",
            account: ModelsData.walletAccounts.account2Address,
            chainId: NetworksModel.optimismNet,
            balance: "12300"
        },
        {
            key: "7",
            tokenKey: "1",
            account: ModelsData.walletAccounts.account3Address,
            chainId: NetworksModel.optimismNet,
            balance: "234234234"
        },
        // SNT on eth
        {
            key: "8",
            tokenKey: "8",
            chainId: NetworksModel.ethNet,
            account: ModelsData.walletAccounts.account1Address,
            balance: "12122323232"
        },
        {
            key: "9",
            tokenKey: "8",
            account: ModelsData.walletAccounts.account2Address,
            chainId: NetworksModel.ethNet,
            balance: "154545"
        },
        {
            key: "10",
            tokenKey: "8",
            account: ModelsData.walletAccounts.account3Address,
            chainId: NetworksModel.ethNet,
            balance: "4342"
        },
        {
            key: "11",
            tokenKey: "8",
            account: ModelsData.walletAccounts.account4Address,
            chainId: NetworksModel.ethNet,
            balance: "23"
        },
        {
            key: "12",
            tokenKey: "8",
            account: ModelsData.walletAccounts.account5Address,
            chainId: NetworksModel.ethNet,
            balance: "56"
        },
        // SNT on opt
        {
            key: "13",
            tokenKey: "7",
            chainId: NetworksModel.optimismNet,
            account: ModelsData.walletAccounts.account1Address,
            balance: "12"
        },
        {
            key: "14",
            tokenKey: "7",
            account: ModelsData.walletAccounts.account2Address,
            chainId: NetworksModel.optimismNet,
            balance: "145"
        },
        {
            key: "15",
            tokenKey: "7",
            account: ModelsData.walletAccounts.account3Address,
            chainId: NetworksModel.optimismNet,
            balance: "6556"
        },
        {
            key: "16",
            tokenKey: "7",
            account: ModelsData.walletAccounts.account4Address,
            chainId: NetworksModel.optimismNet,
            balance: "7000"
        }
    ]

    Component.onCompleted: append(data)
}
