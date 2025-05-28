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

    ListModel {
        id: chatsModel
        ListElement {
            itemId: "id0"
            categoryId: "id0"
            active: false
            notificationsCount: 0
            hasUnreadMessages: false
            name: "Category X"
            emoji: ""
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
            emoji: ""
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
            emoji: ""
            icon: ""
            isCategory: true
            categoryOpened: false
            muted: false
        }
        ListElement {
            itemId: "id3"
            categoryId: "id2"
            type: StatusChatListItem.Type.CommunityChat
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
            type: StatusChatListItem.Type.GroupChat
            categoryId: "id2"
            name: "Channel Y_3"
            active: false
            notificationsCount: 1
            hasUnreadMessages: false
            color: ""
            colorId: 4
            emoji: ""
            icon: "https://assets.coingecko.com/coins/images/17139/standard/10631.png"
            muted: false
            isCategory: false
            categoryOpened: true
        }
    }

    ListModel {
        id: dappsModel
        ListElement {
            name: "Test dApp 2"
            url: "https://dapp.test/2"
            iconUrl: ""
            connectorBadge: "https://raw.githubusercontent.com/WalletConnect/walletconnect-assets/refs/heads/master/Icon/Blue%20(Default)/Icon.svg"
        }
        ListElement {
            name: ""
            url: "https://dapp.test/3"
            iconUrl: ""
            connectorBadge: ""
        }
        ListElement {
            name: "Test dApp 4 - very long name !!!!!!!!!!!!!!!!"
            url: "https://dapp.test/4"
            iconUrl: "https://react-app.walletconnect.com/assets/eip155-10.png"
            connectorBadge: "https://raw.githubusercontent.com/WalletConnect/walletconnect-assets/refs/heads/master/Icon/Blue%20(Default)/Icon.svg"
        }
        ListElement {
            name: "Test dApp 5 - very long url"
            url: "https://dapp.test/very_long/url/unusual"
            iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            connectorBadge: ""
        }
    }

    ShellContainer {
        id: shell
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        shellAdaptor: ShellAdaptor {
            id: shellAdaptor

            sectionsBaseModel: SectionsModel {}
            chatsBaseModel: chatsModel
            walletsBaseModel: WalletAccountsModel {}
            dappsBaseModel: dappsModel

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
            readonly property var colorHash: [{colorId: 0, segmentLength: 1}, {colorId: 4, segmentLength: 2}]
            property int currentUserStatus: Constants.currentUserStatus.automatic
        }

        getEmojiHashFn: function(pubKey) { // <- root.utilsStore.getEmojiHash(pubKey)
            if (pubKey === "")
                return ""

            return JSON.stringify(
                        ["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻",
                         "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
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
            logs.logEvent("onNotificationButtonClicked")
        }
        onSetCurrentUserStatusRequested: function (status) {
            profileStore.currentUserStatus = status
            logs.logEvent("onSetCurrentUserStatusRequested", ["status"], arguments) // <- root.rootStore.setCurrentUserStatus(status)
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
