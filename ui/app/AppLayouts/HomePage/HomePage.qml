import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

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

    property var getLinkToProfileFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }
    property var getEmojiHashFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }

    readonly property string searchPhrase: searchField.text

    signal itemActivated(string key, int sectionType, string itemId)
    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)

    signal setCurrentUserStatusRequested(int status)
    signal viewProfileRequested(string pubKey)

    topPadding: Theme.defaultBigPadding * 2
    bottomPadding: Theme.smallPadding * 2
    horizontalPadding: Theme.defaultSmallPadding * 2

    spacing: Theme.defaultBigPadding

    function focusSearch(force = false) {
        if (SQUtils.Utils.isMobile && !force) {
            return
        }
        // Need to use Qt.callLater to ensure the focus is set after the component is fully loaded
        Qt.callLater(() => searchField.forceActiveFocus())
    }

    Component.onCompleted: {
        focusSearch()
    }

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

        Rectangle {
            Layout.maximumWidth: parent.width
            Layout.preferredWidth: Math.max(searchField.implicitWidth, placeholderText.implicitWidth)
            Layout.preferredHeight: searchField.implicitHeight
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.baseColor3
            radius: Theme.defaultSmallPadding * 2
            z: grid.z + 1 // to make sure it's on top of the grid

            HomePageSearchField {
                id: searchField
                objectName: "homeSearchField"
                anchors.fill: parent

                font.pixelSize: d.isNarrowView ? Theme.fontSize(23) : Theme.fontSize(27)

                StatusBaseText {
                    id: placeholderText
                    anchors.fill: parent
                    text: qsTr("Jump to a community, chat, account or a dApp...")
                    font.pixelSize: searchField.font.pixelSize
                    fontSizeMode: Text.Fit
                    color: Theme.palette.baseColor1
                    verticalAlignment: Text.AlignVCenter
                    visible: searchField.text.length === 0
                }
            }
        }

        HomePageGrid {
            id: grid
            Layout.fillWidth: true
            Layout.rightMargin: -root.horizontalPadding
            Layout.fillHeight: true

            objectName: "homeGrid"

            model: root.homePageEntriesModel

            delegateWidth: 160
            spacing: d.isNarrowView ? 10 : Theme.defaultPadding

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
        anchors.rightMargin: Theme.defaultPadding
        anchors.top: parent.top
        anchors.topMargin: Theme.defaultSmallPadding
        spacing: 12

        // TODO remove me, duplicate in PrimaryNavSidebar
        ProfileButton {
            objectName: "homeProfileButton"
            name: root.profileStore.name
            pubKey: root.profileStore.pubKey
            compressedPubKey: root.profileStore.compressedPubKey
            iconSource: root.profileStore.icon
            colorId: root.profileStore.colorId
            currentUserStatus: root.profileStore.currentUserStatus
            usesDefaultName: root.profileStore.usesDefaultName

            getEmojiHashFn: root.getEmojiHashFn
            getLinkToProfileFn: root.getLinkToProfileFn

            onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
            onViewProfileRequested: (pubKey) => root.viewProfileRequested(pubKey)
        }
    }
}
