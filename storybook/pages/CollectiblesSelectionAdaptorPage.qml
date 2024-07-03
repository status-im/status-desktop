import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Models 0.1

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.adaptors 1.0
import utils 1.0

import Storybook 1.0

import SortFilterProxyModel 0.2

Pane {
    id: root

    ListModel {
        id: listModel

        readonly property var data: [
            // collection 2
            {
                tokenId: "id_3",
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
                communityImage: Qt.resolvedUrl("")
            },
            {
                tokenId: "id_4",
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
                communityImage: Qt.resolvedUrl("")
            },
            {
                tokenId: "id_5",
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
                communityImage: Qt.resolvedUrl("")
            },
            // collection 1
            {
                tokenId: "id_1",
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
                communityImage: Qt.resolvedUrl("")
            },
            {
                tokenId: "id_2",
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
                communityImage: Qt.resolvedUrl("")
            },
            // collection 3, community token
            {
                tokenId: "id_6",
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

            accountsSelector.model = [...accounts.values()]
        }
    }

    CollectiblesSelectionAdaptor {
        id: adaptor

        collectiblesModel: listModel
        accountKey: accountsSelector.selection
    }

    ColumnLayout {
        anchors.fill: parent

        TokenSelectorNew {
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
