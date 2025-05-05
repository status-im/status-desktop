import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import SortFilterProxyModel 0.2

import utils 1.0

import AppLayouts.Shell 1.0
import AppLayouts.Profile.helpers 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    SectionsModel {
        id: sectionsBaseModel
    }

    // TODO CommunitiesPortalDummyModel -> SectionModel
    CommunitiesPortalDummyModel {
        id: communitiesModel
    }

    SortFilterProxyModel {
        id: sectionsModel
        sourceModel: sectionsBaseModel
        filters: [
            ValueFilter {
                roleName: "sectionType"
                value: Constants.appSection.loadingSection
                inverted: true
            }
        ]
    }

    ObjectProxyModel {
        id: settingsModel

        sourceModel: SettingsEntriesModel {
            // FIXME expose these props to the adaptor
            showWalletEntries: true
            syncingBadgeCount: 2
            messagingBadgeCount: 4
        }

        delegate: QObject {
            readonly property string id: model.subsection
            readonly property string name: model.text
            readonly property string icon: model.icon
            readonly property bool hasNotification: model.badgeCount > 0
            readonly property int notificationsCount: model.badgeCount
            readonly property bool isExperimental: model.isExperimental
        }
        expectedRoles: ["subsection", "text", "icon", "badgeCount", "isExperimental"]
        exposedRoles: ["id", "name", "icon", "hasNotification", "notificationsCount", "isExperimental",
            "onlineStatus"]
    }

    ObjectProxyModel {
        id: walletsModel

        sourceModel: WalletAccountsModel {}
        delegate: QObject {
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
        exposedRoles: ["id", "name", "icon", "color", "hasNotification", "notificationsCount", "walletType", "currencyBalance",
            "onlineStatus", "isExperimental"]
    }

    SortFilterProxyModel {
        id: chatsModel
        sourceModel: ObjectProxyModel {
            sourceModel: ListModel {
                ListElement {
                    itemId: "id0"
                    categoryId: "id0"
                    active: false
                    notificationsCount: 0
                    hasUnreadMessages: false
                    name: "Category X"
                    icon: ""
                    isCategory: true
                    categoryOpened: true
                    muted: false
                }
                ListElement {
                    itemId: "id1"
                    type: StatusChatListItem.Type.OneToOneChat
                    onlineStatus: 1 //Constants.onlineStatus.online
                    name: "Punxnotdead"
                    categoryId: "id0"
                    active: false
                    notificationsCount: 0
                    hasUnreadMessages: false
                    color: ""
                    colorId: 1
                    icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACkAAAAoCAYAAABjPNNTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAALiSURBVHgB1ZhPTxNBGId/24IWYiIeNEUikkg1EtL2APRSYoKUNl5EvEhjgn4Ba3rxqEc92MgXUE/WE9GDxCKSEIkJcqnBQAyYkCqIxQChBLG1xX2n2dp/6u7sbFOepNnuzM7uk3fm3ZlZ6f7NF9ekPekRqhQJ0uMaCGZ96xsWv8zmzrvaeqEX4ZKfZMGnr0K586qTDMtyG1txiEao5MzcOIxAiGR4LISZeWMECV2SSpKsJ8R3cT66JIuTxChM4ISSRE0Xs+t0jlXuSKp9sHJdp45XkWZJJUkWnt8pqbNd/FN290Y/Lp93sv8jE1EEhy9g0BPkklXd3ZQk7+So2E7WYaAn+3CTuRY1dYfZkaDyrvaWkrZNxxpY3Y9UjN3DMEklSeynzbgX6M82PlgPy5HjMMtHgsqV6OXjksWpzmRa5Eo07jFpaWhEJp3C7sYKMsmdEiFXmYjywi1ZU9+AXzubSCa+F5QrXSsSbsntlXlUCtWSzc0n4Pf70Wp3wmJtAQ/nepNy2zZoRbWk292N7kvXoYehM30Yko8Pb7/V1E615NTUGzZ7UDTdbjcre//VjJcLtQXXORvT8NpSqI1EYI5GC+pSPh/SDge0oloyFvssSz7JCRKr2yZEiiQJkiRBEs0n7XRySap6T9Js8TM9wWYZT1Mca5MPUEl0rYKshzLwtaYKyhxydxMUNUhSQV3GagUPuiRJSJEqJuX1sp8IVEtOf1jCreFnGJCnPZpNEh/HoJWR11F2n46jVzW1Uy25HN9kqxlaQLjagd3VOWhlcnyU3aMjYIBkKDDK1oVhFYsDkqCIK5Rb0mlF+L67qubuv+Fiw6EFIuHe4+RT3MWiESI5PbvERI1CSHfTIpd++XschapLHNEJoyBUUtn7iEZ4dpdDGbN76VZc8fRAK0IS538sr2VnK8uBZq7vlUIiSa+ff2U3fRCgWYsXod3debZ8lE412aEHoZKDfUEYQUXGpF72heRvWCUEXU7sGx8AAAAASUVORK5CYII="
                    muted: false
                    isCategory: false
                    categoryOpened: true
                }
                ListElement {
                    itemId: "id2"
                    categoryId: "id2"
                    name: "Category Y"
                    active: false
                    notificationsCount: 12
                    hasUnreadMessages: false
                    color: ""
                    colorId: 2
                    icon: ""
                    isCategory: true
                    categoryOpened: false
                    muted: false
                }
                ListElement {
                    itemId: "id3"
                    categoryId: "id2"
                    name: "Channel Y_1"
                    emoji: "💩"
                    active: false
                    notificationsCount: 0
                    hasUnreadMessages: true
                    color: ""
                    colorId: 2
                    icon: ""
                    muted: false
                    isCategory: false
                    categoryOpened: true
                }
                ListElement {
                    itemId: "id4"
                    categoryId: "id2"
                    name: "Channel Y_2"
                    active: false
                    notificationsCount: 0
                    hasUnreadMessages: false
                    color: "red"
                    colorId: 3
                    icon: ""
                    muted: false
                    isCategory: false
                    categoryOpened: true
                }
                ListElement {
                    itemId: "id5"
                    categoryId: "id2"
                    name: "Channel Y_3"
                    active: false
                    notificationsCount: 1
                    hasUnreadMessages: false
                    color: ""
                    colorId: 4
                    icon: ""
                    muted: false
                    isCategory: false
                    categoryOpened: true
                }
            }

            delegate: QObject {
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
            exposedRoles: ["id", "chatType", "name", "icon", "color", "hasNotification", "notificationsCount", "onlineStatus",
                "isExperimental", "walletType", "currencyBalance"]
        }
        filters: [
            ValueFilter {
                roleName: "isCategory"
                value: false
            }
        ]
    }

    ConcatModel {
        id: combinedModel
        sources: [
            SourceModel {
                model: communitiesModel // TODO sectionsModel
                markerRoleValue: Constants.appSection.community
            },
            SourceModel {
                model: walletsModel
                markerRoleValue: Constants.appSection.wallet
            },
            SourceModel {
                model: settingsModel
                markerRoleValue: Constants.appSection.profile
            },
            SourceModel {
                model: chatsModel
                markerRoleValue: Constants.appSection.chat
            }
        ]

        markerRoleName: "sectionType"
        expectedRoles: ["id", "name", "icon", "color", "hasNotification", "notificationsCount", // common props
            "banner", "members", "activeMembers" // FIXME correct community -> section props
        ]
    }

    ShellContainer {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        model: combinedModel
        sectionsModel: sectionsModel // TODO merge with above model

        profileStore: ProfileStores.ProfileStore {
            readonly property string pubkey: "0xdeadbeef"
            readonly property string compressedPubKey: "zxDeadBeef"
            readonly property string name: "John Roe"
            readonly property string icon: ModelsData.icons.rarible
            readonly property int colorId: 7
            readonly property var colorHash: [{colorId: 0, segmentLength: 1}, {colorId: 4, segmentLength: 2}]
            readonly property int currentUserStatus: Constants.currentUserStatus.automatic
        }

        useNewDockIcons: ctrlNewIcons.checked
        hasUnseenACNotifications: ctrlHasNotifications.checked
        aCNotificationCount: ctrlNotificationsCount.value

        onDockButtonActivated: function(sectionType, itemId) {
            logs.logEvent("onDockButtonActivated", ["sectionType", "itemId"], arguments)
        }
        onItemActivated: function(sectionType, itemId) {
            logs.logEvent("onItemActivated", ["sectionType", "itemId"], arguments)
        }
        onItemPinRequested: function(sectionType, itemId, pin) {
            logs.logEvent("onItemPinRequested", ["sectionType", "itemId", "pin"], arguments)
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 150
        SplitView.preferredHeight: 150
        SplitView.fillWidth: true

        logsView.logText: logs.logText

        ColumnLayout {
            Switch {
                id: ctrlNewIcons
                text: "Use new dock icons"
                checked: true
            }
            RowLayout {
                Switch {
                    id: ctrlHasNotifications
                    text: "Has unseen notifications"
                }
                Label { text: "  Count:" }
                SpinBox {
                    id: ctrlNotificationsCount
                    from: 0
                    to: 100
                    value: 0
                    enabled: ctrlHasNotifications.checked
                }
            }
        }
    }
}

// category: Sections
// status: good
// https://www.figma.com/design/uXJKlC0LaUjvwL5MEsI9v4/Shell----Desktop?node-id=251-357756&m=dev
