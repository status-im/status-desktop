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
    property alias communitiesShowcaseModel: communityJoinedModel.leftModel

    // adapted models
    readonly property alias adaptedCommunitiesSourceModel: communityJoinedModel

    // Accounts input models
    property alias accountsSourceModel: accountsSFPM.sourceModel

    // adapted models
    readonly property alias adaptedAccountsSourceModel: accountsSFPM

    //helpers
    property var isAddressSaved: (address) => false
    property bool isShowcaseLoading: false

    // Collectibles input models
    property alias collectiblesSourceModel: collectiblesSFPM.sourceModel
    property alias collectiblesShowcaseModel: collectiblesJoinedModel.leftModel

    // adapted models
    readonly property alias adaptedCollectiblesSourceModel: collectiblesJoinedModel

    // Social links input models
    property alias socialLinksSourceModel: socialLinksSFPM.sourceModel

    // adapted models
    readonly property alias adaptedSocialLinksSourceModel: socialLinksSFPM

    component JoinModel: LeftJoinModel {
        joinRole: "showcaseKey"
    }

    // Communities proxies

    SortFilterProxyModel {
        id: communitySFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.id
                expectedRoles: ["id"]
            },
            ConstantRole {
                name: "showcaseVisibility"
                value: Constants.ShowcaseVisibility.Everyone
            },
            FastExpressionRole {
                name: "isShowcaseLoading"
                expression: root.isShowcaseLoading
            }
        ]
    }

    JoinModel {
        id: communityJoinedModel
        rightModel: communitySFPM
    }

    SortFilterProxyModel {
        id: accountsSFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.address
                expectedRoles: ["address"]
            },
            FastExpressionRole {
                name: "saved"
                expression: root.isAddressSaved(model.address)
                expectedRoles: ["address"]
            },
            FastExpressionRole {
                name: "showcaseVisibility"
                expression: getShowcaseVisibility()
                function getShowcaseVisibility() {
                    return Constants.ShowcaseVisibility.Everyone
                }
            },
            FastExpressionRole {
                name: "canReceiveFromMyAccounts"
                expression: true
            }
        ]
    }

    // Collectibles proxies

    SortFilterProxyModel {
        id: collectiblesSFPM
        proxyRoles: [
            FastExpressionRole {
                name: "showcaseKey"
                expression: model.uid
                expectedRoles: ["uid"]
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

    JoinModel {
        id: collectiblesJoinedModel
        rightModel: collectiblesSFPM
    }

    // Social links proxies

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
