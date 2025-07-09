import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Backpressure 0.1

import AppLayouts.HomePage.delegates 1.0

import utils 1.0

StatusScrollView {
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
    property alias model: repeater.model

    property int delegateWidth: 160
    Behavior on delegateWidth {
        PropertyAnimation { duration: Theme.AnimationDuration.Fast }
    }
    property int delegateHeight: 160
    Behavior on delegateHeight {
        PropertyAnimation { duration: Theme.AnimationDuration.Fast }
    }

    signal itemActivated(string key, int sectionType, string itemId)
    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)

    padding: 0
    rightPadding: Theme.padding

    contentWidth: availableWidth

    QtObject {
        id: d
        property bool positioningComplete // delay the animations
    }

    ColumnLayout {
        width: root.availableWidth

        Flow {
            // calculate a tight bounding box, and then horizontally center over the scrollview width
            readonly property int delegateCountPerRow: Math.trunc(parent.width / (root.delegateWidth + spacing))
            Layout.preferredWidth: (delegateCountPerRow * root.delegateWidth) + (spacing * (delegateCountPerRow - 1))
            Layout.alignment: Qt.AlignHCenter

            spacing: Theme.padding

            // for the drop shadow
            topPadding: Theme.smallPadding
            bottomPadding: Theme.padding

            // delay the animations
            onPositioningComplete: Backpressure.debounce(this, 500, () => {d.positioningComplete = true})()

            Repeater {
                id: repeater
                delegate: Loader {
                    required property int index
                    required property var model

                    objectName: "homeGridItemLoader_" + model.key

                    sourceComponent: {
                        switch (model.sectionType) {
                        case Constants.appSection.profile:
                            return settingsDelegate
                        case Constants.appSection.community:
                            return communityDelegate
                        case Constants.appSection.wallet:
                            return walletDelegate
                        case Constants.appSection.chat:
                        case -1: // search
                            return chatDelegate
                        case Constants.appSection.dApp:
                            return dappDelegate
                        default:
                            console.warn("Unhandled HomePageGridItem delegate for sectionType:", model.sectionType)
                        }
                    }

                    Connections {
                        target: item ?? null
                        function onClicked() {
                            root.itemActivated(model.key, model.sectionType, item.itemId)
                        }
                        function onPinRequested() {
                            root.itemPinRequested(model.key, !model.pinned)
                        }
                    }
                }
            }

            Component {
                id: communityDelegate

                HomePageGridCommunityItem {
                    width: root.delegateWidth
                    height: root.delegateHeight
                    itemId: model.id
                    title: model.name
                    color: model.color
                    icon.source: model.icon
                    banner: model.banner ?? ""
                    hasNotification: model.hasNotification
                    notificationsCount: model.notificationsCount
                    pinned: model.pinned

                    membersCount: model.members ?? 0
                    activeMembersCount: model.activeMembers ?? 0

                    pending: model.pending ?? false
                    banned: model.banned ?? false
                }
            }

            Component {
                id: settingsDelegate

                HomePageGridSettingsItem {
                    width: root.delegateWidth
                    height: root.delegateHeight
                    itemId: model.id
                    title: model.name
                    icon.name: model.icon
                    hasNotification: model.hasNotification
                    notificationsCount: model.notificationsCount
                    pinned: model.pinned

                    isExperimental: model.isExperimental ?? false
                }
            }

            Component {
                id: walletDelegate

                HomePageGridWalletItem {
                    width: root.delegateWidth
                    height: root.delegateHeight
                    itemId: model.id
                    title: model.name
                    icon.name: model.icon
                    icon.color: model.color
                    hasNotification: model.hasNotification
                    notificationsCount: model.notificationsCount
                    pinned: model.pinned

                    currencyBalance: model.currencyBalance ?? ""
                    walletType: model.walletType ?? ""
                }
            }

            Component {
                id: chatDelegate

                HomePageGridChatItem {
                    width: root.delegateWidth
                    height: root.delegateHeight
                    itemId: model.id
                    title: chatType === Constants.chatType.communityChat ? "#" + model.name : model.name
                    icon.name: model.icon
                    icon.color: model.color
                    hasNotification: model.hasNotification ?? false
                    notificationsCount: model.notificationsCount ?? 0
                    pinned: model.pinned
                    lastMessageText: {
                        if (!!model.lastMessageText)
                            return model.lastMessageText
                        if (model.sectionType === -1 && model.chatType === Constants.chatType.communityChat)
                            return model.sectionName
                        return ""
                    }

                    chatType: model.chatType ?? Constants.chatType.unknown
                    onlineStatus: model.onlineStatus ?? Constants.onlineStatus.unknown
                }
            }

            Component {
                id: dappDelegate

                HomePageGridDAppItem {
                    width: root.delegateWidth
                    height: root.delegateHeight
                    itemId: model.id
                    title: model.name
                    icon.name: model.icon
                    icon.color: model.color
                    pinned: model.pinned

                    connectorBadge: model.connectorBadge ?? ""

                    onDisconnectRequested: root.dappDisconnectRequested(itemId)
                }
            }

            move: Transition {
                enabled: d.positioningComplete
                NumberAnimation { properties: "x,y"; }
            }
            add: Transition {
                enabled: d.positioningComplete
                NumberAnimation { properties: "x,y"; from: 0; duration: Theme.AnimationDuration.Fast }
            }
        }
    }
}
