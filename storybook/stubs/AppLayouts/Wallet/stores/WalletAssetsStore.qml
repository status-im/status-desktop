import QtQuick 2.15

import StatusQ 0.1

import Storybook 1.0
import Models 1.0

QtObject {
    id: root

    property TokensStore walletTokensStore: TokensStore {}

    readonly property var groupedAccountsAssetsModel: GroupedAccountsAssetsModel {}
    property var assetsWithFilteredBalances
    readonly property var tokensBySymbolModel: TokensBySymbolModel {}
    readonly property var communityModel: ListModel {
        Component.onCompleted: append([{
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
        }])
    }

    // renaming tokens by symbol key so that can be used to join models
    readonly property var renamedTokensBySymbolModel: RolesRenamingModel {
        sourceModel: tokensBySymbolModel
        mapping: [
            RoleRename {
                from: "key"
                to: "tokensKey"
            }
        ]
    }

    // join account assets and tokens by symbol model
    property LeftJoinModel jointModel: LeftJoinModel {
        leftModel: assetsWithFilteredBalances
        rightModel: renamedTokensBySymbolModel
        joinRole: "tokensKey"
    }

    // combining community model with assets to get community meta data
    property LeftJoinModel groupedAccountAssetsModel: LeftJoinModel {
        leftModel: jointModel
        rightModel: communityModel
        joinRole: "communityId"
    }

    readonly property var assetsController: QtObject {
        property int revision

        function filterAcceptsTokenKey(symbol) {
            return true
        }
    }
}
