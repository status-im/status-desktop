import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Models 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0

import utils 1.0

import SortFilterProxyModel 0.2

QtObject {
    id: root

    property TokensStore walletTokensStore

    /* this property represents the grouped_account_assets_model from backend*/
    readonly property var baseGroupedAccountAssetModel: walletSectionAssets.groupedAccountAssetsModel

    readonly property var assetsController: ManageTokensController {
        sourceModel: groupedAccountAssetsModel
        settingsKey: "WalletAssets"
        serializeAsCollectibles: false

        onRequestSaveSettings: (jsonData) => {
            savingStarted()
            walletTokensStore.updateTokenPreferences(jsonData)
            savingFinished()
        }
        onRequestLoadSettings: {
            loadingStarted()
            let jsonData = walletTokensStore.getTokenPreferencesJson()
            loadingFinished(jsonData)
        }

        onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                         qsTr("%1 community assets successfully hidden").arg(communityName), "", "checkmark-circle",
                                         false, Constants.ephemeralNotificationType.success, "")
        onTokenShown: (symbol, name) => Global.displayToastMessage(qsTr("%1 is now visible").arg(name), "", "checkmark-circle",
                                                                   false, Constants.ephemeralNotificationType.success, "")
        onCommunityTokenGroupShown: (communityName) => Global.displayToastMessage(
                                        qsTr("%1 community assets are now visible").arg(communityName), "", "checkmark-circle",
                                        false, Constants.ephemeralNotificationType.success, "")
    }

    /* This model renames the role "key" to "tokensKey" in TokensBySymbolModel so that
    it can be easily joined with the Account Assets model */
    readonly property var renamedTokensBySymbolModel: RolesRenamingModel {
        objectName: "renamedTokensBySymbolModel"
        sourceModel: walletTokensStore.plainTokensBySymbolModel
        mapping: [
            RoleRename {
                from: "key"
                to: "tokensKey"
            }
        ]
    }

    /* PRIVATE: This model renames the roles
        1. "id" to "communityId"
        2. "name" to "communityName"
        3. "image" to "communityImage"
        4. "description" to "communityDescription"
    in communitiesModule.model so that it can be easily
    joined with the Account Assets model */
    readonly property var _renamedCommunitiesModel: RolesRenamingModel {
        sourceModel: communitiesModule.model
        mapping: [
            RoleRename {
                from: "id"
                to: "communityId"
            },
            RoleRename {
                from: "name"
                to: "communityName"
            },
            RoleRename {
                from: "image"
                to: "communityImage"
            },
            RoleRename {
                from: "description"
                to: "communityDescription"
            }
        ]
    }

    /* PRIVATE: This model joins the "Tokens By Symbol Model" and "Communities Model" by communityId */
    property LeftJoinModel _jointTokensBySymbolModel: LeftJoinModel {
        leftModel: renamedTokensBySymbolModel
        rightModel: _renamedCommunitiesModel
        joinRole: "communityId"
    }

    /* This model joins the "Tokens by symbol model combined with Community details"
    and "Grouped Account Assets Model" by tokenskey */
    property LeftJoinModel groupedAccountAssetsModel: LeftJoinModel {
        objectName: "groupedAccountAssetsModel"

        leftModel: root.baseGroupedAccountAssetModel
        rightModel: _jointTokensBySymbolModel
        joinRole: "tokensKey"
    }

    // This is hard coded for now, and should be updated whenever Hop add new tokens for support
    // This should be dynamically fetched somehow in the future
    readonly property var tokensSupportedByHopBridge: [
        Constants.uniqueSymbols.usdcEvm,
        Constants.uniqueSymbols.usdcBsc,
        "USDC.e",
        Constants.uniqueSymbols.usdtEvm,
        Constants.uniqueSymbols.usdtBsc,
        "DAI",
        "HOP",
        "SNX",
        "sUSD",
        "rETH",
        "MAGIC",
        "ETH"
    ]

    readonly property SortFilterProxyModel bridgeableGroupedAccountAssetsModel: SortFilterProxyModel {
        objectName: "bridgeableGroupedAccountAssetsModel"
        sourceModel: root.groupedAccountAssetsModel

        filters: [
            FastExpressionFilter {
                function isBSC(chainId) {
                    return chainId === Constants.chains.binanceSmartChainMainnetChainId ||
                            chainId === Constants.chains.binanceSmartChainTestnetChainId
                }
                expression: !isBSC(model.chainId) && root.tokensSupportedByHopBridge.includes(model.symbol)
                expectedRoles: ["chainId", "symbol"]
            }
        ]
    }
}

