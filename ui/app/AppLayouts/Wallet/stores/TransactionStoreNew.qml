import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Models 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0

import utils 1.0

import SortFilterProxyModel 0.2

QtObject {
    id: root

    property var walletSectionSendInst: walletSectionSendNew
    readonly property var pathModel: walletSectionSendInst.pathModel

    function authenticateAndTransfer(uuid, fromAddr, slippagePercentage = "") {
        root.walletSectionSendInst.authenticateAndTransfer(uuid, fromAddr, slippagePercentage)
    }

    function fetchSuggestedRoutes(uuid, sendType, chainId, accountFrom,
                                  accountTo, amountIn, token,
                                  amountOut = "0", toToken = "",
                                  extraParamsJson = "") {
        root.walletSectionSendInst.fetchSuggestedRoutes(uuid, sendType, chainId, accountFrom, accountTo, amountIn, token,
                                                        amountOut, toToken, extraParamsJson)
    }

    function stopUpdatesForSuggestedRoute() {
        root.walletSectionSendInst.stopUpdatesForSuggestedRoute()
    }

    signal suggestedRoutesReady(string uuid, var pathModel, string errCode, string errDescription)

    Component.onCompleted: {
        walletSectionSendInst.suggestedRoutesReady.connect(suggestedRoutesReady)
    }
}

