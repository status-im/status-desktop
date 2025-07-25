import QtQuick

import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Controls

import utils

StatusListItem {
    id: root

    property var keyPair

    signal buttonClicked()

    title: !!root.keyPair? root.keyPair.pairType === Constants.keypair.type.watchOnly ? qsTr("Watched address") : root.keyPair.name: ""
    titleAsideText: !!root.keyPair && root.keyPair.pairType === Constants.keypair.type.profile? Utils.getElidedCompressedPk(root.keyPair.pubKey): ""
    asset {
        width: !!root.keyPair && root.keyPair.icon? Theme.bigPadding : 40
        height: !!root.keyPair && root.keyPair.icon? Theme.bigPadding : 40
        name: !!root.keyPair? !!root.keyPair.image? root.keyPair.image : root.keyPair.icon : ""
        isImage: !!root.keyPair && !!root.keyPair.image
        color: !!root.keyPair && root.keyPair.pairType === Constants.keypair.type.profile? Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.primaryColor1
        letterSize: Math.max(4, asset.width / 2.4)
        charactersLen: 2
        isLetterIdenticon: !!root.keyPair && !root.keyPair.icon && !asset.name.toString()
    }
    color: {
        if (sensor.containsMouse || root.highlighted) {
            return Theme.palette.baseColor2
        }
        return Theme.palette.transparent
    }
    ringSettings {
        ringSpecModel: !!root.keyPair && root.keyPair.pairType === Constants.keypair.type.profile? Utils.getColorHashAsJson(root.userProfilePublicKey) : []
        ringPxSize: Math.max(asset.width / 24.0)
    }
    tagsModel: !!root.keyPair? root.keyPair.accounts: []
    tagsDelegate: StatusListItemTag {
        bgColor: !!model.account.colorId ? Utils.getColorForId(model.account.colorId): ""
        bgRadius: 6
        height: Theme.bigPadding
        closeButtonVisible: false
        asset.width: Theme.bigPadding
        asset.height: Theme.bigPadding
        asset.emoji: model.account.emoji
        asset.emojiSize: Emoji.size.verySmall
        asset.color: Theme.palette.transparent
        asset.isLetterIdenticon: true
        title: model.account.name
        titleText.font.pixelSize: Theme.tertiaryTextFontSize
        titleText.color: Theme.palette.indirectColor1
    }
    components: [
        StatusRoundButton {
            width: 32
            height: 32
            radius: 8
            visible: root.sensor.containsMouse
            type: StatusRoundButton.Type.Quinary
            icon.name: "more"
            icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            icon.hoverColor: Theme.palette.primaryColor3
            onClicked: root.buttonClicked()
        }
    ]
}
