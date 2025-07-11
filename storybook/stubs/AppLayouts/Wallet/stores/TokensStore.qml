import QtQuick

QtObject {
    id: root

    property var plainTokensBySymbolModel
    property bool showCommunityAssetsInSend
    property bool displayAssetsBelowBalance
    property var getDisplayAssetsBelowBalanceThresholdDisplayAmount
    property double tokenListUpdatedAt
}
