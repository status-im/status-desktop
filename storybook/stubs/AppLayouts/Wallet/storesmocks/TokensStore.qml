import QtQuick

import StatusQ.Core.Utils

import QtModelsToolkit

import AppLayouts.Wallet.stores

TokensStore {
    id: root

    property var tokenGroupsModel
    property var tokenGroupsForChainModel
    property var searchResultModel
    property bool showCommunityAssetsInSend
    property bool displayAssetsBelowBalance
    property var _displayAssetsBelowBalanceThresholdDisplayAmountFunc: function() { return 0 }
    property double tokenListUpdatedAt

    function getDisplayAssetsBelowBalanceThresholdDisplayAmount() {
        return _displayAssetsBelowBalanceThresholdDisplayAmountFunc()
    }

    function buildGroupsForChain(chainId) {
        if (!root.tokenGroupsModel || chainId <= 0) {
            console.warn("buildGroupsForChain: invalid parameters", chainId)
            return
        }

        if (!root.tokenGroupsForChainModel) {
            console.warn("buildGroupsForChain: tokenGroupsForChainModel is not set")
            return
        }

        root.tokenGroupsForChainModel.clear()

        for (let i = 0; i < root.tokenGroupsModel.ModelCount.count; i++) {
            const group = ModelUtils.get(root.tokenGroupsModel, i)

            if (!group.tokens || group.tokens.ModelCount.count === 0) {
                continue
            }

            const tokensListModel = Qt.createQmlObject('import QtQuick; ListModel {}', root)
            for (let j = 0; j < group.tokens.ModelCount.count; j++) {
                const token = ModelUtils.get(group.tokens, j)
                if (token.chainId === chainId) {
                    tokensListModel.append({
                        key: token.key,
                        groupKey: token.groupKey,
                        crossChainId: token.crossChainId,
                        chainId: token.chainId,
                        address: token.address,
                        name: token.name,
                        symbol: token.symbol,
                        decimals: token.decimals,
                        image: token.image,
                        customToken: token.customToken,
                        communityId: token.communityId
                    })
                }
            }

            if (tokensListModel.count > 0) {
                root.tokenGroupsForChainModel.append({
                    key: group.key,
                    symbol: group.symbol,
                    name: group.name,
                    decimals: group.decimals,
                    logoUri: group.logoUri,
                    tokens: tokensListModel,
                    communityId: group.communityId || "",
                    marketDetails: group.marketDetails || {},
                    detailsLoading: group.detailsLoading || false,
                    marketDetailsLoading: group.marketDetailsLoading || false
                })
            }
        }
    }
}
