import QtQuick

import Storybook
import Models

QtObject {
    id: root

    property TokensStore walletTokensStore: TokensStore {}

    property var assetsWithFilteredBalances: GroupedAccountsAssetsModel {}
    property var tokenGroupsModel: TokenGroupsModel {}
    readonly property var communityModel: ListModel {
        Component.onCompleted: append([
            {
                communityId: "ddls",
                communityName: "Doodles",
                communityImage: ModelsData.collectibles.doodles
            },
            {
                communityId: "sox",
                communityName: "Socks",
                communityImage: ModelsData.icons.socks
            },
            {
                communityId: "ast",
                communityName: "Astafarians",
                communityImage: ModelsData.icons.dribble
            }
        ])
    }

    // For storybook tests we keep the processed models identical to the raw assets
    readonly property var baseGroupedAccountAssetModel: assetsWithFilteredBalances
    property var groupedAccountAssetsModel: assetsWithFilteredBalances

    readonly property var assetsController: QtObject {
        property int revision
        function filterAcceptsSymbol(symbol) {
            return true
        }
    }
}
