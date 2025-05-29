import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1

import Models 1.0
import Storybook 1.0

import utils 1.0

import AppLayouts.Shell 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    ShellContainer {
        id: shell
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        shellAdaptor: ShellAdaptor {
            id: shellAdaptor

            sectionsBaseModel: SectionsModel {}
            chatsBaseModel: ChatsModel {}
            walletsBaseModel: WalletAccountsModel {}
            dappsBaseModel: DappsModel {}

            showCommunities: ctrlShowCommunities.checked || ctrlShowAllEntries.checked
            showSettings: ctrlShowSettings.checked || ctrlShowAllEntries.checked
            showChats: ctrlShowChats.checked || ctrlShowAllEntries.checked
            showWallets: ctrlShowWallets.checked || ctrlShowAllEntries.checked
            showDapps: ctrlShowDapps.checked || ctrlShowAllEntries.checked

            showEnabledSectionsOnly: ctrlShowEnabledSectionsOnly.checked
            marketEnabled: ctrlMarketEnabled.checked

            syncingBadgeCount: 2
            messagingBadgeCount: 4
            showBackUpSeed: true

            searchPhrase: shell.searchPhrase

            profileId: profileStore.pubkey
        }

        profileStore: ProfileStores.ProfileStore {
            id: profileStore
            readonly property string pubkey: "0xdeadbeef"
            readonly property string compressedPubKey: "zxDeadBeef"
            readonly property string name: "John Roe"
            readonly property string icon: ModelsData.icons.rarible
            readonly property int colorId: 7
            readonly property var colorHash: [{colorId: 7, segmentLength: 1}, {colorId: 6, segmentLength: 2}]
            property int currentUserStatus: Constants.currentUserStatus.automatic
        }

        getEmojiHashFn: function(pubKey) { // <- root.utilsStore.getEmojiHash(pubKey)
            if (pubKey === "")
                return ""

            return["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"]
        }
        getLinkToProfileFn: function(pubKey) { // <- root.rootStore.contactStore.getLinkToProfile(pubKey)
            return Constants.userLinkPrefix + pubKey
        }

        useNewDockIcons: ctrlNewIcons.checked
        hasUnseenACNotifications: ctrlHasNotifications.checked
        aCNotificationCount: ctrlNotificationsCount.value

        onItemActivated: function(sectionType, itemId) {
            logs.logEvent("onItemActivated", ["sectionType", "itemId"], arguments)
            console.info("!!! ITEM ACTIVATED; sectionType:", sectionType, "; itemId:", itemId)
        }
        onItemPinRequested: function(key, pin) {
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
                checked: true
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
                onClicked: shellAdaptor.clear()
            }
        }
    }
}

// category: Sections
// status: good
// https://www.figma.com/design/uXJKlC0LaUjvwL5MEsI9v4/Shell----Desktop?node-id=251-357756&m=dev
