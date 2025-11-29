import QtQuick

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

    readonly property QtObject currentActivityFiltersStore: QtObject {
        readonly property bool filtersSet: false

        function applyAllFilters() {}
        function updateCollectiblesModel() {}
        function updateRecipientsModel() {}
    }

    function updateTransactionFilterIfDirty() {}
    function fetchMoreTransactions() {}
    function resetActivityData() {}
    function getEtherscanLink(chainID) { return "" }
    function getTransactionType(transaction) { return 0 }
    function getNameForAddress(address) { return "" }
    function getDappDetails(chainId, contractAddress) { return undefined }
    function isOwnedAccount(address) { return true }
}
