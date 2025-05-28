import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Shell.delegates 1.0

import utils 1.0

StatusGridView {
    id: root
    
    property int cellSize: 160
    property int cellPadding: Theme.padding

    signal itemActivated(int sectionType, string itemId)
    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)
    
    cellWidth: cellSize + cellPadding
    cellHeight: cellWidth
    
    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }
    
    delegate: Loader {
        required property int index
        required property var model

        sourceComponent: {
            switch (model.sectionType) {
            case Constants.appSection.profile:
                return settingsDelegate
            case Constants.appSection.community:
                return communityDelegate
            case Constants.appSection.wallet:
                return walletDelegate
            case Constants.appSection.chat:
                return chatDelegate
            case Constants.appSection.dApp:
                return dappDelegate
            default:
                console.warn("Unhandled ShellGridItem delegate for sectionType:", model.sectionType)
            }
        }

        Connections {
            target: item ?? null
            function onClicked() {
                root.itemActivated(item.sectionType, item.itemId)
                model.timestamp = new Date().valueOf()
            }
            function onPinRequested() {
                model.pinned = !model.pinned
                if (model.pinned)
                    model.timestamp = new Date().valueOf()
                root.itemPinRequested(model.key, model.pinned)
            }
        }
    }

    Component {
        id: communityDelegate
        ShellGridCommunityItem {
            width: root.cellSize
            height: root.cellSize
            itemId: model.id
            title: model.name
            color: model.color
            icon.source: model.icon
            banner: model.banner
            hasNotification: model.hasNotification
            notificationsCount: model.notificationsCount
            pinned: model.pinned

            membersCount: model.members
            activeMembersCount: model.activeMembers

            pending: model.pending
            banned: model.banned
        }
    }

    Component {
        id: settingsDelegate
        ShellGridSettingsItem {
            width: root.cellSize
            height: root.cellSize
            itemId: model.id
            title: model.name
            icon.name: model.icon
            hasNotification: model.hasNotification
            notificationsCount: model.notificationsCount
            pinned: model.pinned

            isExperimental: model.isExperimental
        }
    }

    Component {
        id: walletDelegate
        ShellGridWalletItem {
            width: root.cellSize
            height: root.cellSize
            itemId: model.id
            title: model.name
            icon.name: model.icon
            icon.color: model.color
            hasNotification: model.hasNotification
            notificationsCount: model.notificationsCount
            pinned: model.pinned

            currencyBalance: model.currencyBalance
            walletType: model.walletType
        }
    }

    Component {
        id: chatDelegate
        ShellGridChatItem {
            width: root.cellSize
            height: root.cellSize
            itemId: model.id
            title: model.name
            icon.name: model.icon
            icon.color: model.color
            hasNotification: model.hasNotification
            notificationsCount: model.notificationsCount
            pinned: model.pinned

            chatType: model.chatType
            onlineStatus: model.onlineStatus
        }
    }

    Component {
        id: dappDelegate
        ShellGridDAppItem {
            width: root.cellSize
            height: root.cellSize
            itemId: model.id
            title: model.name
            icon.name: model.icon
            icon.color: model.color
            pinned: model.pinned

            connectorBadge: model.connectorBadge

            onDisconnectRequested: root.dappDisconnectRequested(itemId)
        }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; }
    }
    add: Transition {
        NumberAnimation { properties: "x,y"; from: 0; duration: Theme.AnimationDuration.Fast }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; to: 0; duration: Theme.AnimationDuration.Fast }
            NumberAnimation { properties: "x,y"; to: 0; duration: Theme.AnimationDuration.Fast }
        }
    }
}
