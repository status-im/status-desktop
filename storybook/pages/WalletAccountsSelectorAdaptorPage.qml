import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2

import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.adaptors 1.0

import Storybook 1.0
import Models 1.0

import shared.stores 1.0
import utils 1.0

Item {
    id: root

    ListModel {
        id: walletAccountsModel
        readonly property var data: [
            {
                name: "helloworld",
                address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                emoji: "😋",
                colorId: Constants.walletAccountColors.primary,
                walletType: "",
                canSend: true,
                position: 0,
                currencyBalance: ({amount: 1.25,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: true
            },
            {
                name: "Hot wallet (generated)",
                emoji: "🚗",
                colorId: Constants.walletAccountColors.army,
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                walletType: Constants.generatedWalletType,
                canSend: true,
                position: 3,
                currencyBalance: ({amount: 10,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            },
            {
                name: "Family (seed)",
                emoji: "🎨",
                colorId: Constants.walletAccountColors.magenta,
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
                walletType: Constants.seedWalletType,
                canSend: true,
                position: 1,
                currencyBalance: ({amount: 110.05,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            },
            {
                name: "Tag Heuer (watch)",
                emoji: "⌚",
                colorId: Constants.walletAccountColors.copper,
                color: "#CB6256",
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
                walletType: Constants.watchWalletType,
                canSend: false,
                position: 2,
                currencyBalance: ({amount: 3,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            },
            {
                name: "Fab (key)",
                emoji: "🔑",
                colorId: Constants.walletAccountColors.camel,
                color: "#C78F67",
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8884",
                walletType: Constants.keyWalletType,
                canSend: true,
                position: 4,
                currencyBalance: ({amount: 999,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            }
        ]

        Component.onCompleted: append(data)
    }

    QtObject {
        id: d

        readonly property var assetsStore: WalletAssetsStore {
            id: thisWalletAssetStore
            walletTokensStore: TokensStore {
                plainTokensBySymbolModel: TokensBySymbolModel {}
            }
            readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
            assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
        }
        readonly property var currencyStore: CurrenciesStore{}
    }

    WalletAccountsSelectorAdaptor {
        id: adaptor
        accounts: walletAccountsModel
        assetsModel: d.assetsStore.groupedAccountAssetsModel
        tokensBySymbolModel: d.assetsStore.walletTokensStore.plainTokensBySymbolModel
        filteredFlatNetworksModel: SortFilterProxyModel {
            sourceModel: NetworksModel.flatNetworks
            filters: ValueFilter { roleName: "isTest"; value: true }
        }

        fnFormatCurrencyAmountFromBigInt: function(balance, symbol, decimals, options = null) {
            return d.currencyStore.formatCurrencyAmountFromBigInt(balance, symbol, decimals, options)
        }

        selectedTokenKey: selectedTokenComboBox.currentValue
        selectedNetworkChainId: networksComboBox.currentValue
    }

    ColumnLayout {
        anchors.fill: parent

        Label { text: "Selected Token" }
        ComboBox {
            id: selectedTokenComboBox
            textRole: "name"
            valueRole: "key"
            model: d.assetsStore.walletTokensStore.plainTokensBySymbolModel
            currentIndex: 0
            onCountChanged: currentIndex = 0
        }

        Label { text: "Selected Network" }
        ComboBox {
            id: networksComboBox
            textRole: "chainName"
            valueRole: "chainId"
            model: adaptor.filteredFlatNetworksModel
            currentIndex: 0
            onCountChanged: currentIndex = 0
        }

        RowLayout {
            GenericListView {
                label: "Input Accounts model"

                model: walletAccountsModel

                Layout.fillWidth: true
                Layout.fillHeight: true

                roles: ["name", "address", "currencyBalance", "position", "canSend"]

                skipEmptyRoles: true
            }

            GenericListView {
                label: "Adapter's output model"

                model: adaptor.processedWalletAccounts

                Layout.fillWidth: true
                Layout.fillHeight: true

                roles: ["name", "address", "currencyBalance", "position", "canSend", "accountBalance", "currencyBalanceDouble"]

                skipEmptyRoles: true

                insetComponent: Label {
                    text: "balance " + (model ? model.accountBalance.formattedBalance: "")
                }
            }
        }
    }
}

// category: Adaptors
