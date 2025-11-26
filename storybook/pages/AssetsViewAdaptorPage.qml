import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Models

import Storybook

import utils
import shared.views

Item {
    id: root

    ListModel {
        id: listModel

        readonly property var data: [
            {
                key: Constants.ethGroupKey,
                name: "Ether",
                symbol: "ETH",
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
                communityImage: "",
                marketDetails: {
                    changePct24hour: -2.1232,
                    currencyPrice: {
                        amount: 3423.23898
                    }
                },
                detailsLoading: false,
                logoUri: "",
                position: 1,
                visible: true
            },
            {
                key: Constants.sntGroupKey,
                name: "Status",
                symbol: "SNT",
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
                communityImage: "",
                marketDetails: {
                    changePct24hour: 9.232,
                    currencyPrice: {
                        amount: 33.23898
                    }
                },
                detailsLoading: false,
                logoUri: "",
                position: 2,
                visible: true
            },
            {
                key: "key_MYASST",
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
                logoUri: Constants.tokenIcon("ZRX", false),
                position: 5,
                visible: true
            }
        ]

        Component.onCompleted: {
            append(data)

            const chains = new Set()
            const accounts = new Set()

            data.forEach(e => e.balances.forEach(
                             e => { chains.add(e.chainId);
                                    accounts.add(e.account)}))

            chainsSelector.model = [...chains.values()]
            chainsDownSelector.model = [...chains.values()]
            accountsSelector.model = [...accounts.values()]
        }
    }

    AssetsViewAdaptor {
        id: adaptor

        chains: chainsSelector.selection
        accounts: accountsSelector.selection

        marketValueThreshold: minimumBalanceSlider.value

        chainsError: chains => {
            const chainsDown = chainsDownSelector.selection
            const downForToken = chains.filter(value => chainsDown.includes(value))

            if (downForToken.length)
                return "Chains down: " + JSON.stringify(downForToken)

            return ""
        }

        tokensModel: listModel
    }

    ColumnLayout {
        anchors.fill: parent

        Label { text: "CHAINS:" }

        CheckBoxFlowSelector {
            id: chainsSelector

            Layout.fillWidth: true
            initialSelection: true
        }

        Label { text: "CHAINS DOWN:" }

        CheckBoxFlowSelector {
            id: chainsDownSelector

            Layout.fillWidth: true
        }

        Label { text: "ACCOUNTS:" }

        CheckBoxFlowSelector {
            id: accountsSelector

            Layout.fillWidth: true
            initialSelection: true
        }

        Label { text: "MINIMUM BALANCE:" }

        RowLayout {
            Slider {
                id: minimumBalanceSlider

                from: 0.1
                to: 100

                value: 10
            }
            Label {
                text: minimumBalanceSlider.value
            }
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
                    ["key", "symbol", "name", "icon", "error", "balance", "balanceText",
                     "marketDetailsAvailable", "marketDetailsLoading",
                     "marketPrice", "marketChangePct24hour", "communityId",
                     "communityName", "communityIcon", "position", "canBeHidden"]

                skipEmptyRoles: true
            }
        }
    }
}

// category: Adaptors
