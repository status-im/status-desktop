import QtQml
import QtQml.Models

import StatusQ
import StatusQ.Core.Utils

import QtModelsToolkit
import SortFilterProxyModel

import utils

QObject {
    id: root

    // Communities input models
    property alias communitiesSourceModel: communitySFPM.sourceModel
    property alias communitiesShowcaseModel: communityJoinedModel.rightModel

    // adapted models
    readonly property alias adaptedCommunitiesSourceModel: communityJoinedModel

    // Accounts input models
    property alias accountsSourceModel: accountsSFPM.sourceModel
    property alias accountsShowcaseModel: accountsJoinedModel.rightModel

    // adapted models
    readonly property alias adaptedAccountsSourceModel: accountsJoinedModel

    // Collectibles input models
    property alias collectiblesSourceModel: collectiblesSFPM.sourceModel
    property alias collectiblesShowcaseModel: collectiblesJoinedModel.rightModel

    // adapted models
    readonly property alias adaptedCollectiblesSourceModel: collectiblesJoinedModel

    // Social links input models
    property alias socialLinksSourceModel: socialLinksSFPM.sourceModel

    // adapted models
    readonly property alias adaptedSocialLinksSourceModel: socialLinksSFPM

    component JoinModel: LeftJoinModel {
        joinRole: "showcaseKey"
    }

    //
    // Communities proxies
    //
    SortFilterProxyModel {
        id: communitySFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.id
                expectedRoles: ["id"]
            },
            FastExpressionRole {
                name: "membersCount"
                expression: model.allMembers.rowCount()
                expectedRoles: ["allMembers"]
            },
            ConstantRole {
                name: "isShowcaseLoading"
                value: false
            }
        ]
        filters: ValueFilter {
            roleName: "joined"
            value: true
        }
    }

    JoinModel {
        id: communityJoinedModel
        leftModel: communitySFPM
    }

    //
    // Accounts proxies
    //
    SortFilterProxyModel {
        id: accountsSFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.address
                expectedRoles: ["address"]
            },
            FastExpressionRole {
                function canReceiveFromMyAccounts() {
                    return accountsSourceModel.count > 1
                }
                name: "canReceiveFromMyAccounts"
                expression: canReceiveFromMyAccounts()
            }
        ]
    }

    JoinModel {
        id: accountsJoinedModel
        leftModel: accountsSFPM
    }

    //
    // Collectibles proxies
    //
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

    JoinModel {
        id: collectiblesJoinedModel
        leftModel: collectiblesSFPM
    }

    //
    // Social links proxies
    //
    SortFilterProxyModel {
        id: socialLinksSFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.url
                expectedRoles: ["url"]
            },
            FastExpressionRole {
                name: "showcaseVisibility"
                expression: getShowcaseVisibility()
                function getShowcaseVisibility() {
                    return Constants.ShowcaseVisibility.Everyone
                }
            }
        ]
    }
}
