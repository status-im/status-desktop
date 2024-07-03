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

    // To expose the selected from and to Token from the SwapModal
    readonly property var fromToken: fromTokenEntry.item
    readonly property var toToken: toTokenEntry.item

    readonly property string uuid: d.uuid

    readonly property var nonWatchAccounts: SortFilterProxyModel {
        sourceModel: root.swapStore.accounts
        filters: ValueFilter {
            roleName: "walletType"
            value: Constants.watchWalletType
            inverted: true
        }
        sorters: [
            RoleSorter { roleName: "currencyBalanceDouble"; sortOrder: Qt.DescendingOrder },
            RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        ]
        proxyRoles: [
            FastExpressionRole {
                name: "accountBalance"
                expression: d.processAccountBalance(model.address)
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
            },
            FastExpressionRole {
                name: "colorizedChainPrefixes"
                function getChainShortNames(chainIds) {
                    const chainShortNames = root.getNetworkShortNames(chainIds)
                    return WalletUtils.colorizedChainPrefix(chainShortNames)
                }
                expression: getChainShortNames(model.preferredSharingChainIds)
                expectedRoles: ["preferredSharingChainIds"]
            }
        ]
    }

    readonly property SortFilterProxyModel filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.swapStore.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: root.swapStore.areTestNetworksEnabled }
    }

    signal suggestedRoutesReady()

    QtObject {
        id: d

        property string uuid
        // storing txHash to verify against tx completed event
        property string txHash

        readonly property SubmodelProxyModel filteredBalancesModel: SubmodelProxyModel {
            sourceModel: root.walletAssetsStore.baseGroupedAccountAssetModel
            submodelRoleName: "balances"
            delegateModel: SortFilterProxyModel {
                sourceModel: joinModel
                filters: ValueFilter {
                    roleName: "chainId"
                    value: root.swapFormData.selectedNetworkChainId
                }
                readonly property LeftJoinModel joinModel: LeftJoinModel {
                    leftModel: submodel
                    rightModel: root.swapStore.flatNetworks

                    joinRole: "chainId"
                }
            }
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
        function onSuggestedRoutesReady(txRoutes) {
            if (txRoutes.uuid !== d.uuid) {
                // Suggested routes for a different fetch, ignore
                return
            }
            root.swapOutputData.reset()
            root.validSwapProposalReceived = false
            root.swapProposalLoading = false
            root.swapOutputData.rawPaths = txRoutes.rawPaths
            // if valid route was found
            if(txRoutes.suggestedRoutes.count === 1) {
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
            }
            else {
                root.swapOutputData.hasError = true
            }
            root.suggestedRoutesReady()
        }

        function onTransactionSent(chainId, txHash, uuid, error) {
            if(root.swapOutputData.approvalNeeded) {
                if (uuid !== d.uuid || !!error) {
                    root.approvalPending = false
                    root.approvalSuccessful = false
                    return
                }
                root.approvalPending = true
                d.txHash = txHash
            }
        }

        function onTransactionSendingComplete(txHash, success) {
            if(d.txHash === txHash && root.swapOutputData.approvalNeeded && root.approvalPending) {
                root.approvalPending = false
                root.approvalSuccessful = success
                d.txHash = ""
            }
        }
    }

    function reset() {
        root.swapFormData.resetFormData()
        root.swapOutputData.reset()
        root.validSwapProposalReceived = false
        root.swapProposalLoading = false
        root.approvalPending = false
        root.approvalSuccessful = false
        d.txHash = ""
    }

    function getNetworkShortNames(chainIds) {
        var networkString = ""
        let chainIdsArray = chainIds.split(":")
        for (let i = 0; i< chainIdsArray.length; i++) {
            let nwShortName = ModelUtils.getByKey(root.filteredFlatNetworksModel, "chainId", Number(chainIdsArray[i]), "shortName")
            if(!!nwShortName) {
                networkString = networkString + nwShortName + ':'
            }
        }
        return networkString
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

    function fetchSuggestedRoutes(cryptoValueInRaw) {
        root.swapFormData.toTokenAmount = ""
        if (root.swapFormData.isFormFilledCorrectly() && !!cryptoValueInRaw) {
            // Identify new swap with a different uuid
            d.uuid = Utils.uuid()

            root.swapProposalLoading = true

            let account = selectedAccountEntry.item
            let accountAddress = account.address
            let disabledChainIds = getDisabledChainIds(root.swapFormData.selectedNetworkChainId)

            root.swapStore.fetchSuggestedRoutes(d.uuid, accountAddress, accountAddress,
                                                cryptoValueInRaw, "0", root.swapFormData.fromTokensKey, root.swapFormData.toTokenKey,
                                                disabledChainIds, disabledChainIds, Constants.SendType.Swap, "")
        } else {
            root.swapProposalLoading = false
            root.swapOutputData.reset()
        }
    }

    function sendApproveTx() {
        root.approvalPending = true

        let account = selectedAccountEntry.item
        let accountAddress = account.address

        root.swapStore.authenticateAndTransfer(d.uuid, accountAddress, accountAddress,
            root.swapFormData.fromTokensKey, root.swapFormData.toTokenKey,
            Constants.SendType.Approve, "", false, root.swapOutputData.rawPaths, "")
    }

    function sendSwapTx() {
        let account = selectedAccountEntry.item
        let accountAddress = account.address

        root.swapStore.authenticateAndTransfer(d.uuid, accountAddress, accountAddress,
            root.swapFormData.fromTokensKey, root.swapFormData.toTokenKey,
            Constants.SendType.Swap, "", false, root.swapOutputData.rawPaths, root.swapFormData.selectedSlippage)
    }
}
