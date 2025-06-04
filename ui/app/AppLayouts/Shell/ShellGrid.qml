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

    /**
      Expected model structure:

      Common data:
        key                 [string] - unique identifier of a section across all models, e.g "1;0x3234235"
        id                  [string] - id of this section
        sectionType         [int]    - type of this section (Constants.appSection.*)
        name                [string] - section's name, e.g. "Chat" or "Wallet" or a community name
        icon                [string] - section's icon (url like or blob)
        color               [color]  - the section's color
        banner              [string] - the section's banner image (url like or blob), mostly empty for non-communities
        hasNotification     [bool]   - whether the section has any notification (w/o denoting the number)
        notificationsCount  [int]    - number of notifications, if any
        enabled             [bool]   - whether the section should show in the UI

      Communities:
        members             [int]   - number of members
        activeMembers       [int]   - number of active members
        pending             [bool]  - whether a request to join/spectate is in effect
        banned              [bool]  - whether we are kicked/banned from this community

      Chats:
        chatType            [int]   - type of the chat (Constants.chatType.*)
        onlineStatus        [int]   - online status of the contact (Constants.onlineStatus.*)

      Wallets:
        walletType          [string] - type of the wallet (Constants.*WalletType)
        currencyBalance     [string] - user formatted balance of the wallet in fiat (e.g. "1 000,23 CZK")

      Dapps:
        connectorBadge      [string] - decoration image for the connector used

      Settings:
        isExperimental      [bool]   - whether the section is experimental (shows the Beta badge)

      Writable layer:
        pinned             [bool]   - whether the item is pinned in the UI
        timestamp          [int]    - timestamp of the last user interaction with the item
    **/
    
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
