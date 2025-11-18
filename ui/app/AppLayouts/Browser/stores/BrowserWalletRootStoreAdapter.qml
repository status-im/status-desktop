import QtQuick
import SortFilterProxyModel

import utils
import shared.stores as SharedStores

QtObject {
    id: root

    required property var browserWalletStore

    readonly property string selectedAddress: browserWalletStore.selectedAddress
    readonly property bool isNonArchivalNode: browserWalletStore.isNonArchivalNode
    readonly property bool showAllAccounts: false
    readonly property var activityController: browserWalletStore.activityController
    readonly property bool loadingHistoryTransactions: browserWalletStore.loadingHistoryTransactions
    readonly property var transactionActivityStatus: browserWalletStore.transactionActivityStatus
    readonly property bool newDataAvailable: browserWalletStore.newDataAvailable
    readonly property var currentActivityFiltersStore: browserWalletStore.currentActivityFiltersStore

    readonly property var historyTransactions: SortFilterProxyModel {
        sourceModel: root.browserWalletStore.historyTransactions
        filters: ExpressionFilter {
            expression: {
                const currentAddr = root.browserWalletStore.dappBrowserAccount.address.toLowerCase()
                if (!model.activityEntry) return false
                const sender = model.activityEntry.sender ? model.activityEntry.sender.toLowerCase() : ""
                const recipient = model.activityEntry.recipient ? model.activityEntry.recipient.toLowerCase() : ""
                return sender === currentAddr || recipient === currentAddr
            }
        }
    }

    function updateTransactionFilterIfDirty() {
        browserWalletStore.updateTransactionFilterIfDirty()
    }

    function fetchMoreTransactions() {
        browserWalletStore.fetchMoreTransactions()
    }

    function resetActivityData() {
        browserWalletStore.resetActivityData()
    }

    function getEtherscanLink(chainID) {
        return browserWalletStore.getEtherscanLink(chainID)
    }

    function getTransactionType(transaction) {
        if (!transaction) return Constants.TransactionType.Send
        return transaction.txType
    }

    function getNameForAddress(address) {
        const name = walletSectionAccounts.getNameByAddress(address)
        return name.length > 0 ? name : ""
    }

    function getDappDetails(chainId, contractAddress) {
        return undefined
    }

    function isOwnedAccount(address) {
        return walletSectionAccounts.isOwnedAccount(address)
    }
}
