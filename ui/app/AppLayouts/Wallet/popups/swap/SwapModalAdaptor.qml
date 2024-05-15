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
                expression: root.__selectedFromToken
            }
        ]
    }

    function getNetworkShortNames(chainIds) {
        var networkString = ""
        let chainIdsArray = chainIds.split(":")
        for (let i = 0; i< chainIdsArray.length; i++) {
            let nwShortName = ModelUtils.getByKey(root.__filteredFlatNetworksModel, "chainId", Number(chainIdsArray[i]), "shortName")
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
    readonly property SortFilterProxyModel __filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.swapStore.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: root.swapStore.areTestNetworksEnabled }
    }

    /* TODO: the below logic is only needed until https://github.com/status-im/status-desktop/issues/14550
       is implemented then we should use that helper to connect the balances model with a wallet account */
    readonly property var __selectedFromToken: ModelUtils.getByKey(root.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel, "key", root.swapFormData.fromTokensKey)
    readonly property var __balancesModelForSelectedFromToken: ModelUtils.getByKey(root.walletAssetsStore.baseGroupedAccountAssetModel, "tokensKey", root.swapFormData.fromTokensKey, "balances")
    readonly property LeftJoinModel __networkJointBalancesModelForSelectedFromToken: LeftJoinModel {
        leftModel: root.__balancesModelForSelectedFromToken
        rightModel: root.__filteredFlatNetworksModel
        joinRole: "chainId"
    }
    readonly property SortFilterProxyModel __filteredBalancesModelForSelectedFromToken: SortFilterProxyModel {
        sourceModel: __networkJointBalancesModelForSelectedFromToken
        filters: ValueFilter { roleName: "chainId"; value: root.swapFormData.selectedNetworkChainId}
    }
    function __processAccountBalance(address) {
        let network = ModelUtils.getByKey(root.__filteredFlatNetworksModel, "chainId", root.swapFormData.selectedNetworkChainId)
        if(!!network) {
            let accountBalances = ModelUtils.getByKey(root.__filteredBalancesModelForSelectedFromToken, "account", address)
            if(accountBalances === null) {
                return {
                    balance: "0",
                    iconUrl: network.iconUrl,
                    chainColor: network.chainColor}
            }
            return accountBalances
        }
        return null
    }
}
