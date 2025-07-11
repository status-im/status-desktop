import QtQuick
import QtQuick.Controls

import StatusQ
import StatusQ.Controls
import StatusQ.Core.Theme

import shared.popups

import utils

StatusNavBarTabButton {
    id: root

    required property string name
    required property string usesDefaultName
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
    identicon.ringSettings.ringSpecModel: root.colorHash

    identicon.asset.name: {
        if (identicon.asset.isImage) {
            return icon.source
        }
        if (root.usesDefaultName) {
            return "contact"
        }
        return icon.name
    }
    // identicon.asset.width: identicon.asset.isImage ? 28 : (root.usesDefaultName ? Math.floor(width * 0.9) : width)
    // identicon.asset.height: identicon.asset.isImage ? 28 : (root.usesDefaultName ? Math.floor(height * 0.9) : height)
    identicon.asset.bgWidth: root.usesDefaultName ? width : 0
    identicon.asset.bgHeight: root.usesDefaultName ? height : 0
    identicon.asset.color: root.usesDefaultName ? Theme.palette.indirectColor2 : Utils.colorForPubkey(root.pubKey)
    identicon.asset.isLetterIdenticon: root.usesDefaultName ? false : icon.name !== "" && !identicon.asset.isImage
    identicon.asset.bgColor: root.usesDefaultName ? Utils.colorForPubkey(root.pubKey) : "transparent"

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
        objectName: "userStatusContextMenu"

        y: root.y - userStatusContextMenu.height + root.height
        x: root.x + root.width + 5

        compressedPubKey: root.compressedPubKey
        emojiHash: root.getEmojiHashFn(root.pubKey)
        colorHash: root.colorHash
        colorId: root.colorId
        name: root.name
        headerIcon: root.iconSource
        isEnsVerified: root.isEnsVerified
        usesDefaultName: root.usesDefaultName

        currentUserStatus: root.currentUserStatus

        onViewProfileRequested: root.viewProfileRequested(root.pubKey)
        onCopyLinkRequested: ClipboardUtils.setText(root.getLinkToProfileFn(root.pubKey))
        onSetCurrentUserStatusRequested: (status) => root.setCurrentUserStatusRequested(status)
    }
}
