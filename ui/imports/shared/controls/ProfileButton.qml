import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.stores 1.0 as ProfileStores

import shared.popups 1.0

import utils 1.0

StatusNavBarTabButton {
    id: root

    required property ProfileStores.ProfileStore profileStore

    property var getLinkToProfileFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }
    property var getEmojiHashFn: function(pubkey) { console.error("IMPLEMENT ME"); return "" }

    property bool opened: false

    signal viewProfileRequested(string pubKey)
    signal setCurrentUserStatusRequested(int status)

    name: root.profileStore.name
    icon.source: root.profileStore.icon
    implicitWidth: 32
    implicitHeight: 32
    identicon.asset.width: width
    identicon.asset.height: height
    identicon.asset.useAcronymForLetterIdenticon: true
    identicon.asset.color: Utils.colorForPubkey(root.profileStore.pubkey)
    identicon.ringSettings.ringSpecModel: root.profileStore.colorHash

    badge.visible: true
    badge.anchors {
        left: undefined
        top: undefined
        right: root.right
        bottom: root.bottom
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

    onClicked: userStatusContextMenu.opened ? userStatusContextMenu.close() : userStatusContextMenu.open()

    UserStatusContextMenu {
        id: userStatusContextMenu

        readonly property string pubKey: root.profileStore.pubkey

        y: root.y - userStatusContextMenu.height + root.height
        x: root.x + root.width + 5

        compressedPubKey: root.profileStore.compressedPubKey
        emojiHash: root.getEmojiHashFn(pubKey)
        colorHash: root.profileStore.colorHash
        colorId: root.profileStore.colorId
        name: root.profileStore.name
        headerIcon: root.profileStore.icon
        isEnsVerified: !!root.profileStore.preferredName

        currentUserStatus: root.profileStore.currentUserStatus

        onViewProfileRequested: root.viewProfileRequested(pubKey)
        onCopyLinkRequested: ClipboardUtils.setText(root.getLinkToProfileFn(pubKey))
        onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
    }
}
