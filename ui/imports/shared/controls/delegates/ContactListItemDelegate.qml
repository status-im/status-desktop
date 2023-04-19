import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

/**
  attached model property should be compatible with nim's contact model
 */

StatusMemberListItem {
    id: root

    readonly property string _pubKey: model.pubKey // expose uncompressed pubkey

    pubKey: model.isEnsVerified ? "" : Utils.getCompressedPk(model.pubKey)
    nickName: model.localNickname
    userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
    isVerified: model.isVerified
    isUntrustworthy: model.isUntrustworthy
    isContact: model.isContact
    asset.name: model.icon
    asset.color: Utils.colorForColorId(model.colorId)
    asset.isImage: (asset.name !== "")
    asset.isLetterIdenticon: (asset.name === "")
    status: model.onlineStatus
    statusListItemIcon.badge.border.color: sensor.containsMouse ? Theme.palette.baseColor2 : Theme.palette.baseColor4
    ringSettings.ringSpecModel: model.colorHash
    color: (sensor.containsMouse || highlighted) ? Theme.palette.baseColor2 : "transparent"
}
