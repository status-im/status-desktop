import QtQuick 2.15

import SortFilterProxyModel 0.2
import StatusQ 0.1

import utils 1.0

QtObject {
    id: root

    /* PRIVATE: Modules used to get data from backend */
    readonly property var _allTokensModule: !!walletSectionAllTokens ? walletSectionAllTokens : null
    readonly property var _networksModule: !!networksModule ? networksModule : null

    readonly property double tokenListUpdatedAt: root._allTokensModule.tokenListUpdatedAt

    /* This contains the different sources for the tokens list
       ex. uniswap list, status tokens list */
    readonly property var sourcesOfTokensModel: SortFilterProxyModel {
        sourceModel: !!root._allTokensModule ? root._allTokensModule.sourcesOfTokensModel : null
        proxyRoles: ExpressionRole {
            function sourceImage(sourceKey) {
                return Constants.getSupportedTokenSourceImage(sourceKey)
            }
            name: "image"
            expression: sourceImage(model.key)
        }
        filters: AnyOf {
            ValueFilter {
                roleName: "key"
                value: Constants.supportedTokenSources.uniswap
            }
            ValueFilter {
                roleName: "key"
                value: Constants.supportedTokenSources.status
            }
        }
    }

    /* This list contains the complete list of tokens with separate
       entry per token which has a unique [address + network] pair */
    readonly property var flatTokensModel: !!root._allTokensModule ? root._allTokensModule.flatTokensModel : null

    /* PRIVATE: This model just combines tokens and network information in one */
    readonly property LeftJoinModel _joinFlatTokensModel : LeftJoinModel {
        leftModel: root.flatTokensModel
        rightModel: root._networksModule.flatNetworks

        joinRole: "chainId"
    }

    /* This list contains the complete list of tokens with separate
       entry per token which has a unique [address + network] pair including extended information
       about the specific network per entry */
    readonly property var extendedFlatTokensModel: SortFilterProxyModel {
        sourceModel: root._joinFlatTokensModel

        proxyRoles:  [
            ExpressionRole {
                name: "explorerUrl"
                expression: model.blockExplorerURL + "/token/" + model.address
            },
            ExpressionRole {
                function tokenIcon(symbol) {
                    return Constants.tokenIcon(symbol)
                }
                name: "image"
                expression: tokenIcon(model.symbol)
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
            ExpressionRole {
                function tokenIcon(symbol) {
                    return Constants.tokenIcon(symbol)
                }
                name: "iconSource"
                expression: tokenIcon(model.symbol)
            },
            // TODO: Review if it can be removed
            ExpressionRole {
                name: "shortName"
                expression: model.symbol
            },
            ExpressionRole {
                function getCategory(index) {
                    return 0
                }
                name: "category"
                expression: getCategory(model.communityId)
            }
        ]
    }

    // Property and methods below are used to apply advanced token management settings to the SendModal
    readonly property bool showCommunityAssetsInSend: root._allTokensModule.showCommunityAssetWhenSendingTokens
    readonly property bool balanceThresholdEnabled: root._allTokensModule.displayAssetsBelowBalance
    readonly property real balanceThresholdAmount: root._allTokensModule.displayAssetsBelowBalanceThreshold
}
