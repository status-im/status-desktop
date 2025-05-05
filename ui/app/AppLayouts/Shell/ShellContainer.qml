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

    required property ShellAdaptor shellAdaptor
    required property ProfileStores.ProfileStore profileStore

    property bool useNewDockIcons: true

    required property bool hasUnseenACNotifications
    required property int aCNotificationCount

    property var getLinkToProfileFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }
    property var getEmojiHashFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }

    readonly property string searchPhrase: searchField.text

    signal dockButtonActivated(int sectionType, string itemId)
    signal itemActivated(int sectionType, string itemId)
    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)

    signal notificationButtonClicked()
    signal setCurrentUserStatusRequested(int status)

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
            model: root.shellAdaptor.shellEntriesModel

            width: parent.width
            leftMargin: root.width * .1
            rightMargin: root.width * .1
            anchors.top: searchField.bottom
            anchors.topMargin: Theme.bigPadding
            anchors.bottom: shellDock.top
            anchors.bottomMargin: Theme.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter

            onItemActivated: function(sectionType, itemId) {
                root.itemActivated(sectionType, itemId)
            }
            onItemPinRequested: function(key, pin) {
                root.itemPinRequested(key, pin)
            }
            onDappDisconnectRequested: function(dappUrl) {
                root.dappDisconnectRequested(dappUrl)
            }
        }

        ShellDock {
            id: shellDock
            width: Math.min(implicitWidth, parent.width - root.bottomPadding * 2)
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            useNewDockIcons: root.useNewDockIcons
            sectionsModel: root.shellAdaptor.sectionsModel
            pinnedModel: root.shellAdaptor.pinnedModel
            onItemActivated: function(sectionType, itemId) {
                console.info("!!! DOCK BUTTON CLICKED:", itemId, "-> section:", sectionType)
                root.dockButtonActivated(sectionType, itemId)
            }
            onItemPinRequested: function(key, pin) {
                root.itemPinRequested(key, pin)
            }
            onDappDisconnectRequested: function(dappUrl) {
                root.dappDisconnectRequested(dappUrl)
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
            identicon.asset.color: Utils.colorForColorId(root.profileStore.colorId)
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
                emojiHash: root.getEmojiHashFn(pubKey)
                colorHash: root.profileStore.colorHash
                colorId: root.profileStore.colorId
                name: root.profileStore.name
                headerIcon: root.profileStore.icon
                isEnsVerified: !!root.profileStore.preferredName

                currentUserStatus: root.profileStore.currentUserStatus

                onViewProfileRequested: Global.openProfilePopup(pubKey)
                onCopyLinkRequested: ClipboardUtils.setText(root.getLinkToProfileFn(pubKey))
                onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
            }
        }
    }
}
