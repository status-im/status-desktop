import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
        // Need to use Qt.callLater to ensure the focus is set after the component is fully loaded
        Qt.callLater(() => searchField.forceActiveFocus())
    }

    Component.onCompleted: focusSearch()

    Keys.onEscapePressed: {
        searchField.clear()
        focusSearch()
    }

    QtObject {
        id: d
        readonly property int narrowViewThreshold: 660
        readonly property bool isNarrowView: root.width < root.height
    }

    background: MouseArea { // eat every event behind the control
        hoverEnabled: true
        onPressed: (event) => event.accepted = true
        onWheel: (wheel) => wheel.accepted = true

        Rectangle {
            anchors.fill: parent
            color: Theme.palette.baseColor3
        }
    }

    contentItem: ColumnLayout {
        spacing: root.spacing

        ShellSearchField {
            Layout.maximumWidth: parent.width
            Layout.alignment: Qt.AlignHCenter

            id: searchField
            objectName: "shellSearchField"

            font.pixelSize: d.isNarrowView ? 23 : 27

            placeholderText: qsTr("Jump to a community, chat, account or a dApp...")
        }

        ShellGrid {
            Layout.fillWidth: true
            Layout.rightMargin: -root.horizontalPadding
            Layout.fillHeight: true

            objectName: "shellGrid"

            model: root.shellEntriesModel

            delegateWidth: d.isNarrowView ? 140 : 160
            spacing: d.isNarrowView ? 10 : Theme.padding

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
            usesDefaultName: root.profileStore.usesDefaultName

            getEmojiHashFn: root.getEmojiHashFn
            getLinkToProfileFn: root.getLinkToProfileFn

            onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
            onViewProfileRequested: (pubKey) => root.viewProfileRequested(pubKey)
        }
    }
}
