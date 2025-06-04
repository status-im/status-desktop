import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.popups 1.0

import utils 1.0

StatusNavBarTabButton {
    id: root

    required property string name
    required property string pubKey
    required property string compressedPubKey
    required property bool isEnsVerified
    required property string iconSource
    required property int colorId
    required property var colorHash
    required property int currentUserStatus

    property var getLinkToProfileFn: function(pubKey) { console.error("IMPLEMENT ME"); return "" }
    property var getEmojiHashFn: function(pubKey) { console.error("IMPLEMENT ME"); return "" }

    property bool opened: false

    signal viewProfileRequested(string pubKey)
    signal setCurrentUserStatusRequested(int status)

    name: root.name
    icon.source: root.iconSource
    implicitWidth: 32
    implicitHeight: 32
    identicon.asset.width: width
    identicon.asset.height: height
    identicon.asset.useAcronymForLetterIdenticon: true
    identicon.asset.color: Utils.colorForPubkey(root.pubKey)
    identicon.ringSettings.ringSpecModel: root.colorHash

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
        switch(root.currentUserStatus) {
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

        y: root.y - userStatusContextMenu.height + root.height
        x: root.x + root.width + 5

        compressedPubKey: root.compressedPubKey
        emojiHash: root.getEmojiHashFn(root.pubKey)
        colorHash: root.colorHash
        colorId: root.colorId
        name: root.name
        headerIcon: root.iconSource
        isEnsVerified: root.isEnsVerified

        currentUserStatus: root.currentUserStatus

        onViewProfileRequested: root.viewProfileRequested(root.pubKey)
        onCopyLinkRequested: ClipboardUtils.setText(root.getLinkToProfileFn(root.pubKey))
        onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
    }
}
