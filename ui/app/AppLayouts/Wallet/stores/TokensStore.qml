import QtQuick

import QtModelsToolkit
import SortFilterProxyModel

import StatusQ

import utils

import shared.stores as SharedStores

QtObject {
    id: root

    required property SharedStores.NetworksStore networksStore

    /* PRIVATE: Modules used to get data from backend */
    readonly property var _allTokensModule: !!walletSectionAllTokens ? walletSectionAllTokens : null
    readonly property var _networksModule: !!networksModule ? networksModule : null

    readonly property double tokenListUpdatedAt: root._allTokensModule.tokenListUpdatedAt

    readonly property bool marketHistoryIsLoading: Global.appIsReady ? walletSectionAllTokens.marketHistoryIsLoading : false

    /* This contains the different sources for the tokens list
       ex. uniswap list, status tokens list */
    readonly property var sourcesOfTokensModel: SortFilterProxyModel {
        sourceModel: !!root._allTokensModule ? root._allTokensModule.sourcesOfTokensModel : null
        proxyRoles: FastExpressionRole {
            function sourceImage(name) {
                return Constants.getSupportedTokenSourceImage(name)
            }
            name: "image"
            expression: sourceImage(model.name)
            expectedRoles: ["name"]
        }
        filters: FastExpressionFilter {
            function shouldDisplayList(listName, tokensCount) {
                return listName !== Constants.supportedTokenSources.nativeList &&
                        listName !== Constants.supportedTokenSources.custom &&
                        tokensCount > 0
            }

            expression: {
                return shouldDisplayList(model.name, model.tokensCount)
            }
            expectedRoles: ["name", "tokensCount"]
        }
    }

    /* This list contains the complete list of tokens with separate
       entry per token which has a unique [address + network] pair */
    readonly property var flatTokensModel: !!root._allTokensModule ? root._allTokensModule.flatTokensModel : null

    /* PRIVATE: This model just combines tokens and network information in one */
    readonly property LeftJoinModel _joinFlatTokensModel : LeftJoinModel {
        leftModel: root.flatTokensModel
        rightModel: root.networksStore.allNetworks

        joinRole: "chainId"
    }

    /* This list contains the complete list of tokens with separate
       entry per token which has a unique [address + network] pair including extended information
       about the specific network per entry */
    readonly property var extendedFlatTokensModel: SortFilterProxyModel {
        sourceModel: root._joinFlatTokensModel

        proxyRoles:  [
            JoinRole {
                name: "explorerUrl"
                roleNames: ["blockExplorerURL", "address"]
                separator: "/token/"
            },
            FastExpressionRole {
                function tokenIcon(symbol) {
                    return Constants.tokenIcon(symbol)
                }
                name: "image"
                expression: tokenIcon(model.symbol)
                expectedRoles: ["symbol"]
            }
        ]
    }

    /* This list contains list of tokens grouped by symbol
       EXCEPTION: We may have different entries for the same symbol in case
       of symbol clash when minting community tokens, so in case of community tokens
       there will be one entry per address + network pair */
    // TODO in #12513
    readonly property var plainTokensBySymbolModel: !!root._allTokensModule ? root._allTokensModule.tokensBySymbolModel : null
    readonly property var assetsBySymbolModel: SortFilterProxyModel {
        sourceModel: plainTokensBySymbolModel
        proxyRoles: [
            FastExpressionRole {
                function tokenIcon(symbol) {
                    return Constants.tokenIcon(symbol)
                }
                name: "iconSource"
                expression: tokenIcon(model.symbol)
                expectedRoles: ["symbol"]
            },
            // TODO: Review if it can be removed
            FastExpressionRole {
                name: "shortName"
                expression: model.symbol
                expectedRoles: ["symbol"]
            },
            FastExpressionRole {
                function getCategory(index) {
                    return 0
                }
                name: "category"
                expression: getCategory(model.communityId)
                expectedRoles: ["communityId"]
            }
        ]
    }

    // Property and methods below are used to apply advanced token management settings to the SendModal

    // Temporarily disabled, refer to https://github.com/status-im/status-app/issues/15955 for details.
    readonly property bool showCommunityAssetsInSend: true //root._allTokensModule.showCommunityAssetWhenSendingTokens
    readonly property bool displayAssetsBelowBalance: root._allTokensModule.displayAssetsBelowBalance
    readonly property bool autoRefreshTokensLists: root._allTokensModule.autoRefreshTokensLists

    signal displayAssetsBelowBalanceThresholdChanged()

    function getHistoricalDataForToken(symbol, currency) {
        root._allTokensModule.getHistoricalDataForToken(symbol, currency)
    }

    function getDisplayAssetsBelowBalanceThresholdCurrency() {
        return root._allTokensModule.displayAssetsBelowBalanceThreshold
    }

    function getDisplayAssetsBelowBalanceThresholdDisplayAmount() {
        const thresholdCurrency = getDisplayAssetsBelowBalanceThresholdCurrency()
        return thresholdCurrency.amount / Math.pow(10, thresholdCurrency.displayDecimals)
    }

    function setDisplayAssetsBelowBalanceThreshold(rawValue) {
        // rawValue - raw amount (multiplied by displayDecimals)`
        root._allTokensModule.setDisplayAssetsBelowBalanceThreshold(rawValue)
    }

    function toggleShowCommunityAssetsInSend() {
        root._allTokensModule.toggleShowCommunityAssetWhenSendingTokens()
    }

    function toggleDisplayAssetsBelowBalance() {
        root._allTokensModule.toggleDisplayAssetsBelowBalance()
    }

    function toggleAutoRefreshTokensLists() {
        root._allTokensModule.toggleAutoRefreshTokensLists()
    }

    readonly property Connections allTokensConnections: Connections {
        target: root._allTokensModule

        function onDisplayAssetsBelowBalanceThresholdChanged() {
            root.displayAssetsBelowBalanceThresholdChanged()
        }
    }

    function updateTokenPreferences(jsonData) {
        root._allTokensModule.updateTokenPreferences(jsonData)
    }

    function getTokenPreferencesJson(jsonData) {
        return root._allTokensModule.getTokenPreferencesJson(jsonData)
    }
}
