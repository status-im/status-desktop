import QtQuick

QtObject {
    id: root

    property var dappBrowserAccount: browserSectionCurrentAccount
    property var accounts: walletSectionAccounts.accounts
    property string defaultCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase // FIXME

    // Properties required by HistoryView
    readonly property string selectedAddress: dappBrowserAccount.address
    readonly property bool isNonArchivalNode: false // Browser doesn't show this warning
    readonly property bool showAllAccounts: false

    // Activity controller properties
    readonly property var activityController: browserSection.activityController
    readonly property var historyTransactions: activityController.model
    readonly property var transactionActivityStatus: activityController.status
    readonly property bool loadingHistoryTransactions: activityController.status.loadingData
    readonly property bool newDataAvailable: activityController.status.newDataAvailable

    // Minimal activity filter store wrapper
    readonly property QtObject currentActivityFiltersStore: QtObject {
        readonly property bool filtersSet: false // No filters in browser view

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

    function getEtherscanLink(chainID) {
        return networksModule.getBlockExplorerTxURL(chainID)
    }

    function switchAccountByAddress(address) {
        browserSectionCurrentAccount.switchAccountByAddress(address)
    }

    function fetchMoreTransactions() {
        // Browser view doesn't support pagination yet, no-op
    }

    function resetActivityData() {
        activityController.resetActivityData()
    }
}
