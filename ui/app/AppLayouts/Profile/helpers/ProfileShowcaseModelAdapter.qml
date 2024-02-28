import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

QObject {
    id: root

    // input models
    property alias communitiesSourceModel: communityRenamingSource.sourceModel
    property alias communitiesShowcaseModel: communityRenamingShowcase.sourceModel

    // adapted models
    readonly property alias adaptedCommunitiesSourceModel: communityRenamingSource
    readonly property alias adaptedCommunitiesShowcaseModel: communityRenamingShowcase

    // input models
    property alias accountsSourceModel: accountsRenamingSource.sourceModel
    property alias accountsShowcaseModel: accountsRenamingShowcase.sourceModel

    // adapted models
    readonly property alias adaptedAccountsSourceModel: accountsRenamingSource
    readonly property alias adaptedAccountsShowcaseModel: accountsRenamingShowcase

    // input models
    property alias collectiblesSourceModel: collectiblesRenamingSource.sourceModel
    property alias collectiblesShowcaseModel: collectiblesRenamingShowcase.sourceModel

    // adapted models
    readonly property alias adaptedCollectiblesSourceModel: collectiblesRenamingSource
    readonly property alias adaptedCollectiblesShowcaseModel: collectiblesRenamingShowcase


    RolesRenamingModel {
        id: communityRenamingSource
        mapping: [
            RoleRename {
                from: "id"
                to: "key"
            }
        ]
    }

    RolesRenamingModel {
        id: communityRenamingShowcase
        mapping: [
            RoleRename {
                from: "id"
                to: "key"
            },
            RoleRename {
                from: "order"
                to: "position"
            },
            RoleRename {
                from: "showcaseVisibility"
                to: "visibility"
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

    RolesRenamingModel {
        id: accountsRenamingSource
        mapping: [
            RoleRename {
                from: "address"
                to: "key"
            },
            RoleRename {
                from: "position"
                to: "positions"
            }
        ]
    }


    RolesRenamingModel {
        id: accountsRenamingShowcase
        mapping: [
            RoleRename {
                from: "address"
                to: "key"
            },
            RoleRename {
                from: "order"
                to: "position"
            },
            RoleRename {
                from: "showcaseVisibility"
                to: "visibility"
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

    RolesRenamingModel {
        id: collectiblesRenamingSource
        sourceModel: root.collectiblesSourceModel
        mapping: [
            RoleRename {
                from: "uid"
                to: "key"
            }
        ]
    }

    RolesRenamingModel {
        id: collectiblesRenamingShowcase
        sourceModel: root.collectiblesShowcaseModel

        mapping: [
            RoleRename {
                from: "uid"
                to: "key"
            },
            RoleRename {
                from: "order"
                to: "position"
            },
            RoleRename {
                from: "showcaseVisibility"
                to: "visibility"
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