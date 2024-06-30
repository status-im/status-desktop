import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

QtObject {
    id: root

    /* TODO: all of these should come from their respective stores once the stores are reworked and
       streamlined. This store should contain only swap specific properties/methods if any */
    readonly property var accounts: walletSectionAccounts.accounts
    readonly property var flatNetworks: networksModule.flatNetworks
    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled

    /* TODO: Send module should be reworked into a lighter, generic, "stateless" module.
       Remove these and use the new TransactorStore in SwapModalAdaptor when that happens. */
    readonly property var walletSectionSendInst: walletSectionSend

    signal suggestedRoutesReady(var txRoutes)

    readonly property Connections walletSectionSendConnections: Connections {
        target: root.walletSectionSendInst
        function onSuggestedRoutesReady(txRoutes) {
            root.suggestedRoutesReady(txRoutes)
        }
    }

    function fetchSuggestedRoutes(accountFrom, accountTo, amountIn, amountOut, tokenFrom, tokenTo,
        disabledFromChainIDs, disabledToChainIDs, sendType, lockedInAmounts) {
        const valueIn = AmountsArithmetic.fromNumber(amountIn)
        const valueOut = AmountsArithmetic.fromNumber(amountOut)
        root.walletSectionSendInst.fetchSuggestedRoutesWithParameters(accountFrom, accountTo, valueIn.toFixed(), valueOut.toFixed(),
            tokenFrom, tokenTo, disabledFromChainIDs, disabledToChainIDs, sendType, lockedInAmounts)
    }

    function authenticateAndTransfer(uuid, accountFrom, accountTo,
            tokenFrom, tokenTo, sendType, tokenName, tokenIsOwnerToken, paths, slippagePercentage) {
        root.walletSectionSendInst.authenticateAndTransferWithParameters(uuid, accountFrom, accountTo,
            tokenFrom, tokenTo, sendType, tokenName, tokenIsOwnerToken, paths, slippagePercentage)
    }

    function getWei2Eth(wei, decimals) {
        return globalUtils.wei2Eth(wei, decimals)
    }
}
