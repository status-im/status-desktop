import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.stores 1.0 as ProfileStores

import shared.popups 1.0
import shared.controls 1.0

import utils 1.0

Control {
    id: root

    // grid (see ShellAdaptor for docu)
    required property var shellEntriesModel

    // dock (see ShellAdaptor for docu)
    required property var sectionsModel
    required property var pinnedModel

    required property ProfileStores.ProfileStore profileStore

    property bool useNewDockIcons: true

    required property bool hasUnseenACNotifications
    required property int aCNotificationCount

    property var getLinkToProfileFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }
    property var getEmojiHashFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }

    readonly property string searchPhrase: searchField.text

    signal itemActivated(string key, int sectionType, string itemId)
    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)

    signal notificationButtonClicked()
    signal setCurrentUserStatusRequested(int status)
    signal viewProfileRequested(string pubKey)

    topPadding: Theme.bigPadding * 2
    bottomPadding: Theme.smallPadding * 2
    horizontalPadding: Theme.smallPadding * 2

    spacing: Theme.bigPadding

    function focusSearch() {
        searchField.forceActiveFocus()
    }

    Component.onCompleted: focusSearch()

    Keys.onEscapePressed: {
        searchField.clear()
        focusSearch()
    }

    QtObject {
        id: d
        readonly property int narrowViewThreshold: 660
        readonly property bool isNarrowView: root.availableWidth < d.narrowViewThreshold ||
                                             root.Screen.primaryOrientation === Qt.PortraitOrientation ||
                                             root.Screen.primaryOrientation === Qt.InvertedPortraitOrientation
    }

    background: MouseArea { // eat every event behind the control
        hoverEnabled: true
        onPressed: (event) => event.accepted = true
        onWheel: (wheel) => wheel.accepted = true

        Rectangle {
            anchors.fill: parent
            color: "#0b121d"
        }
    }

    contentItem: ColumnLayout {
        spacing: root.spacing

        ShellSearchField {
            Layout.fillWidth: true

            id: searchField

            objectName: "shellSearchField"
            leftPadding: d.isNarrowView ? 0 : root.width * .1
            rightPadding: d.isNarrowView ? 0 : root.width * .1
            placeholderText: qsTr("Jump to a community, chat, account or a dApp...")
        }

        ShellGrid {
            Layout.fillWidth: !d.isNarrowView
            Layout.preferredWidth: d.isNarrowView ? (3*cellSize) + (3*cellPadding) : implicitWidth
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true

            objectName: "shellGrid"

            model: root.shellEntriesModel

            leftMargin: d.isNarrowView ? 0 : root.width * .1
            rightMargin: d.isNarrowView ? 0 : root.width * .1

            onItemActivated: function(key, sectionType, itemId) {
                root.itemActivated(key, sectionType, itemId)
            }
            onItemPinRequested: function(key, pin) {
                root.itemPinRequested(key, pin)
            }
            onDappDisconnectRequested: function(dappUrl) {
                root.dappDisconnectRequested(dappUrl)
            }
        }

        ShellDock {
            Layout.alignment: d.isNarrowView && root.availableWidth < implicitWidth ? 0 : Qt.AlignHCenter
            Layout.fillWidth: d.isNarrowView && root.availableWidth < implicitWidth
            Layout.maximumWidth: parent.width

            objectName: "shellDock"

            useNewDockIcons: root.useNewDockIcons
            sectionsModel: root.sectionsModel
            pinnedModel: root.pinnedModel

            onItemActivated: function(key, sectionType, itemId) {
                root.itemActivated(key, sectionType, itemId)
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
            Layout.topMargin: 4
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

        ProfileButton {
            name: root.profileStore.name
            pubKey: root.profileStore.pubkey
            compressedPubKey: root.profileStore.compressedPubKey
            isEnsVerified: !!root.profileStore.preferredName
            iconSource: root.profileStore.icon
            colorId: root.profileStore.colorId
            colorHash: root.profileStore.colorHash
            currentUserStatus: root.profileStore.currentUserStatus

            getEmojiHashFn: root.getEmojiHashFn
            getLinkToProfileFn: root.getLinkToProfileFn

            badge.border.color: hovered ? "#222833" : "#161c27"

            onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
            onViewProfileRequested: (pubKey) => root.viewProfileRequested(pubKey)
        }
    }
}
