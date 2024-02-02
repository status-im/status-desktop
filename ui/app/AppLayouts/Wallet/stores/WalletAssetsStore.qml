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

    readonly property var assetsController: ManageTokensController {
        sourceModel: groupedAccountAssetsModel
        settingsKey: "WalletAssets"
        onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                         qsTr("%1 community assets successfully hidden").arg(communityName), "", "checkmark-circle",
                                         false, Constants.ephemeralNotificationType.success, "")
        onTokenShown: (symbol, name) => Global.displayToastMessage(qsTr("%1 is now visible").arg(name), "", "checkmark-circle",
                                                                   false, Constants.ephemeralNotificationType.success, "")
        onCommunityTokenGroupShown: (communityName) => Global.displayToastMessage(
                                        qsTr("%1 community assets are now visible").arg(communityName), "", "checkmark-circle",
                                        false, Constants.ephemeralNotificationType.success, "")
    }

    /* PRIVATE: This model renames the role "key" to "tokensKey" in TokensBySymbolModel so that
    it can be easily joined with the Account Assets model */
    readonly property var _renamedTokensBySymbolModel: RolesRenamingModel {
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
        leftModel: _renamedTokensBySymbolModel
        rightModel: _renamedCommunitiesModel
        joinRole: "communityId"
    }

    /* This model joins the "Tokens by symbol model combined with Community details"
    and "Grouped Account Assets Model" by tokenskey */
    property LeftJoinModel groupedAccountAssetsModel: LeftJoinModel {
        leftModel: walletSectionAssets.groupedAccountAssetsModel
        rightModel: _jointTokensBySymbolModel
        joinRole: "tokensKey"
    }
}
