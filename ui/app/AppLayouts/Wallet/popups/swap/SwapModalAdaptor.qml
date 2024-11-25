import QtQml 2.15
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.stores 1.0
import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

QObject {
    id: root

    required property CurrenciesStore currencyStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property WalletStore.SwapStore swapStore
    required property SwapInputParamsForm swapFormData
    required property SwapOutputData swapOutputData

    // the below 2 properties holds the state of finding a swap proposal
    property bool validSwapProposalReceived: false
    property bool swapProposalLoading: false

    // the below 2 properties holds the state of finding a swap proposal
    property bool approvalPending: false
    property bool approvalSuccessful: false

    // the below property holds internal checks done by the SwapModal
    property bool amountEnteredGreaterThanBalance: false

    // To expose the selected from and to Token from the SwapModal
    readonly property var fromToken: fromTokenEntry.item
    readonly property var toToken: toTokenEntry.item
    readonly property var selectedAccount: selectedAccountEntry.item

    readonly property string uuid: d.uuid

    // TO REVIEW: Handle this in a separate `WalletAccountsAdaptor.qml` file.
    // Probably this data transformation should live there since they have common base.
    readonly property var nonWatchAccounts: SortFilterProxyModel {
        sourceModel: root.swapStore.accounts
        delayed: true // Delayed to allow `processAccountBalance` dependencies to be resolved
        filters: ValueFilter {
            roleName: "canSend"
            value: true
        }
        sorters: [
            RoleSorter { roleName: "currencyBalanceDouble"; sortOrder: Qt.DescendingOrder },
            RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        ]
        proxyRoles: [
            FastExpressionRole {
                name: "accountBalance"
                expression: {
                    // dependencies
                    root.swapFormData.fromTokensKey
                    root.fromToken
                    root.fromToken.symbol
                    root.fromToken.decimals
                    root.swapFormData.selectedNetworkChainId
                    root.swapFormData.fromTokensKey

                    return d.processAccountBalance(model.address)
                }
                expectedRoles: ["address"]
            },
            FastExpressionRole {
                name: "currencyBalanceDouble"
                expression: model.currencyBalance.amount
                expectedRoles: ["currencyBalance"]
            },
            FastExpressionRole {
                name: "fromToken"
                expression: root.fromToken
            }
        ]
    }

    readonly property SortFilterProxyModel filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.swapStore.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: root.swapStore.areTestNetworksEnabled }
    }

    readonly property string errorMessage: d.errorMessage
    readonly property bool isEthBalanceInsufficient: d.isEthBalanceInsufficient
    readonly property bool isTokenBalanceInsufficient: d.isTokenBalanceInsufficient

    QtObject {
        id: d

        property string uuid
        // storing txHash to verify against tx completed event
        property string txHash

        readonly property ObjectProxyModel filteredBalancesModel: ObjectProxyModel {
            sourceModel: root.walletAssetsStore.baseGroupedAccountAssetModel

            delegate: SortFilterProxyModel {
                readonly property var balances: this

                sourceModel: LeftJoinModel {
                    leftModel: model.balances
                    rightModel: root.swapStore.flatNetworks

                    joinRole: "chainId"
                }

                filters: ValueFilter {
                    roleName: "chainId"
                    value: root.swapFormData.selectedNetworkChainId
                }
            }

            expectedRoles: "balances"
            exposedRoles: "balances"
        }

        function processAccountBalance(address) {
            if (!root.swapFormData.fromTokensKey || !root.fromToken) {
                return null
            }

            let network = ModelUtils.getByKey(root.filteredFlatNetworksModel, "chainId", root.swapFormData.selectedNetworkChainId)

            if (!network) {
                return null
            }

            let balancesModel = ModelUtils.getByKey(filteredBalancesModel, "tokensKey", root.swapFormData.fromTokensKey, "balances")
            let accountBalance = ModelUtils.getByKey(balancesModel, "account", address)
            if(accountBalance && accountBalance.balance !== "0") {
                accountBalance.formattedBalance = root.formatCurrencyAmountFromBigInt(accountBalance.balance, root.fromToken.symbol, root.fromToken.decimals)
                return accountBalance
            }

            return {
                balance: "0",
                iconUrl: network.iconUrl,
                chainColor: network.chainColor,
                formattedBalance: "0 %1".arg(root.fromToken.symbol)
            }
        }

        // Properties to handle error states
        readonly property bool isRouteEthBalanceInsufficient: root.validSwapProposalReceived && root.swapOutputData.errCode === Constants.routerErrorCodes.router.errNotEnoughNativeBalance

        readonly property bool isRouteTokenBalanceInsufficient: root.validSwapProposalReceived && root.swapOutputData.errCode === Constants.routerErrorCodes.router.errNotEnoughTokenBalance

        readonly property bool isTokenBalanceInsufficient: {
            if (!!root.fromToken && !!root.fromToken.symbol) {
                return (root.amountEnteredGreaterThanBalance || isRouteTokenBalanceInsufficient) &&
                        root.fromToken.symbol !== Constants.ethToken
            }
            return false
        }

        readonly property bool isEthBalanceInsufficient: {
            if (!!root.fromToken && !!root.fromToken.symbol) {
                return (root.amountEnteredGreaterThanBalance && root.fromToken.symbol === Constants.ethToken) ||
                        isRouteEthBalanceInsufficient
            }
            return false
        }

        readonly property bool isBalanceInsufficientForSwap: {
            if (!!root.fromToken && !!root.fromToken.symbol) {
                return (root.amountEnteredGreaterThanBalance && root.fromToken.symbol === Constants.ethToken) ||
                        (isTokenBalanceInsufficient && root.fromToken.symbol !== Constants.ethToken)
            }
            return false
        }

        readonly property bool isBalanceInsufficientForFees: !isBalanceInsufficientForSwap && isEthBalanceInsufficient

        property string errorMessage: {
            if (isBalanceInsufficientForSwap) {
                return qsTr("Insufficient funds for swap")
            } else if (isBalanceInsufficientForFees) {
                return qsTr("Not enough ETH to pay gas fees")
            } else if (root.swapOutputData.hasError) {
                // TOOD #15874: Unify with WalletUtils router error code handling
                switch (root.swapOutputData.errCode) {
                    case Constants.routerErrorCodes.processor.errPriceTimeout:
                        return qsTr("Fetching the price took longer than expected. Please, try again later.")
                    case Constants.routerErrorCodes.processor.errNotEnoughLiquidity:
                        return qsTr("Not enough liquidity. Lower token amount or try again later.")
                    case Constants.routerErrorCodes.processor.errPriceImpactTooHigh:
                        return qsTr("Price impact too high. Lower token amount or try again later.")
                }
                return qsTr("Something went wrong. Change amount, token or try again later.")
            }
            return ""
        }
    }

    ModelEntry {
        id: fromTokenEntry
        sourceModel: root.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel
        key: "key"
        value: root.swapFormData.fromTokensKey
    }

    ModelEntry {
        id: toTokenEntry
        sourceModel: root.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel
        key: "key"
        value: root.swapFormData.toTokenKey
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: root.nonWatchAccounts
        key: "address"
        value: root.swapFormData.selectedAccountAddress
    }

    Connections {
        target: root.swapStore
        function onSuggestedRoutesReady(txRoutes, errCode, errDescription) {
            if (txRoutes.uuid !== d.uuid) {
                // Suggested routes for a different fetch, ignore
                return
            }
            root.swapOutputData.reset()
            root.validSwapProposalReceived = false
            root.swapProposalLoading = false
            root.swapOutputData.rawPaths = txRoutes.rawPaths
            root.swapOutputData.errCode = errCode
            root.swapOutputData.errDescription = errDescription
            // if valid route was found
            if(txRoutes.suggestedRoutes.count > 0) {
                root.validSwapProposalReceived = true
                root.swapOutputData.toTokenAmount = AmountsArithmetic.div(AmountsArithmetic.fromString(txRoutes.amountToReceive), AmountsArithmetic.fromNumber(1, root.toToken.decimals)).toString()

                let gasTimeEstimate = txRoutes.gasTimeEstimate
                let totalTokenFeesInFiat = 0
                if (!!root.fromToken && !!root.fromToken.marketDetails && !!root.fromToken.marketDetails.currencyPrice)
                    totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.fromToken.marketDetails.currencyPrice.amount
                root.swapOutputData.totalFees = root.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat
                let bestPath = ModelUtils.get(txRoutes.suggestedRoutes, 0, "route")
                root.swapOutputData.approvalNeeded = !!bestPath ? bestPath.approvalRequired: false
                root.swapOutputData.approvalGasFees = !!bestPath ? bestPath.approvalGasFees.toString() : ""
                root.swapOutputData.approvalAmountRequired = !!bestPath ? bestPath.approvalAmountRequired: ""
                root.swapOutputData.approvalContractAddress = !!bestPath ? bestPath.approvalContractAddress: ""
                root.swapOutputData.estimatedTime = !!bestPath ? bestPath.estimatedTime: Constants.TransactionEstimatedTime.Unknown
                root.swapOutputData.txProviderName = !!bestPath ? bestPath.bridgeName: ""
            } else {
                root.swapOutputData.hasError = true
            }
            root.swapOutputData.hasError = root.swapOutputData.hasError || root.swapOutputData.errCode !== ""
        }

        function onTransactionSent(uuid, chainId, approvalTx, txHash, error) {
            if(root.swapOutputData.approvalNeeded && !root.approvalSuccessful) {
                if (uuid !== d.uuid || !!error) {
                    root.approvalPending = false
                    root.approvalSuccessful = false
                    return
                }
                root.approvalPending = true
                d.txHash = txHash
            }
        }

        function onTransactionSendingComplete(txHash, status) {
            if(d.txHash === txHash && root.swapOutputData.approvalNeeded && root.approvalPending) {
                root.approvalPending = false
                root.approvalSuccessful = status == "Success" // TODO: make a all tx statuses Constants (success, pending, failed)
                d.txHash = ""
            }
        }
    }

    function reset() {
        d.uuid = ""
        root.swapFormData.resetFormData()
        root.swapOutputData.reset()
        root.validSwapProposalReceived = false
        root.swapProposalLoading = false
        root.approvalPending = false
        root.approvalSuccessful = false
        d.txHash = ""
    }

    function formatCurrencyAmount(balance, symbol, options = null, locale = null) {
        return root.currencyStore.formatCurrencyAmount(balance, symbol, options, locale)
    }

    function formatCurrencyAmountFromBigInt(balance, symbol, decimals, options = null) {
        return root.currencyStore.formatCurrencyAmountFromBigInt(balance, symbol, decimals, options)
    }

    function getDisabledChainIds(enabledChainId) {
        let disabledChainIds = []
        let chainIds = ModelUtils.modelToFlatArray(root.filteredFlatNetworksModel, "chainId")
        for (let i = 0; i < chainIds.length; i++) {
            if (chainIds[i] !== enabledChainId) {
                disabledChainIds.push(chainIds[i])
            }
        }
        return disabledChainIds.join(":")
    }

    function invalidateSuggestedRoute() {
        d.uuid = ""
        root.validSwapProposalReceived = false
        root.approvalPending = false
        root.approvalSuccessful = false
        root.swapOutputData.resetPathInfoAndError()
    }

    function fetchSuggestedRoutes(cryptoValueInRaw) {
        root.swapFormData.toTokenAmount = ""
        if (root.swapFormData.isFormFilledCorrectly() && !!cryptoValueInRaw) {
            // Identify new swap with a different uuid
            d.uuid = Utils.uuid()

            root.swapProposalLoading = true

            let accountAddress = root.swapFormData.selectedAccountAddress
            let disabledChainIds = getDisabledChainIds(root.swapFormData.selectedNetworkChainId)

            root.swapStore.fetchSuggestedRoutes(d.uuid, accountAddress, accountAddress,
                                                cryptoValueInRaw, "0", root.swapFormData.fromTokensKey, root.swapFormData.toTokenKey,
                                                disabledChainIds, disabledChainIds, Constants.SendType.Swap, "")
        } else {
            root.swapProposalLoading = false
            root.swapOutputData.reset()
        }
    }

    function stopUpdatesForSuggestedRoute() {
        root.swapStore.stopUpdatesForSuggestedRoute()
    }

    function sendApproveTx() {
        root.approvalPending = true
        root.swapStore.authenticateAndTransfer(d.uuid, "")
    }

    function sendSwapTx() {
        root.swapStore.authenticateAndTransfer(d.uuid, root.swapFormData.selectedSlippage)
    }
}
