import QtQuick 2.15
import QtQuick.Controls 2.15

import SortFilterProxyModel 0.2

import Models 1.0
import Storybook 1.0

import AppLayouts.Wallet.popups.simpleSend 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.adaptors 1.0

import utils 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    QtObject {
        id: d

        readonly property SortFilterProxyModel filteredNetworksModel: SortFilterProxyModel {
            sourceModel: NetworksModel.flatNetworks
            filters: ValueFilter { roleName: "isTest"; value: testNetworksCheckbox.checked }
        }

        readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
            assetsWithFilteredBalances: groupedAccountsAssetsModel
        }

        readonly property var walletAccountsModel: WalletAccountsModel{}
    }

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !simpleSend.visible

            onClicked: simpleSend.open()
        }

        Component.onCompleted: simpleSend.open()
    }

    SimpleSendModal {
        id: simpleSend

        visible: true
        modal: false
        closePolicy: Popup.CloseOnEscape

        accountsModel: d.walletAccountsModel
        assetsModel: assetsSelectorViewAdaptor.outputAssetsModel
        collectiblesModel: collectiblesSelectionAdaptor.model
        networksModel: d.filteredNetworksModel
        Component.onCompleted: simpleSend.open()
    }

    TokenSelectorViewAdaptor {
        id: assetsSelectorViewAdaptor

        assetsModel: d.walletAssetStore.groupedAccountAssetsModel

        flatNetworksModel: NetworksModel.flatNetworks

        currentCurrency: "USD"
        accountAddress: simpleSend.selectedAccountAddress
        showCommunityAssets: true
        enabledChainIds: [simpleSend.selectedChainId]
    }

    CollectiblesSelectionAdaptor {
        id: collectiblesSelectionAdaptor

        accountKey: simpleSend.selectedAccountAddress

        networksModel: d.filteredNetworksModel
        collectiblesModel: collectiblesBySymbolModel
    }

    ListModel {
        id: collectiblesBySymbolModel

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
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                symbol: "def",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-sequencer Test NFT 2",
                contractAddress: "contract_2",
                collectionName: "Multi-sequencer Test NFT",
                collectionUid: "collection_2",
                ownership: [
                    {
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                symbol: "ghi",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-sequencer Test NFT 3",
                contractAddress: "contract_2",
                collectionName: "Multi-sequencer Test NFT",
                collectionUid: "collection_2",
                ownership: [
                    {
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                symbol: "jkl",
                chainId: NetworksModel.mainnetChainId,
                name: "Genesis",
                contractAddress: "contract_1",
                collectionName: "ERC-1155 Faucet",
                collectionUid: "collection_1",
                ownership: [
                    {
                        accountAddress: d.walletAccountsModel.accountAddress1,
                        balance: 23,
                        txTimestamp: 1714059862
                    },
                    {
                        accountAddress: d.walletAccountsModel.accountAddress2,
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
                symbol: "mno",
                chainId: NetworksModel.mainnetChainId,
                name: "QAERC1155",
                contractAddress: "contract_1",
                collectionName: "ERC-1155 Faucet",
                collectionUid: "collection_1",
                ownership: [
                    {
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                symbol: "pqr",
                chainId: NetworksModel.optChainId,
                name: "My Token",
                contractAddress: "contract_3",
                collectionName: "My Token",
                collectionUid: "collection_3",
                ownership: [
                    {
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                        accountAddress: d.walletAccountsModel.accountAddress2,
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
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                        accountAddress: d.walletAccountsModel.accountAddress1,
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
                        accountAddress: d.walletAccountsModel.accountAddress2,
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
                        accountAddress: d.walletAccountsModel.accountAddress3,
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
                        accountAddress: d.walletAccountsModel.accountAddress3,
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
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.minimumWidth: 300

        CheckBox {
            id: testNetworksCheckbox
            text: "are test networks enabled"
        }
    }
}

// category: Popups
