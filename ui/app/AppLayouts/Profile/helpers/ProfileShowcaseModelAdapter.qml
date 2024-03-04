import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

QObject {
    id: root

    // Communities input models
    property alias communitiesSourceModel: communitySFPM.sourceModel
    property alias communitiesShowcaseModel: communityShowcaseRenaming.sourceModel

    // adapted models
    readonly property alias adaptedCommunitiesSourceModel: communitySFPM
    readonly property alias adaptedCommunitiesShowcaseModel: communityShowcaseRenaming

    // Accounts input models
    property alias accountsSourceModel: accountsSFPM.sourceModel
    property alias accountsShowcaseModel: accountsRenamingShowcase.sourceModel

    // adapted models
    readonly property alias adaptedAccountsSourceModel: accountsSFPM
    readonly property alias adaptedAccountsShowcaseModel: accountsRenamingShowcase

    // Collectibles input models
    property alias collectiblesSourceModel: collectiblesSFPM.sourceModel
    property alias collectiblesShowcaseModel: collectiblesRenamingShowcase.sourceModel

    // adapted models
    readonly property alias adaptedCollectiblesSourceModel: collectiblesSFPM
    readonly property alias adaptedCollectiblesShowcaseModel: collectiblesRenamingShowcase


    SortFilterProxyModel {
        id: communitySFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.id
                expectedRoles: ["id"]
            }
        ]
    }

    RolesRenamingModel {
        id: communityShowcaseRenaming
        mapping: [
            RoleRename {
                from: "id"
                to: "showcaseKey"
            },
            RoleRename {
                from: "order"
                to: "showcasePosition"
            },
            // Removing model duplicates
            // TODO: remove this when the lightweigth model is used
            // https://github.com/status-im/status-desktop/issues/13688
            RoleRename {
                from: "name"
                to: "_name"
            },
            RoleRename {
                from: "memberRole"
                to: "_memberRole"
            },
            RoleRename {
                from: "image"
                to: "_image"
            },
            RoleRename {
                from: "color"
                to: "_color"
            },
            RoleRename {
                from: "description"
                to: "_description"
            },
            RoleRename {
                from: "membersCount"
                to: "_membersCount"
            },
            RoleRename {
                from: "loading"
                to: "_loading"
            }
        ]
    }

    SortFilterProxyModel {
        id: accountsSFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.address
                expectedRoles: ["address"]
            }
        ]
    }

    RolesRenamingModel {
        id: accountsRenamingShowcase
        mapping: [
            RoleRename {
                from: "address"
                to: "showcaseKey"
            },
            RoleRename {
                from: "order"
                to: "showcasePosition"
            },
            // Removing model duplicates
            // TODO: remove this when the lightweigth model is used
            // https://github.com/status-im/status-desktop/issues/13688
            RoleRename {
                from: "name"
                to: "_name"
            },
            RoleRename {
                from: "emoji"
                to: "_emoji"
            },
            RoleRename {
                from: "colorId"
                to: "_colorId"
            }
        ]
    }

    SortFilterProxyModel {
        id: collectiblesSFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.uid
                expectedRoles: ["uid"]
            }
        ]
    }

    RolesRenamingModel {
        id: collectiblesRenamingShowcase
        mapping: [
            RoleRename {
                from: "uid"
                to: "showcaseKey"
            },
            RoleRename {
                from: "order"
                to: "showcasePosition"
            },
            // Removing model duplicates
            // TODO: remove this when the lightweigth model is used
            // https://github.com/status-im/status-desktop/issues/13688
            RoleRename {
                from: "chainId"
                to: "_chainId"
            },
            RoleRename {
                from: "contractAddress"
                to: "_contractAddress"
            },
            RoleRename {
                from: "tokenId"
                to: "_tokenId"
            },
            RoleRename {
                from: "name"
                to: "_name"
            },
            RoleRename {
                from: "imageUrl"
                to: "_imageUrl"
            },
            RoleRename {
                from: "backgroundColor"
                to: "_backgroundColor"
            },
            RoleRename {
                from: "collectionName"
                to: "_collectionName"
            },
            RoleRename {
                from: "isLoading"
                to: "_isLoading"
            },
            RoleRename {
                from: "communityId"
                to: "_communityId"
            }
        ]
    }
}