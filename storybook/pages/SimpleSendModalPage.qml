import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Backpressure 0.1

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
            walletTokensStore: TokensStore {
                plainTokensBySymbolModel: TokensBySymbolModel{}
                getDisplayAssetsBelowBalanceThresholdDisplayAmount: () => 0
            }
        }

        readonly property var walletAccountsModel: WalletAccountsModel{}

        function getCurrencyAmount(amount, symbol) {
            return ({
                        amount: amount,
                        symbol: symbol ? symbol.toUpperCase() : root.currentCurrency,
                        displayDecimals: 2,
                        stripTrailingZeroes: false
                    })
        }

        readonly property var savedAddressesModel: ListModel {
            Component.onCompleted: {
                for (let i = 0; i < 10; i++)
                    append({
                               name: "some saved addr name " + i,
                               ens: [],
                               address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4",
                           })
                append({
                           name: "some saved ENS name ",
                           ens: ["me@status.eth"],
                           address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4",
                       })
            }
        }

        property var setFees: Backpressure.debounce(root, 1500, function () {
            simpleSend.routesLoading = false
            simpleSend.estimatedTime = "~60s"
            simpleSend.estimatedFiatFees = "1.45 EUR"
            simpleSend.estimatedCryptoFees = "0.0007 ETH"
            simpleSend.routerErrorCode = Constants.routerErrorCodes.router.errNotEnoughNativeBalance
            simpleSend.routerError = qsTr("Not enough ETH to pay gas fees")
            simpleSend.routerErrorDetails = ""
        })

        function formatCurrencyAmount(amount, symbol, options = null, locale = null) {
            if (isNaN(amount)) {
                return "N/A"
            }
            var currencyAmount = d.getCurrencyAmount(amount, symbol)
            return LocaleUtils.currencyAmountToLocaleString(currencyAmount, options, locale)
        }

        function resetRouterValues() {
            simpleSend.estimatedCryptoFees = ""
            simpleSend.estimatedFiatFees = ""
            simpleSend.estimatedTime = ""
            simpleSend.routerErrorCode = ""
            simpleSend.routerError = ""
            simpleSend.routerErrorDetails = ""
        }
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

        interactive: interactiveCheckbox.checked

        accountsModel: accountsSelectorAdaptor.processedWalletAccounts
        assetsModel: assetsSelectorViewAdaptor.outputAssetsModel
        collectiblesModel: collectiblesSelectionAdaptor.model
        networksModel: d.filteredNetworksModel

        savedAddressesModel: d.savedAddressesModel
        recentRecipientsModel: WalletTransactionsModel{}

        currentCurrency: "USD"
        fnFormatCurrencyAmount: d.formatCurrencyAmount

        fnResolveENS: Backpressure.debounce(root, 500, function (ensName, uuid) {
            if (!!ensName && ensName.endsWith(".eth")) {
                // return some valid address
                simpleSend.ensNameResolved(ensName, "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4", uuid)
            } else {
                simpleSend.ensNameResolved(ensName, "", uuid) // invalid
            }
        })

        onFormChanged: {
            d.resetRouterValues()
            if(allValuesFilledCorrectly) {
                console.log("Fetch fees...")
                routesLoading = true
                d.setFees()
            }
        }

        onReviewSendClicked: console.log("Review send clicked")
        onLaunchBuyFlow: console.log("launch buy flow clicked")

        Binding on selectedAccountAddress {
            value: accountsCombobox.currentValue ?? ""
        }
        Binding on selectedChainId {
            value: networksCombobox.currentValue ?? 0
        }
        Binding on selectedTokenKey {
            value: tokensCombobox.currentValue ?? ""
        }
    }

    WalletAccountsSelectorAdaptor {
        id: accountsSelectorAdaptor

        accounts: d.walletAccountsModel
        assetsModel: GroupedAccountsAssetsModel {}
        tokensBySymbolModel: d.walletAssetStore.walletTokensStore.plainTokensBySymbolModel
        filteredFlatNetworksModel: d.filteredNetworksModel

        selectedTokenKey: simpleSend.selectedTokenKey
        selectedNetworkChainId: simpleSend.selectedChainId

        fnFormatCurrencyAmountFromBigInt: function(balance, symbol, decimals, options = null) {
            let bigIntBalance = AmountsArithmetic.fromString(balance)
            let decimalBalance = AmountsArithmetic.toNumber(bigIntBalance, decimals)
            return d.formatCurrencyAmount(decimalBalance, symbol, options)
        }
    }

    TokenSelectorViewAdaptor {
        id: assetsSelectorViewAdaptor

        assetsModel: d.walletAssetStore.groupedAccountAssetsModel
        flatNetworksModel: NetworksModel.flatNetworks

        currentCurrency: "USD"
        showCommunityAssets: true

        accountAddress: simpleSend.selectedAccountAddress
        enabledChainIds: [simpleSend.selectedChainId]
    }

    CollectiblesSelectionAdaptor {
        id: collectiblesSelectionAdaptor

        accountKey: simpleSend.selectedAccountAddress
        enabledChainIds: [simpleSend.selectedChainId]

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
                name: "Multi-seq NFT 1",
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
                communityImage: Qt.resolvedUrl(""),
                tokenType: Constants.TokenType.ERC721
            },
            {
                tokenId: "id_4",
                symbol: "def",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-seq NFT 2",
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
                communityImage: Qt.resolvedUrl(""),
                tokenType: Constants.TokenType.ERC721
            },
            {
                tokenId: "id_5",
                symbol: "ghi",
                chainId: NetworksModel.mainnetChainId,
                name: "Multi-seq NFT 3",
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
                communityImage: Qt.resolvedUrl(""),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Qt.resolvedUrl(""),
                tokenType: Constants.TokenType.ERC1155
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
                communityImage: Qt.resolvedUrl(""),
                tokenType: Constants.TokenType.ERC1155
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
                communityImage: Constants.tokenIcon("KIN", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("KIN", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("KIN", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("KIN", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("ICOS", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("ICOS", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("ICOS", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("ICOS", false),
                tokenType: Constants.TokenType.ERC721
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
                communityImage: Constants.tokenIcon("ICOS", false),
                tokenType: Constants.TokenType.ERC721
            }
        ]

        Component.onCompleted: {
            append(data)
        }
    }

    Pane {
        SplitView.minimumHeight: 100
        SplitView.minimumWidth: 300
        SplitView.maximumWidth: 380

        ColumnLayout {
            spacing: 20

            CheckBox {
                id: interactiveCheckbox
                text: "Is interactive"
                checked: true
            }

            Text {
                text: "Select an accounts"
            }
            ComboBox {
                id: accountsCombobox
                model: SortFilterProxyModel {
                    sourceModel: d.walletAccountsModel
                    filters: ValueFilter {
                        roleName: "walletType"
                        value: Constants.watchWalletType
                        inverted: true
                    }
                }
                textRole: "name"
                valueRole: "address"
                currentIndex: 0
            }

            CheckBox {
                id: testNetworksCheckbox
                text: "are test networks enabled"
            }
            Text {
                text: "Select a network"
            }
            ComboBox {
                id: networksCombobox
                model: d.filteredNetworksModel
                textRole: "chainName"
                valueRole: "chainId"
                currentIndex: 0
            }

            Text {
                text: "Select a token"
            }
            ComboBox {
                id: tokensCombobox
                model: ConcatModel {
                    sources: [
                        SourceModel {
                            model: assetsSelectorViewAdaptor.outputAssetsModel
                            markerRoleValue: "first_model"
                        },
                        SourceModel {
                            model: collectiblesKeyModel
                            markerRoleValue: "second_model"
                        }
                    ]

                    markerRoleName: "which_model"
                    expectedRoles: ["tokensKey", "name"]
                }
                textRole: "name"
                valueRole: "tokensKey"
            }

            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: amountInput
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50
                    validator: RegularExpressionValidator {
                        regularExpression: /^\d*\.?\d*$/
                    }
                }
                Button {
                    text: "update in modal"
                    onClicked: simpleSend.selectedAmount = amountInput.text
                }
            }
            Text {
                text: "amount selected in base unit: " + simpleSend.selectedAmountInBaseUnit
            }

            Text {
                text: "Select a recipient"
            }
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: recipientInput
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50
                }
                Button {
                    text: "update in modal"
                    onClicked: simpleSend.selectedRecipientAddress = recipientInput.text
                }
            }

            Text {
                text: "account selected is: \n"
                      + simpleSend.selectedAccountAddress
            }
            Text {
                text: "network selected is: " + simpleSend.selectedChainId
            }
            Text {
                text: "token selected is: " + simpleSend.selectedTokenKey
            }
            Text {
                text: "amount entered is: " + simpleSend.selectedAmount
            }
            Text {
                text: "selected recipient is: \n" + simpleSend.selectedRecipientAddress
            }

            RolesRenamingModel {
                id: collectiblesKeyModel
                sourceModel: collectiblesSelectionAdaptor.model

                mapping: [
                    RoleRename {
                        from: "symbol"
                        to: "tokensKey"
                    }
                ]
            }
        }
    }
}

// category: Popups
