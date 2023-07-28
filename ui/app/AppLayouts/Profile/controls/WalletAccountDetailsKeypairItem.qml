import QtQuick 2.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import utils 1.0

StatusListItem {
    id: root

    property var keyPair

    signal buttonClicked()

    title: keyPair ? keyPair.pairType === Constants.keycard.keyPairType.watchOnly ? qsTr("Watch only") : keyPair.name: ""
    titleAsideText: keyPair && keyPair.pairType === Constants.keycard.keyPairType.profile ? Utils.getElidedCompressedPk(keyPair.pubKey): ""
    asset {
        width: keyPair && keyPair.icon ? Style.current.bigPadding : 40
        height: keyPair && keyPair.icon ? Style.current.bigPadding : 40
        name: keyPair ? keyPair.image ? keyPair.image : keyPair.icon: ""
        isImage: !!keyPair && !!keyPair.image
        color: keyPair && keyPair.pairType === Constants.keycard.keyPairType.profile ? Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.primaryColor1
        letterSize: Math.max(4, asset.width / 2.4)
        charactersLen: 2
        isLetterIdenticon: !!keyPair && !keyPair.icon && !asset.name.toString()
    }
    color: {
        if (sensor.containsMouse || root.highlighted) {
            return Theme.palette.baseColor2
        }
        return Theme.palette.transparent
    }
    ringSettings {
        ringSpecModel: keyPair && keyPair.pairType === Constants.keycard.keyPairType.profile ? Utils.getColorHashAsJson(root.userProfilePublicKey) : []
        ringPxSize: Math.max(asset.width / 24.0)
    }
    tagsModel: keyPair ? keyPair.accounts: []
    tagsDelegate: StatusListItemTag {
        bgColor: !!model.account.colorId ? Utils.getColorForId(model.account.colorId): ""
        bgRadius: 6
        height: Style.current.bigPadding
        closeButtonVisible: false
        asset.width: Style.current.bigPadding
        asset.height: Style.current.bigPadding
        asset.emoji: model.account.emoji
        asset.emojiSize: Emoji.size.verySmall
        asset.color: Theme.palette.transparent
        asset.isLetterIdenticon: true
        title: model.account.name
        titleText.font.pixelSize: 12
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
