import QtQuick 2.15

QtObject {
    id: root

    property var _walletSectionSendInst: walletSectionSendNew

    signal suggestedRoutesReady(string uuid, var pathModel, string errCode, string errDescription)
    signal transactionSent(string uuid, int chainId, bool approvalTx, string txHash, string error)
    signal successfullyAuthenticated(string uuid)

    function authenticateAndTransfer(uuid, fromAddr) {
        _walletSectionSendInst.authenticateAndTransfer(uuid, fromAddr)
    }

    function fetchSuggestedRoutes(uuid, sendType, chainId, accountFrom,
                                  accountTo, amountIn, token,
                                  amountOut = "0", toToken = "",
                                  slippagePercentage = "",
                                  extraParamsJson = "") {
        _walletSectionSendInst.fetchSuggestedRoutes(uuid, sendType, chainId, accountFrom,
                                                    accountTo, amountIn, token,
                                                    amountOut, toToken, slippagePercentage, extraParamsJson)
    }

    function resetData() {
        _walletSectionSendInst.resetData()
    }

    function setFeeMode(feeMode, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId) {
        _walletSectionSendInst.setFeeMode(feeMode, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId)
    }

    function setCustomTxDetails(nonce, gasAmount, gasPrice, maxFeesPerGas, priorityFee, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId) {
        _walletSectionSendInst.setCustomTxDetails(nonce, gasAmount, gasPrice, maxFeesPerGas, priorityFee, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId)
    }

    function getEstimatedTime(chainId, gasPrice, baseFeeInWei, priorityFeeInWei) {
        return _walletSectionSendInst.getEstimatedTime(chainId, gasPrice, baseFeeInWei, priorityFeeInWei)
    }

    Component.onCompleted: {
        _walletSectionSendInst.suggestedRoutesReady.connect(suggestedRoutesReady)
        _walletSectionSendInst.transactionSent.connect(transactionSent)
        _walletSectionSendInst.successfullyAuthenticated.connect(successfullyAuthenticated)
    }
}

