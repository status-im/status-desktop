import QtQuick 2.15

QtObject {
    id: root

    property var plainTokensBySymbolModel
    property bool showCommunityAssetsInSend
    property bool displayAssetsBelowBalance
    property var getDisplayAssetsBelowBalanceThresholdDisplayAmount
    property double tokenListUpdatedAt
}
