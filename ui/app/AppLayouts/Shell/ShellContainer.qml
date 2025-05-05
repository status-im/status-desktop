import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.stores 1.0 as ProfileStores

import utils 1.0
import shared.popups 1.0

Control {
    id: root

    required property var model
    required property var sectionsModel
    required property ProfileStores.ProfileStore profileStore

    property bool useNewDockIcons: true

    property bool hasUnseenACNotifications
    property int aCNotificationCount

    signal dockButtonActivated(int sectionType, string itemId)
    signal itemActivated(int sectionType, string itemId)
    signal itemPinRequested(int sectionType, string itemId, bool pin)

    signal notificationButtonClicked()

    topPadding: Theme.bigPadding * 2
    bottomPadding: Theme.smallPadding * 2

    Component.onCompleted: searchField.forceActiveFocus()

    Keys.onEscapePressed: {
        searchField.clear()
        searchField.forceActiveFocus()
    }

    background: Rectangle {
        color: "#0b121d"
    }

    contentItem: Item {
        ShellSearchField {
            id: searchField
            width: parent.width
            leftPadding: root.width * .1
            rightPadding: root.width * .1
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Jump to a community, chat, account or a dApp...")
        }

        ShellGrid {
            id: shellGrid
            sourceModel: root.model

            //width: 5*cellSize + 5*Theme.padding // fixed 5 columns ???
            width: parent.width
            leftMargin: root.width * .1
            rightMargin: root.width * .1
            anchors.top: searchField.bottom
            anchors.topMargin: Theme.bigPadding
            anchors.bottom: shellDock.top
            anchors.bottomMargin: Theme.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter
            searchPhrase: searchField.text

            onItemActivated: function(sectionType, itemId) {
                console.info("!!! ITEM ACTIVATED:", itemId, "-> section:", sectionType)
                root.itemActivated(sectionType, itemId)
            }
            onItemPinRequested: function(sectionType, itemId, pin) {
                console.info("!!! ITEM PIN REQUESTED:", itemId, "-> section:", sectionType)
                root.itemPinRequested(sectionType, itemId, pin)
            }
        }

        ShellDock {
            id: shellDock
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            useNewDockIcons: root.useNewDockIcons
            sectionsModel: root.sectionsModel
            // TODO allow for pinned items
            onItemActivated: function(sectionType, itemId) {
                console.info("!!! DOCK BUTTON CLICKED:", itemId, "-> section:", sectionType)
                root.dockButtonActivated(sectionType, itemId)
            }
        }
    }

    // top right action buttons
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        spacing: 12

        StatusActivityCenterButton {
            Layout.topMargin: 6
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            icon.height: 24
            icon.color: hovered ? Theme.palette.white : Theme.palette.baseColor1
            Behavior on icon.color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
            color: "transparent"
            tooltip.color: "#222833"
            unreadNotificationsCount: root.aCNotificationCount
            hasUnseenNotifications: root.hasUnseenACNotifications
            onClicked: root.notificationButtonClicked()
        }

        // TODO make a separate/shared component
        StatusNavBarTabButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            id: profileButton

            name: root.profileStore.name
            icon.source: root.profileStore.icon
            identicon.asset.width: width
            identicon.asset.height: height
            identicon.asset.useAcronymForLetterIdenticon: true
            identicon.asset.color: Utils.colorForPubkey(root.profileStore.pubkey)
            identicon.ringSettings.ringSpecModel: root.profileStore.colorHash

            badge.visible: true
            badge.anchors {
                left: undefined
                top: undefined
                right: profileButton.right
                bottom: profileButton.bottom
                margins: 0
                rightMargin: -badge.border.width
                bottomMargin: -badge.border.width
            }
            badge.implicitHeight: 12
            badge.implicitWidth: 12
            badge.color: {
                switch(root.profileStore.currentUserStatus) {
                case Constants.currentUserStatus.automatic:
                case Constants.currentUserStatus.alwaysOnline:
                    return Theme.palette.successColor1
                default:
                    return Theme.palette.baseColor1
                }
            }
            badge.border.color: hovered ? "#222833" : "#161c27"

            onClicked: userStatusContextMenu.popup()

            UserStatusContextMenu {
                id: userStatusContextMenu

                readonly property string pubKey: root.profileStore.pubkey

                compressedPubKey: root.profileStore.compressedPubKey
                emojiHash: root.utilsStore.getEmojiHash(pubKey) // FIXME utilsStore
                colorHash: root.profileStore.colorHash
                colorId: root.profileStore.colorId
                name: root.profileStore.name
                headerIcon: root.profileStore.icon
                isEnsVerified: !!root.profileStore.preferredName

                currentUserStatus: root.profileStore.currentUserStatus

                onViewProfileRequested: Global.openProfilePopup(pubKey)
                onCopyLinkRequested: ClipboardUtils.setText(root.rootStore.contactStore.getLinkToProfile(pubKey)) // FIXME contactStore
                onSetCurrentUserStatusRequested: root.rootStore.setCurrentUserStatus(status)
            }
        }
    }
}
