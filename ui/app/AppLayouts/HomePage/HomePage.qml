import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Profile.stores as ProfileStores

import shared.popups
import shared.controls

import utils

Control {
    id: root

    // grid (see HomePageAdaptor for docu)
    required property var homePageEntriesModel

    // dock (see HomePageAdaptor for docu)
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

        HomePageSearchField {
            Layout.maximumWidth: parent.width
            Layout.alignment: Qt.AlignHCenter

            id: searchField
            objectName: "homeSearchField"

            font.pixelSize: d.isNarrowView ? 23 : 27

            placeholderText: qsTr("Jump to a community, chat, account or a dApp...")
        }

        HomePageGrid {
            Layout.fillWidth: true
            Layout.rightMargin: -root.horizontalPadding
            Layout.fillHeight: true

            objectName: "homeGrid"

            model: root.homePageEntriesModel

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

        HomePageDock {
            Layout.alignment: d.isNarrowView && root.availableWidth < implicitWidth ? 0 : Qt.AlignHCenter
            Layout.fillWidth: d.isNarrowView && root.availableWidth < implicitWidth
            Layout.maximumWidth: parent.width

            objectName: "homeDock"

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
            objectName: "homeACButton"
            Layout.topMargin: 4
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            icon.height: 24
            unreadNotificationsCount: root.aCNotificationCount
            hasUnseenNotifications: root.hasUnseenACNotifications
            onClicked: root.notificationButtonClicked()
        }

        ProfileButton {
            objectName: "homeProfileButton"
            name: root.profileStore.name
            pubKey: root.profileStore.pubKey
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
