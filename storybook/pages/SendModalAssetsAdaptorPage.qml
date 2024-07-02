import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Models 0.1

import Storybook 1.0

import utils 1.0
import shared.popups.send.models 1.0

Item {
    id: root

    ListModel {
        id: listModel

        readonly property var data: [
            {
                tokensKey: "key_ETH",
                name: "Ether",
                symbol: "ETH",
                addressPerChain: [
                    { chainId: 1, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 5, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 10, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 420, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 42161, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 421613, address: "0x0000000000000000000000000000000000000000"}
                ],
                balances: [
                    {
                        chainId: "chain_id_1",
                        balance: "186316672770338050",
                        account: "account_1",
                    },
                    {
                        chainId: "chain_id_1",
                        balance: "386318672772348050",
                        account: "account_2",
                    },
                    {
                        chainId: "chain_id_2",
                        balance: "186311232772348990",
                        account: "account_1",
                    },
                    {
                        chainId: "chain_id_2",
                        balance: "986317232772348990",
                        account: "account_1",
                    }
                ],
                decimals: 18,
                communityId: "",
                communityName: "",
                communityImage: Qt.resolvedUrl(""),
                marketDetails: {
                    changePct24hour: -2.1232,
                    currencyPrice: {
                        amount: 3423.23898
                    }
                },
                detailsLoading: false,
                image: Qt.resolvedUrl("")
            },
            {
                tokensKey: "key_SNT",
                name: "Status",
                symbol: "SNT",
                addressPerChain: [
                    { chainId: 1, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 5, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 10, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 420, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 42161, address: "0x0000000000000000000000000000000000000000"},
                    { chainId: 421613, address: "0x0000000000000000000000000000000000000000"}
                ],
                balances: [
                    {
                        chainId: "chain_id_1",
                        balance: "386316672770338850",
                        account: "account_1",
                    },
                    {
                        chainId: "chain_id_1",
                        balance: "377778672772348050",
                        account: "account_2",
                    },
                    {
                        chainId: "chain_id_2",
                        balance: "146311232772348990",
                        account: "account_1",
                    },
                    {
                        chainId: "chain_id_3",
                        balance: "86317232772348990",
                        account: "account_1",
                    }
                ],
                decimals: 18,
                communityId: "",
                communityName: "",
                communityImage: Qt.resolvedUrl(""),
                marketDetails: {
                    changePct24hour: 9.232,
                    currencyPrice: {
                        amount: 33.23898
                    }
                },
                detailsLoading: false,
                image: Qt.resolvedUrl("")
            },
            {
                tokensKey: "key_MYASST",
                name: "Community Asset",
                symbol: "MYASST",
                balances: [
                    {
                        chainId: "chain_id_1",
                        balance: "23234",
                        account: "account_1",
                    },
                    {
                        chainId: "chain_id_1",
                        balance: "63234",
                        account: "account_2",
                    }
                ],
                decimals: 3,
                communityId: "0x033f36ccb",
                communityName: "My Community",
                communityImage: Constants.tokenIcon("DAI", false),
                marketDetails: {
                    changePct24hour: 0,
                    currencyPrice: {
                        amount: 0
                    }
                },
                detailsLoading: false,
                image: Constants.tokenIcon("ZRX", false)
            }
        ]

        Component.onCompleted: {
            append(data)

            const accounts = new Set()

            data.forEach(e => e.balances.forEach(
                             e => { accounts.add(e.account) }))

            accountsSelector.model = [...accounts.values()]
        }
    }

    ManageTokensController {
        id: manageTokensController

        sourceModel: listModel
        serializeAsCollectibles: false

        onRequestLoadSettings: {
            loadingStarted()

            const jsonData = [
                {
                    "key": "ETH",
                    "position": 1,
                    "visible": true
                },
                {
                    "key": "SNT",
                    "position": 2,
                    "visible": true
                },
                {
                    "key": "MYASST",
                    "position": 5,
                    "visible": true
                }
            ]

            loadingFinished(JSON.stringify(jsonData))
        }
    }


    SendModalAssetsAdaptor {
        id: adaptor

        controller: manageTokensController
        account: accountsSelector.selection[0]
        tokensModel: listModel
    }

    ColumnLayout {
        anchors.fill: parent

        Label { text: "ACCOUNTS:" }

        CheckBoxFlowSelector {
            id: accountsSelector

            Layout.fillWidth: true
            initialSelection: true
            exclusive: true
        }

        RowLayout {
            GenericListView {
                label: "Input model"

                model: listModel

                Layout.fillWidth: true
                Layout.fillHeight: true

                skipEmptyRoles: true
            }

            GenericListView {
                label: "Adapter's output model"

                model: adaptor.model

                Layout.fillWidth: true
                Layout.fillHeight: true

                roles:
                    ["key", "error", "currentBalance", "currentCurrencyBalance", "currentBalanceText",
                     "icon", "visible", "marketDetailsAvailable", "marketDetailsLoading",
                     "marketPrice", "marketChangePct24hour", "isCommunityAsset", "balancesModel"]

                skipEmptyRoles: true
            }
        }
    }
}

// category: Adaptors
