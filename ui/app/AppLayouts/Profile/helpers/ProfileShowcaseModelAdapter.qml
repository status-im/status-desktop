import QtQml 2.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

QObject {
    id: root

    // Communities input models
    property alias communitiesSourceModel: communitySFPM.sourceModel

    // adapted models
    readonly property alias adaptedCommunitiesSourceModel: communitySFPM

    // Accounts input models
    property alias accountsSourceModel: accountsSFPM.sourceModel

    // adapted models
    readonly property alias adaptedAccountsSourceModel: accountsSFPM

    // Collectibles input models
    property alias collectiblesSourceModel: collectiblesSFPM.sourceModel

    // adapted models
    readonly property alias adaptedCollectiblesSourceModel: collectiblesSFPM

    // Social links input models
    property alias socialLinksSourceModel: socialLinksSFPM.sourceModel

    // adapted models
    readonly property alias adaptedSocialLinksSourceModel: socialLinksSFPM

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
