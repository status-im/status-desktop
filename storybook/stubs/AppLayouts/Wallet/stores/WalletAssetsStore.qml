import QtQuick 2.15

import SortFilterProxyModel 0.2
import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import Storybook 1.0
import Models 1.0

QtObject {
    id: root

    property TokensStore walletTokensStore

    readonly property var groupedAccountsAssetsModel: GroupedAccountsAssetsModel {}
    property var assetsWithFilteredBalances
    readonly property var tokensBySymbolModel: TokensBySymbolModel {}
    readonly property CommunitiesModel communityModel: CommunitiesModel{}

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
}
