import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

QtObject {
    id: root

    /* TODO: all of these should come from their respective stores once the stores are reworked and
       streamlined. This store should contain only swap specific properties/methods if any */
    readonly property var accounts: walletSectionAccounts.accounts

    /* TODO: Send module should be reworked into a lighter, generic, "stateless" module.
       Remove these and use the new TransactorStore in SwapModalAdaptor when that happens. */
    readonly property var walletSectionSendInst: walletSectionSend

    signal suggestedRoutesReady(var txRoutes, string errCode, string errDescription)
    signal transactionSent(var uuid, var chainId, var approvalTx, var txHash, var error)
    signal transactionSendingComplete(var txHash,  var success)

    readonly property Connections walletSectionSendConnections: Connections {
        target: root.walletSectionSendInst
        function onSuggestedRoutesReady(txRoutes, errCode, errDescription) {
            root.suggestedRoutesReady(txRoutes, errCode, errDescription)
        }
        function onTransactionSent(uuid, chainId, approvalTx, txHash, error) {
            root.transactionSent(uuid, chainId, approvalTx, txHash, error)
        }
        function onTransactionSendingComplete(txHash, success) {
            root.transactionSendingComplete(txHash, success)
        }
    }

    function fetchSuggestedRoutes(uuid, accountFrom, accountTo, amountIn, amountOut, tokenFrom, tokenTo,
        fromChainID, toChainID, sendType, slippagePercentage) {
        const valueIn = AmountsArithmetic.fromNumber(amountIn)
        const valueOut = AmountsArithmetic.fromNumber(amountOut)
        root.walletSectionSendInst.fetchSuggestedRoutesWithParameters(uuid, accountFrom, accountTo, valueIn.toFixed(), valueOut.toFixed(),
            tokenFrom, tokenTo, fromChainID, toChainID, sendType, slippagePercentage)
    }

    function resetData() {
        root.walletSectionSendInst.resetData()
    }

    function authenticateAndTransfer(uuid) {
        root.walletSectionSendInst.authenticateAndTransfer(uuid)
    }

    function getWei2Eth(wei, decimals) {
        return globalUtils.wei2Eth(wei, decimals)
    }

    function reevaluateSwap(routerInputParamsUuid, chainId, isApprovalTx) {
        root.walletSectionSendInst.reevaluateSwap(routerInputParamsUuid, chainId, isApprovalTx)
    }
}
