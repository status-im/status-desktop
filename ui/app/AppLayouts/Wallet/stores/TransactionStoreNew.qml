import QtQuick 2.15

QtObject {
    id: root

    property var _walletSectionSendInst: walletSectionSendNew

    signal suggestedRoutesReady(string uuid, var pathModel, string errCode, string errDescription)
    signal transactionSent(string uuid, int chainId, bool approvalTx, string txHash, string error)

    function authenticateAndTransfer(uuid, fromAddr, slippagePercentage = "") {
        _walletSectionSendInst.authenticateAndTransfer(uuid, fromAddr, slippagePercentage)
    }

    function fetchSuggestedRoutes(uuid, sendType, chainId, accountFrom,
                                  accountTo, amountIn, token,
                                  amountOut = "0", toToken = "",
                                  extraParamsJson = "") {
        _walletSectionSendInst.fetchSuggestedRoutes(uuid, sendType, chainId, accountFrom,
                                                    accountTo, amountIn, token,
                                                    amountOut, toToken, extraParamsJson)
    }

    function stopUpdatesForSuggestedRoute() {
        _walletSectionSendInst.stopUpdatesForSuggestedRoute()
    }

    Component.onCompleted: {
        _walletSectionSendInst.suggestedRoutesReady.connect(suggestedRoutesReady)
        _walletSectionSendInst.transactionSent.connect(transactionSent)
    }
}

