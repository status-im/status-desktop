import QtQml 2.15
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

QObject {
    id: root

    required property CurrenciesStore currencyStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property WalletStore.SwapStore swapStore
    required property SwapInputParamsForm swapFormData

    readonly property var nonWatchAccounts: SortFilterProxyModel {
        sourceModel: root.swapStore.accounts
        filters: ValueFilter {
            roleName: "walletType"
            value: Constants.watchWalletType
            inverted: true
        }
        sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        proxyRoles: [
            FastExpressionRole {
                name: "accountBalance"
                expression: __processAccountBalance(model.address)
                expectedRoles: ["address"]
            },
            FastExpressionRole {
                name: "fromToken"
                expression: root.__fromToken
            }
        ]
    }

    readonly property SortFilterProxyModel filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.swapStore.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: root.swapStore.areTestNetworksEnabled }
    }

    function getNetworkShortNames(chainIds) {
        var networkString = ""
        let chainIdsArray = chainIds.split(":")
        for (let i = 0; i< chainIdsArray.length; i++) {
            let nwShortName = ModelUtils.getByKey(root.filteredFlatNetworksModel, "chainId", Number(chainIdsArray[i]), "shortName")
            if(!!nwShortName) {
                networkString = networkString + nwShortName + ':'
            }
        }
        return networkString
    }

    function formatCurrencyAmount(balance, symbol) {
        return root.currencyStore.formatCurrencyAmount(balance, symbol)
    }

    // TODO: remove once the AccountsModalHeader is reworked!!
    function getSelectedAccount(index) {
        if (root.nonWatchAccounts.count > 0 && index >= 0) {
            return ModelUtils.get(nonWatchAccounts, index)
        }
        return null
    }

    // Internal properties and functions -----------------------------------------------------------------------------------------------------------------------------
    readonly property var __fromToken: ModelUtils.getByKey(root.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel, "key", root.swapFormData.fromTokensKey)

    SubmodelProxyModel {
        id: filteredBalancesModel
        sourceModel: root.walletAssetsStore.baseGroupedAccountAssetModel
        submodelRoleName: "balances"
        delegateModel: SortFilterProxyModel {
            sourceModel: joinModel
            filters: ValueFilter {
                roleName: "chainId"
                value: root.swapFormData.selectedNetworkChainId
            }
            readonly property LeftJoinModel joinModel: LeftJoinModel {
                leftModel: submodel
                rightModel: root.filteredFlatNetworksModel

                joinRole: "chainId"
            }
        }
    }

    function __processAccountBalance(address) {
        let network = ModelUtils.getByKey(root.filteredFlatNetworksModel, "chainId", root.swapFormData.selectedNetworkChainId)
        if(!!network) {
            let balancesModel = ModelUtils.getByKey(filteredBalancesModel, "tokensKey", root.swapFormData.fromTokensKey, "balances")
            let accountBalance = ModelUtils.getByKey(balancesModel, "account", address)
            if(!accountBalance) {
                return {
                    balance: "0",
                    iconUrl: network.iconUrl,
                    chainColor: network.chainColor}
            }
            return accountBalance
        }
        return null
    }
}
