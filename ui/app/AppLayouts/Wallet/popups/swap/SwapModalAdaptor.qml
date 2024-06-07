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

    property bool showCommunityTokens

    // To expose the selected from and to Token from the SwapModal
    readonly property var fromToken: fromTokenEntry.item
    readonly property var toToken: toTokenEntry.item

    readonly property var nonWatchAccounts: SortFilterProxyModel {
        sourceModel: root.swapStore.accounts
        filters: ValueFilter {
            roleName: "walletType"
            value: Constants.watchWalletType
            inverted: true
        }
        sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        proxyRoles: [
            FastExpressionRole {
                name: "accountBalance"
                expression: d.processAccountBalance(model.address)
                expectedRoles: ["address"]
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

    // Model prepared to provide filtered and sorted assets as per the advanced Settings in token management
    readonly property var processedAssetsModel: SortFilterProxyModel {
        property real displayAssetsBelowBalanceThresholdAmount: root.walletAssetsStore.walletTokensStore.getDisplayAssetsBelowBalanceThresholdDisplayAmount()
        sourceModel: d.assetsWithFilteredBalances
        proxyRoles: [
            FastExpressionRole {
                name: "currentBalance"
                expression: {
                    // FIXME recalc when selectedNetworkChainId changes
                    root.swapFormData.selectedNetworkChainId
                    return d.getTotalBalance(model.balances, model.decimals)
                }
                expectedRoles: ["balances", "decimals"]
            },
            FastExpressionRole {
                name: "currentCurrencyBalance"
                expression: {
                    if (!!model.marketDetails) {
                        return model.currentBalance * model.marketDetails.currencyPrice.amount
                    }
                    return 0
                }
                expectedRoles: ["marketDetails", "currentBalance"]
            }
        ]
        filters: [
            FastExpressionFilter {
                expression: {
                    root.walletAssetsStore.assetsController.revision

                    if (!root.walletAssetsStore.assetsController.filterAcceptsSymbol(model.symbol)) // explicitely hidden
                        return false
                    if (!!model.communityId)
                        return root.showCommunityTokens
                    if (root.walletAssetsStore.walletTokensStore.displayAssetsBelowBalance)
                        return model.currentCurrencyBalance > processedAssetsModel.displayAssetsBelowBalanceThresholdAmount
                    return true
                }
                expectedRoles: ["symbol", "communityId", "currentCurrencyBalance"]
            }
        ]
        // FIXME sort by assetsController instead, to have the sorting/order as in the main wallet view
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

    QtObject {
        id: d

        property string uuid

        // Internal model filtering balances by the account selected in the AccountsModalHeader
        readonly property SubmodelProxyModel assetsWithFilteredBalances: SubmodelProxyModel {
            sourceModel: root.walletAssetsStore.groupedAccountAssetsModel
            submodelRoleName: "balances"
            delegateModel: SortFilterProxyModel {
                sourceModel: submodel

                filters: [
                    ValueFilter {
                        roleName: "chainId"
                        value: root.swapFormData.selectedNetworkChainId
                        enabled: root.swapFormData.selectedNetworkChainId !== -1
                    },
                    ValueFilter {
                        roleName: "account"
                        value: root.swapFormData.selectedAccountAddress
                    }
                ]
            }
        }

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
            if (!root.swapFormData.fromTokensKey) {
                return null
            }

            let network = ModelUtils.getByKey(root.filteredFlatNetworksModel, "chainId", root.swapFormData.selectedNetworkChainId)

            if (!network) {
                return null
            }

            let balancesModel = ModelUtils.getByKey(filteredBalancesModel, "tokensKey", root.swapFormData.fromTokensKey, "balances")
            let accountBalance = ModelUtils.getByKey(balancesModel, "account", address)
            if(accountBalance) {
                let balance = AmountsArithmetic.toNumber(accountBalance.balance, root.fromToken.decimals)
                let formattedBalance = root.formatCurrencyAmount(balance, root.fromToken.symbol)
                accountBalance.formattedBalance = formattedBalance
                return accountBalance
            }

            return {
                balance: "0",
                iconUrl: network.iconUrl,
                chainColor: network.chainColor,
                formattedBalance: root.formatCurrencyAmount(.0 , root.fromToken.symbol)
            }
        }

        /* Internal function to calculate total balance */
        function getTotalBalance(balances, decimals, chainIds = [root.swapFormData.selectedNetworkChainId]) {
            let totalBalance = 0
            for(let i=0; i<balances.count; i++) {
                let balancePerAddressPerChain = ModelUtils.get(balances, i)
                if (chainIds.includes(-1) || chainIds.includes(balancePerAddressPerChain.chainId))
                    totalBalance += AmountsArithmetic.toNumber(balancePerAddressPerChain.balance, decimals)
            }
            return totalBalance
        }
    }

    Connections {
        target: root.swapStore
        function onSuggestedRoutesReady(txRoutes) {
            root.swapOutputData.reset()
            root.validSwapProposalReceived = false
            root.swapProposalLoading = false
            root.swapOutputData.rawPaths = txRoutes.rawPaths
            // if valid route was found
            if(txRoutes.suggestedRoutes.count === 1) {
                root.validSwapProposalReceived = true
                root.swapOutputData.bestRoutes =  txRoutes.suggestedRoutes
                root.swapOutputData.toTokenAmount = root.swapStore.getWei2Eth(txRoutes.amountToReceive, root.toToken.decimals).toString()
                let gasTimeEstimate = txRoutes.gasTimeEstimate
                let totalTokenFeesInFiat = 0
                if (!!root.fromToken && !!root.fromToken .marketDetails && !!root.fromToken.marketDetails.currencyPrice)
                    totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.fromToken.marketDetails.currencyPrice.amount
                root.swapOutputData.totalFees = root.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat
                root.swapOutputData.approvalNeeded = ModelUtils.get(root.swapOutputData.bestRoutes, 0, "route").approvalRequired
            }
            else {
                root.swapOutputData.hasError = true
            }
        }
    }

    function reset() {
        root.swapFormData.resetFormData()
        root.swapOutputData.reset()
        root.validSwapProposalReceived = false
        root.swapProposalLoading = false
    }

    // this function will not reset input params but only the output ones and loading states
    function newFetchReset() {
        root.swapOutputData.reset()
        root.validSwapProposalReceived = false
        root.swapProposalLoading = false
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

    function getAllChainIds() {
        return ModelUtils.joinModelEntries(root.filteredFlatNetworksModel, "chainId", ":")
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

    function fetchSuggestedRoutes(cryptoValueRaw) {
        if (root.swapFormData.isFormFilledCorrectly() && !!cryptoValueRaw) {
            root.swapOutputData.reset()
            root.validSwapProposalReceived = false

            // Identify new swap with a different uuid
            d.uuid = Utils.uuid()

            let account = selectedAccountEntry.item
            let accountAddress = account.address
            let disabledChainIds = getDisabledChainIds(root.swapFormData.selectedNetworkChainId)
            let preferedChainIds = getAllChainIds()

            root.swapStore.fetchSuggestedRoutes(accountAddress, accountAddress,
                                                cryptoValueRaw, root.swapFormData.fromTokensKey, root.swapFormData.toTokenKey,
                                                disabledChainIds, disabledChainIds, preferedChainIds,
                                                Constants.SendType.Swap, "")
        } else {
            root.validSwapProposalReceived = false
            root.swapProposalLoading = false
        }
    }

    function sendApproveTx() {
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
