import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import AppLayouts.Profile.helpers 1.0

QObject {
    id: root

    // for Shell grid entries
    required property var sectionsBaseModel
    required property var chatsBaseModel
    required property var walletsBaseModel
    required property var dappsBaseModel
    required property string searchPhrase

    // for Settings
    required property int syncingBadgeCount
    required property int messagingBadgeCount
    required property bool showBackUpSeed

    // internal settings
    required property string profileId
    property bool showEnabledSectionsOnly
    property bool marketEnabled: true

    property bool showCommunities: true
    property bool showSettings: true
    property bool showChats: true
    property bool showWallets: true
    property bool showDapps: true

    readonly property var shellEntriesModel: d.shellEntriesModel
    Component.onCompleted: Qt.callLater(() => d.shellEntriesModel = filteredCombinedModel) // FIXME bug in SFPM or OPM

    QtObject {
        id: d
        property var shellEntriesModel
    }

    readonly property var sectionsModel: SortFilterProxyModel {
        sourceModel: root.sectionsBaseModel
        filters: [
            ValueFilter {
                roleName: "sectionType"
                value: Constants.appSection.loadingSection
                inverted: true
            },
            ValueFilter {
                roleName: "sectionType"
                value: Constants.appSection.community
                inverted: true
            },
            ValueFilter {
                roleName: "sectionType"
                value: Constants.appSection.swap
                enabled: root.marketEnabled
                inverted: true
            },
            ValueFilter {
                roleName: "sectionType"
                value: Constants.appSection.market
                enabled: !root.marketEnabled
                inverted: true
            },
            ValueFilter {
                roleName: "enabled"
                value: true
                enabled: root.showEnabledSectionsOnly
            }
        ]
        sorters: [
            FilterSorter {
                ValueFilter { roleName: "sectionType"; value: Constants.appSection.profile; inverted: true } // Settings last
            },
            FilterSorter {
                ValueFilter { roleName: "sectionType"; value: Constants.appSection.node; inverted: true } // Node second last
            },
            RoleSorter { roleName: "sectionType" }
        ]
    }

    readonly property var pinnedModel: SortFilterProxyModel {
        sourceModel: shellProxyModel
        filters: [
            ValueFilter {
                roleName: "pinned"
                value: true
            }
        ]
        sorters: [
            RoleSorter {
                roleName: "timestamp"
            }
        ]
    }

    function clearPinnedItems() {
        shellProxyModel.clearPinnedItems()
    }

    ObjectProxyModel {
        id: communitiesModel

        sourceModel: SortFilterProxyModel {
            sourceModel: root.sectionsBaseModel
            filters: [
                ValueFilter {
                    roleName: "sectionType"
                    value: Constants.appSection.community
                }
            ]
        }

        delegate: QtObject {
            readonly property string key: Constants.appSection.community + ';' + model.id
            readonly property string id: model.id
            readonly property string name: model.name
            readonly property string icon: model.image
            readonly property color color: model.color
            readonly property string banner: model.bannerImageData
            readonly property bool hasNotification: model.hasNotification
            readonly property int notificationsCount: model.notificationsCount

            readonly property int members: model.allMembers.ModelCount.count
            readonly property int activeMembers: model.activeMembersCount

            readonly property bool pending: model.spectated && !model.joined
            readonly property bool banned: model.amIBanned
        }

        expectedRoles: ["id", "name", "image", "color", "bannerImageData", "hasNotification", "notificationsCount",
            "allMembers", "activeMembersCount", "spectated", "joined", "amIBanned"]
        exposedRoles: ["key", "id", "name", "icon", "color", "banner", "hasNotification", "notificationsCount",
            "members", "activeMembers", "pending", "banned"]
    }

    ObjectProxyModel {
        id: settingsModel

        sourceModel: SettingsEntriesModel {
            showWalletEntries: true
            syncingBadgeCount: root.syncingBadgeCount
            messagingBadgeCount: root.messagingBadgeCount
            showBackUpSeed: root.showBackUpSeed
            showSubSubSections: true
        }
        delegate: QtObject {
            readonly property string key: Constants.appSection.profile + ';' + model.subsection
            readonly property string id: model.subsection
            readonly property string name: model.text
            readonly property string icon: model.icon
            readonly property color color: Theme.palette.primaryColor1
            readonly property bool hasNotification: model.badgeCount > 0
            readonly property int notificationsCount: model.badgeCount

            readonly property bool isExperimental: model.isExperimental
        }
        expectedRoles: ["subsection", "text", "icon", "badgeCount", "isExperimental"]
        exposedRoles: ["key", "id", "name", "icon", "color", "hasNotification", "notificationsCount",
            "isExperimental"]
    }

    ObjectProxyModel {
        id: chatsModel
        sourceModel: SortFilterProxyModel {
            sourceModel: root.chatsBaseModel
            filters: [
                ValueFilter {
                    roleName: "isCategory"
                    value: false
                }
            ]
        }
        delegate: QtObject {
            readonly property string key: Constants.appSection.chat + ';' + model.itemId
            readonly property string id: model.itemId
            readonly property string name: model.name
            readonly property string icon: model.icon || model.emoji
            readonly property color color: model.color || Utils.colorForColorId(model.colorId)
            readonly property bool hasNotification: model.hasUnreadMessages || model.notificationsCount
            readonly property int notificationsCount: model.notificationsCount

            readonly property int chatType: model.type // cf. Constants.chatType.*
            readonly property int onlineStatus: model.onlineStatus // cf. Constants.onlineStatus.*
        }

        expectedRoles: ["itemId", "type", "name", "emoji", "icon", "color", "colorId", "hasUnreadMessages", "notificationsCount", "onlineStatus"]
        exposedRoles: ["key", "id", "chatType", "name", "icon", "color", "hasNotification", "notificationsCount", "onlineStatus"]
    }

    ObjectProxyModel {
        id: walletsModel

        sourceModel: root.walletsBaseModel
        delegate: QtObject {
            readonly property string key: Constants.appSection.wallet + ';' + model.mixedcaseAddress
            readonly property string id: model.mixedcaseAddress
            readonly property string name: model.name
            readonly property string icon: model.emoji
            readonly property color color: Utils.getColorForId(model.colorId ?? Constants.walletAccountColors.primary)
            readonly property bool hasNotification: false
            readonly property int notificationsCount: 0

            readonly property string walletType: model.walletType
            readonly property string currencyBalance: LocaleUtils.currencyAmountToLocaleString(model.currencyBalance)
        }
        expectedRoles: ["mixedcaseAddress", "name", "emoji", "colorId", "walletType", "currencyBalance"]
        exposedRoles: ["key", "id", "name", "icon", "color", "hasNotification", "notificationsCount", "walletType", "currencyBalance"]
    }

    ObjectProxyModel {
        id: dappsModel

        sourceModel: root.dappsBaseModel
        delegate: QtObject {
            readonly property string key: Constants.appSection.dApp + ';' + model.url
            readonly property string id: model.url
            readonly property string name: model.name || StringUtils.extractDomainFromLink(model.url)
            readonly property string icon: model.iconUrl || "dapp"
            readonly property color color: Theme.palette.primaryColor1

            readonly property url connectorBadge: model.connectorBadge
        }
        expectedRoles: ["url", "name", "iconUrl", "connectorBadge"]
        exposedRoles: ["key", "id", "name", "icon", "color", "connectorBadge"]
    }

    ConcatModel {
        id: combinedModel
        sources: [
            SourceModel {
                model: root.showCommunities ? communitiesModel : null
                markerRoleValue: Constants.appSection.community
            },
            SourceModel {
                model: root.showWallets ? walletsModel : null
                markerRoleValue: Constants.appSection.wallet
            },
            SourceModel {
                model: root.showSettings ? settingsModel : null
                markerRoleValue: Constants.appSection.profile
            },
            SourceModel {
                model: root.showChats ? chatsModel : null
                markerRoleValue: Constants.appSection.chat
            },
            SourceModel {
                model: root.showDapps ? dappsModel : null
                markerRoleValue: Constants.appSection.dApp
            }
        ]

        markerRoleName: "sectionType"
        expectedRoles: ["key", "id", "enabled", "name", "icon", "color", "hasNotification", "notificationsCount", // common props
            "banner", "members", "activeMembers", "pending", "banned", // community
            "isExperimental", // settings
            "walletType", "currencyBalance", // wallet
            "connectorBadge" // dapp
        ]
    }

    ShellProxyModel { // provides a writable overlay for "timestamp" and "pinned" roles
        id: shellProxyModel
        sourceModel: combinedModel
        profileId: root.profileId
    }

    SortFilterProxyModel {
        id: filteredCombinedModel
        sourceModel: shellProxyModel

        filters: [
            SearchFilter {
                roleName: "name"
                searchPhrase: root.searchPhrase
            }
        ]
        sorters: [
            FastExpressionSorter {
                expression: {
                    if (modelLeft.hasNotification && modelRight.hasNotification)
                        return modelRight.notificationsCount - modelLeft.notificationsCount
                    return modelRight.hasNotification - modelLeft.hasNotification
                }
                expectedRoles: ["hasNotification", "notificationsCount"]
            },
            RoleSorter {
                roleName: "name"
            }
        ]
    }
}
