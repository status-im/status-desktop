import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Components

import Models
import Storybook

import utils

import AppLayouts.HomePage
import AppLayouts.Profile.stores as ProfileStores

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    HomePage {
        id: homePage
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        HomePageAdaptor {
            id: homePageAdaptor

            sectionsBaseModel: SectionsModel {}
            chatsBaseModel: ChatsModel {}
            chatsSearchBaseModel: ChatsSearchModel {}
            walletsBaseModel: WalletAccountsModel {}
            dappsBaseModel: DappsModel {}

            showCommunities: ctrlShowCommunities.checked || ctrlShowAllEntries.checked
            showSettings: ctrlShowSettings.checked || ctrlShowAllEntries.checked
            showChats: ctrlShowChats.checked || ctrlShowAllEntries.checked
            showAllChats: ctrlShowAllChats.checked || ctrlShowAllEntries.checked
            showWallets: ctrlShowWallets.checked || ctrlShowAllEntries.checked
            showDapps: ctrlShowDapps.checked || ctrlShowAllEntries.checked

            showEnabledSectionsOnly: ctrlShowEnabledSectionsOnly.checked
            marketEnabled: ctrlMarketEnabled.checked

            syncingBadgeCount: 2
            messagingBadgeCount: 4
            showBackUpSeed: true

            searchPhrase: homePage.searchPhrase

            profileId: profileStore.pubKey
        }

        homePageEntriesModel: homePageAdaptor.homePageEntriesModel
        sectionsModel: homePageAdaptor.sectionsModel
        pinnedModel: homePageAdaptor.pinnedModel

        profileStore: ProfileStores.ProfileStore {
            id: profileStore
            readonly property string pubKey: "0xdeadbeef"
            readonly property string compressedPubKey: "zxDeadBeef"
            readonly property string name: "John Roe"
            readonly property string icon: ModelsData.icons.rarible
            readonly property int colorId: 7
            readonly property var colorHash: [{colorId: 7, segmentLength: 1}, {colorId: 6, segmentLength: 2}]
            readonly property bool usesDefaultName: false
            property int currentUserStatus: Constants.currentUserStatus.automatic
        }

        getEmojiHashFn: function(pubKey) { // <- root.utilsStore.getEmojiHash(pubKey)
            if (pubKey === "")
                return ""

            return["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"]
        }
        getLinkToProfileFn: function(pubKey) { // <- root.rootStore.contactsStore.getLinkToProfile(pubKey)
            return Constants.userLinkPrefix + pubKey
        }

        useNewDockIcons: ctrlNewIcons.checked
        hasUnseenACNotifications: ctrlHasNotifications.checked
        aCNotificationCount: ctrlNotificationsCount.value

        onItemActivated: function(key, sectionType, itemId) {
            homePageAdaptor.setTimestamp(key, new Date().valueOf())
            logs.logEvent("onItemActivated", ["key", "sectionType", "itemId"], arguments)
            console.info("!!! ITEM ACTIVATED; key:", key, "; sectionType:", sectionType, "; itemId:", itemId)
        }
        onItemPinRequested: function(key, pin) {
            homePageAdaptor.setPinned(key, pin)
            if (pin)
                homePageAdaptor.setTimestamp(key, new Date().valueOf()) // update the timestamp so that the pinned dock items are sorted by their recency
            logs.logEvent("onItemPinRequested", ["key", "pin"], arguments)
            console.info("!!! ITEM", key, "PINNED:", pin)
        }
        onDappDisconnectRequested: function(dappUrl) {
            logs.logEvent("onDappDisconnectRequested", ["dappUrl"], arguments)
            console.info("!!! DAPP DISCONNECT:", dappUrl)
        }

        onNotificationButtonClicked: {
            logs.logEvent("onNotificationButtonClicked") // <- openActivityCenterPopup()
        }
        onSetCurrentUserStatusRequested: function (status) {
            profileStore.currentUserStatus = status
            logs.logEvent("onSetCurrentUserStatusRequested", ["status"], arguments) // <- root.rootStore.setCurrentUserStatus(status)
        }
        onViewProfileRequested: function(pubKey) {
            logs.logEvent("onViewProfileRequested", ["pubKey"], arguments) // <- Global.openProfilePopup(pubKey)
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 300
        SplitView.preferredHeight: 300
        SplitView.fillWidth: true

        logsView.logText: logs.logText

        ColumnLayout {
            Switch {
                id: ctrlNewIcons
                text: "Use new dock icons"
            }
            Switch {
                id: ctrlShowEnabledSectionsOnly
                text: "Show enabled sections only"
            }
            Switch {
                id: ctrlMarketEnabled
                text: "Market enabled"
                checked: true
            }
            RowLayout {
                Switch {
                    id: ctrlShowAllEntries
                    text: "Show all entries"
                    checked: true
                }
                Switch {
                    id: ctrlShowCommunities
                    text: "Show Communities"
                    checked: true
                    enabled: !ctrlShowAllEntries.checked
                }
                Switch {
                    id: ctrlShowChats
                    text: "Show Chats"
                    checked: true
                    enabled: !ctrlShowAllEntries.checked
                }
                Switch {
                    id: ctrlShowAllChats
                    text: "Show All Chats"
                    checked: true
                    enabled: ctrlShowChats.checked && !ctrlShowAllEntries.checked
                }
                Switch {
                    id: ctrlShowWallets
                    text: "Show Wallets"
                    checked: true
                    enabled: !ctrlShowAllEntries.checked
                }
                Switch {
                    id: ctrlShowSettings
                    text: "Show Settings"
                    checked: true
                    enabled: !ctrlShowAllEntries.checked
                }
                Switch {
                    id: ctrlShowDapps
                    text: "Show dApps"
                    checked: true
                    enabled: !ctrlShowAllEntries.checked
                }
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
            Button {
                text: "Reset"
                onClicked: homePageAdaptor.clear()
            }
        }
    }
}

// category: Sections
// status: good
// https://www.figma.com/design/uXJKlC0LaUjvwL5MEsI9v4/Shell----Desktop?node-id=251-357756&m=dev
