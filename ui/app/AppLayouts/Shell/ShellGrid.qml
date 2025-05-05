import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import AppLayouts.Shell.delegates 1.0

import utils 1.0

StatusGridView {
    id: root
    
    required property var sourceModel

    property string searchPhrase

    property int cellSize: 160
    property int cellPadding: Theme.padding

    signal itemActivated(int sectionType, string itemId)
    signal itemPinRequested(int sectionType, string itemId, bool pin)
    
    cellWidth: cellSize + cellPadding
    cellHeight: cellWidth
    
    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }
    
    model: SortFilterProxyModel {
        sourceModel: root.sourceModel
        filters: [
            SearchFilter {
                roleName: "name"
                searchPhrase: root.searchPhrase
            }
        ]
        sorters: [ // TODO sort on recency/pinned/favorite criteria
            StringSorter {
                roleName: "name"
            }
        ]
    }
    
    delegate: Loader {
        required property int index
        required property var model

        sourceComponent: {
            switch (parseInt(model.sectionType)) {
            case Constants.appSection.profile:
                return settingsDelegate
            case Constants.appSection.community:
                return communityDelegate
            case Constants.appSection.wallet:
                return walletDelegate
            case Constants.appSection.chat:
                return chatDelegate
            default:
                console.warn("Unhandled ShellGridItem delegate for sectionType:", model.sectionType)
            }
        }

        Connections {
            target: item ?? null
            function onClicked() {
                root.itemActivated(item.sectionType, item.itemId)
            }
            function onPinRequested() {
                root.itemPinRequested(item.sectionType, item.itemId, !item.pinned)
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

            membersCount: model.members
            activeMembersCount: model.activeMembers
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

            chatType: model.chatType
            onlineStatus: model.onlineStatus
        }
    }
    
    // TODO tune the transitions/animations
    displaced: Transition {
        NumberAnimation { properties: "x,y" }
    }
    add: Transition {
        NumberAnimation { properties: "x,y"; from: 0 }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; to: 0 }
            NumberAnimation { properties: "x,y"; to: 0 }
        }
    }
    populate: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1 }
    }
}
