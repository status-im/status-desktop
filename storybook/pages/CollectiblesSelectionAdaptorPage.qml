import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core.Utils
import StatusQ.Models

import AppLayouts.Wallet.controls
import AppLayouts.Wallet.adaptors
import utils

import Models
import Storybook

import QtModelsToolkit
import SortFilterProxyModel

Pane {
    id: root

    ListModel {
        id: listModel

        readonly property var data: [
            // collection 2
            {
                tokenId: "id_3",
                symbol: "abc",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-sequencer Test NFT 1",
                contractAddress: "contract_2",
                collectionName: "Multi-sequencer Test NFT",
                collectionUid: "collection_2",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059810
                    }
                ],
                imageUrl: Constants.tokenIcon("ETH", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "",
                communityName: "",
                communityImage: ""
            },
            {
                tokenId: "id_4",
                symbol: "def",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-sequencer Test NFT 2",
                contractAddress: "contract_2",
                collectionName: "Multi-sequencer Test NFT",
                collectionUid: "collection_2",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059811
                    }
                ],
                imageUrl: Constants.tokenIcon("ETH", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "",
                communityName: "",
                communityImage: ""
            },
            {
                tokenId: "id_5",
                symbol: "ghi",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-sequencer Test NFT 3",
                contractAddress: "contract_2",
                collectionName: "Multi-sequencer Test NFT",
                collectionUid: "collection_2",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059899
                    }
                ],
                imageUrl: Constants.tokenIcon("ETH", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "",
                communityName: "",
                communityImage: ""
            },
            // collection 1
            {
                tokenId: "id_1",
                symbol: "jkl",
                chainId: NetworksModel.mainnetChainId,
                name: "Genesis",
                contractAddress: "contract_1",
                collectionName: "ERC-1155 Faucet",
                collectionUid: "collection_1",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 23,
                        txTimestamp: 1714059862
                    },
                    {
                        accountAddress: "account_2",
                        balance: 29,
                        txTimestamp: 1714054862
                    }
                ],
                imageUrl: Constants.tokenIcon("DAI", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "",
                communityName: "",
                communityImage: ""
            },
            {
                tokenId: "id_2",
                symbol: "mno",
                chainId: NetworksModel.mainnetChainId,
                name: "QAERC1155",
                contractAddress: "contract_1",
                collectionName: "ERC-1155 Faucet",
                collectionUid: "collection_1",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 500,
                        txTimestamp: 1714059864
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "",
                communityName: "",
                communityImage: ""
            },
            // collection 3, community token
            {
                tokenId: "id_6",
                symbol: "pqr",
                chainId: NetworksModel.optChainId,
                name: "My Token",
                contractAddress: "contract_3",
                collectionName: "My Token",
                collectionUid: "collection_3",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059899
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_1",
                communityName: "My community",
                communityImage: Constants.tokenIcon("KIN", false)
            },
            {
                tokenId: "id_7",
                symbol: "stu",
                chainId: NetworksModel.optChainId,
                name: "My Token",
                contractAddress: "contract_3",
                collectionName: "My Token",
                collectionUid: "collection_3",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059899
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_1",
                communityName: "My community",
                communityImage: Constants.tokenIcon("KIN", false)
            },
            {
                tokenId: "id_8",
                symbol: "vwx",
                chainId: NetworksModel.optChainId,
                name: "My Token",
                contractAddress: "contract_3",
                collectionName: "My Token",
                collectionUid: "collection_3",
                ownership: [
                    {
                        accountAddress: "account_2",
                        balance: 1,
                        txTimestamp: 1714059999
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_1",
                communityName: "My community",
                communityImage: Constants.tokenIcon("KIN", false)
            },
            {
                tokenId: "id_9",
                symbol: "yz1",
                chainId: NetworksModel.optChainId,
                name: "My Other Token",
                contractAddress: "contract_4",
                collectionName: "My Other Token",
                collectionUid: "collection_4",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059991
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_1",
                communityName: "My community",
                communityImage: Constants.tokenIcon("KIN", false)
            },
            {
                tokenId: "id_10",
                symbol: "234",
                chainId: NetworksModel.arbChainId,
                name: "My Community 2 Token",
                contractAddress: "contract_5",
                collectionName: "My Community 2 Token",
                collectionUid: "collection_5",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059777
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_2",
                communityName: "My community 2",
                communityImage: Constants.tokenIcon("ICOS", false)
            },
            {
                tokenId: "id_11",
                symbol: "567",
                chainId: NetworksModel.arbChainId,
                name: "My Community 2 Token",
                contractAddress: "contract_5",
                collectionName: "My Community 2 Token",
                collectionUid: "collection_5",
                ownership: [
                    {
                        accountAddress: "account_1",
                        balance: 1,
                        txTimestamp: 1714059778
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_2",
                communityName: "My community 2",
                communityImage: Constants.tokenIcon("ICOS", false)
            },
            {
                tokenId: "id_11",
                symbol: "8910",
                chainId: NetworksModel.arbChainId,
                name: "My Community 2 Token",
                contractAddress: "contract_5",
                collectionName: "My Community 2 Token",
                collectionUid: "collection_5",
                ownership: [
                    {
                        accountAddress: "account_2",
                        balance: 1,
                        txTimestamp: 1714059779
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_2",
                communityName: "My community 2",
                communityImage: Constants.tokenIcon("ICOS", false)
            },
            {
                tokenId: "id_12",
                symbol: "111213",
                chainId: NetworksModel.arbChainId,
                name: "My Community 2 Token",
                contractAddress: "contract_5",
                collectionName: "My Community 2 Token",
                collectionUid: "collection_5",
                ownership: [
                    {
                        accountAddress: "account_3",
                        balance: 1,
                        txTimestamp: 1714059779
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_2",
                communityName: "My community 2",
                communityImage: Constants.tokenIcon("ICOS", false)
            },
            {
                tokenId: "id_13",
                symbol: "141516",
                chainId: NetworksModel.arbChainId,
                name: "My Community 2 Token",
                contractAddress: "contract_5",
                collectionName: "My Community 2 Token",
                collectionUid: "collection_5",
                ownership: [
                    {
                        accountAddress: "account_3",
                        balance: 1,
                        txTimestamp: 1714059788
                    }
                ],
                imageUrl: Constants.tokenIcon("ZRX", false),
                mediaUrl: Qt.resolvedUrl(""),
                communityId: "community_2",
                communityName: "My community 2",
                communityImage: Constants.tokenIcon("ICOS", false)
            }
        ]

        Component.onCompleted: {
            append(data)

            const accounts = new Set()

            data.forEach(e => e.ownership.forEach(
                             e => { accounts.add(e.accountAddress) }))

            Qt.callLater(() => {
                if (accountsSelector)
                    accountsSelector.model = [...accounts.values()]
            })
        }
    }

    CollectiblesSelectionAdaptor {
        id: adaptor

        networksModel: NetworksModel.flatNetworks
        enabledChainIds: [networksCombobox.currentValue]
        collectiblesModel: listModel
        accountKey: accountsSelector.selection
    }

    ColumnLayout {
        anchors.fill: parent

        TokenSelector {
            collectiblesModel: adaptor.model
        }

        RowLayout {
            Label { text: "Accounts:" }

            RadioButtonFlowSelector {
                id: accountsSelector

                Layout.fillWidth: true
            }
        }

        RowLayout {
            Label { text: "Enabled Networks:" }

            ComboBox {
                id: networksCombobox
                model: NetworksModel.flatNetworks
                textRole: "chainName"
                valueRole: "chainId"
                currentIndex: 0
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

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollBar.vertical: ScrollBar {}
                clip: true
                spacing: 5

                model: adaptor.model

                delegate: ColumnLayout {
                    width: ListView.view.width

                    readonly property var submodel: model.subitems
                    readonly property int submodelCount:
                        model.subitems.ModelCount.count

                    Label {
                        text: (model.communityId ? "Community" : "Collection")
                              + `: ${model.groupName} (count: ${submodelCount})`
                    }

                    Repeater {
                        model: submodel

                        Label {
                            text: "\t" + model.name + " (balance: " + model.balance + "), key: " + model.key
                        }
                    }
                }

                section.property: "type"
                section.delegate: Label {
                    text: section
                    font.underline: true
                    font.bold: true
                    bottomPadding: 10
                }
            }
        }
    }
}

// category: Adaptors
