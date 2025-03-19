import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

/**
  attached model property should be compatible with nim's contact model
 */

StatusMemberListItem {
    id: root

    readonly property string _pubKey: model.pubKey // expose uncompressed pubkey
    readonly property string userAlias: !!model.alias ? model.alias : Utils.generateAlias(model.pubKey)
    readonly property color userColor: !!model.colorId ? Utils.colorForColorId(model.colorId) : Utils.colorForPubkey(model.pubKey)
    readonly property var userColorHash: !!model.colorHash ? model.colorHash : Utils.getColorHashAsJson(model.pubKey)

    pubKey: model.isEnsVerified ? "" : model.compressedPubKey
    nickName: model.localNickname
    userName: ProfileUtils.displayName("", model.ensName, model.displayName,userAlias)
    isBlocked: model.isBlocked
    isVerified: model.isVerified || model.trustStatus === Constants.trustStatus.trusted
    isUntrustworthy: model.isUntrustworthy || model.trustStatus === Constants.trustStatus.untrustworthy
    isContact: model.isContact
    icon.name: model.thumbnailImage || model.icon
    icon.color: userColor
    status: model.onlineStatus
    ringSettings.ringSpecModel: userColorHash
    color: (hovered || highlighted) ? Theme.palette.baseColor2 : "transparent"
}
