import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import shared.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

QObject {
    id: root

    required property CurrenciesStore currencyStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property WalletStore.SwapStore swapStore
    required property SwapSignApproveInputForm inputFormData

    // To expose the selected from and to Token from the SwapModal
    readonly property var fromToken: fromTokenEntry.item
    readonly property var toToken: toTokenEntry.item
    readonly property var selectedAccount: selectedAccountEntry.item
    readonly property var selectedNetwork: selectedNetworkEntry.item
    readonly property var fromTokenContractAddress: fromTokenContractAddress.item
    readonly property var toTokenContractAddress: toTokenContractAddress.item

    ModelEntry {
        id: fromTokenEntry
        sourceModel: root.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel
        key: "key"
        value: root.inputFormData.fromTokensKey
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: root.swapStore.accounts
        key: "address"
        value: root.inputFormData.selectedAccountAddress
    }

    ModelEntry {
        id: selectedNetworkEntry
        sourceModel: root.swapStore.flatNetworks
        key: "chainId"
        value: root.inputFormData.selectedNetworkChainId
    }

    ModelEntry {
        id: toTokenEntry
        sourceModel: root.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel
        key: "key"
        value: root.inputFormData.toTokensKey
    }

    ModelEntry {
        id: fromTokenContractAddress
        sourceModel: !!root.fromToken ?
                         root.fromToken.addressPerChain ?? null : null
        key: "chainId"
        value: root.inputFormData.selectedNetworkChainId
    }

    ModelEntry {
        id: toTokenContractAddress
        sourceModel: !!root.toToken ?
                         root.toToken.addressPerChain ?? null : null
        key: "chainId"
        value: root.inputFormData.selectedNetworkChainId
    }
}
