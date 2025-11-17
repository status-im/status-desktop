import QtQuick

import utils

QtObject {
    id: root

    required property var browserWalletStore

    readonly property var activityController: browserSection.activityController

    readonly property string selectedAddress: browserWalletStore.dappBrowserAccount.address
    readonly property bool isNonArchivalNode: false
    readonly property bool showAllAccounts: false
    readonly property var transactionActivityStatus: activityController.status
    readonly property bool loadingHistoryTransactions: activityController.status.loadingData
    readonly property bool newDataAvailable: activityController.status.newDataAvailable

    readonly property var historyTransactions: activityController.model

    // Browser view doesn't provide transaction filtering UI
    readonly property QtObject currentActivityFiltersStore: QtObject {
        readonly property bool filtersSet: false

        function applyAllFilters() {
            root.activityController.updateFilter()
        }

        function updateCollectiblesModel() {
            root.activityController.updateCollectiblesModel()
        }

        function updateRecipientsModel() {
            root.activityController.updateRecipientsModel()
        }
    }

    function updateTransactionFilterIfDirty() {
        if (transactionActivityStatus.isFilterDirty) {
            activityController.updateFilter()
        }
    }

    function fetchMoreTransactions() {
        if (historyTransactions.count === 0
                || !historyTransactions.hasMore
                || loadingHistoryTransactions)
            return
        activityController.loadMoreItems()
    }

    function resetActivityData() {
        activityController.resetActivityData()
    }

    function getEtherscanLink(chainID) {
        return networksModule.getBlockExplorerTxURL(chainID)
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
        return Utils.getDappDetails(chainId, contractAddress)
    }

    function isOwnedAccount(address) {
        return walletSectionAccounts.isOwnedAccount(address)
    }
}
