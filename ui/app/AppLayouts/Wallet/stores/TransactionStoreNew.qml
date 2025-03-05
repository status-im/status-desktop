import QtQuick 2.15

QtObject {
    id: root

    property var _walletSectionSendInst: walletSectionSendNew

    signal suggestedRoutesReady(string uuid, var pathModel, string errCode, string errDescription)
    signal transactionSent(string uuid, int chainId, bool approvalTx, string txHash, string error)
    signal successfullyAuthenticated(string uuid)

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

    function setFeeMode(feeMode, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId) {
        _walletSectionSendInst.setFeeMode(feeMode, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId)
    }

    function setCustomTxDetails(nonce, gasAmount, maxFeesPerGas, priorityFee, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId) {
        _walletSectionSendInst.setCustomTxDetails(nonce, gasAmount, maxFeesPerGas, priorityFee, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId)
    }

    function getEstimatedTime(chainId, baseFeeInWei, priorityFeeInWei) {
        return _walletSectionSendInst.getEstimatedTime(chainId, baseFeeInWei, priorityFeeInWei)
    }

    Component.onCompleted: {
        _walletSectionSendInst.suggestedRoutesReady.connect(suggestedRoutesReady)
        _walletSectionSendInst.transactionSent.connect(transactionSent)
        _walletSectionSendInst.successfullyAuthenticated.connect(successfullyAuthenticated)
    }
}

