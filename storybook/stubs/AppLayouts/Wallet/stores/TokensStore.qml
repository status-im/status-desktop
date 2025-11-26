import QtQuick

QtObject {
    id: root

    property var tokenGroupsModel
    property var tokenGroupsForChainModel: null
    property bool showCommunityAssetsInSend
    property bool displayAssetsBelowBalance
    property var getDisplayAssetsBelowBalanceThresholdDisplayAmount
    property double tokenListUpdatedAt

    Component.onCompleted: tokenGroupsForChainModel = root.tokenGroupsModel

    function buildGroupsForChain(chainId) {
        tokenGroupsForChainModel = root.tokenGroupsModel
    }
}
