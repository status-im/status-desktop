import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

StatusListItem {
    id: root

    property bool displayChevronComponent: true
    property string keycardName: ""
    property string keycardUid: ""
    property bool keycardLocked: false
    property int keyPairType: Constants.keycard.keyPairType.unknown
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property var keyPairAccounts

    signal keycardSelected()

    color: root.keycardLocked? Theme.palette.dangerColor3 : Theme.palette.baseColor2
    title: root.keycardName
    statusListItemTitleAside.textFormat: Text.RichText
    statusListItemTitleAside.visible: !!statusListItemTitleAside.text
    statusListItemTitleAside.text: {
        let t = ""
        if (root.keyPairType === Constants.keycard.keyPairType.profile) {
            t = Utils.getElidedCompressedPk(d.myPublicKey)
        }
        if (root.keycardLocked) {
            let label = qsTr("Keycard Locked")
            t += ` <font color="${Theme.palette.dangerColor1}" size="5">${label}</font>`
        }
        return t
    }
    statusListItemSubTitle.text: !!root.keycardUid? "(%1)".arg(root.keycardUid) : ""
    statusListItemSubTitle.font.pixelSize: 10
    statusListItemSubTitle.visible: !!statusListItemSubTitle.text

    asset {
        width: root.keyPairIcon? 24 : 40
        height: root.keyPairIcon? 24 : 40
        name: root.keyPairImage? root.keyPairImage : root.keyPairIcon
        isImage: !!root.keyPairImage
        color: root.keyPairType === Constants.keycard.keyPairType.profile?
                   Utils.colorForPubkey(d.myPublicKey) :
                   root.keycardLocked? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
        letterSize: Math.max(4, asset.width / 2.4)
        charactersLen: 2
        isLetterIdenticon: !root.keyPairIcon && !asset.name.toString()
        bgColor: root.keycardLocked? Theme.palette.dangerColor3 : Theme.palette.primaryColor3
    }

    ringSettings {
        ringSpecModel: root.keyPairType === Constants.keycard.keyPairType.profile?
                           Utils.getColorHashAsJson(d.myPublicKey) : []
        ringPxSize: Math.max(asset.width / 24.0)
    }

    tagsModel: root.keyPairAccounts

    tagsDelegate: StatusListItemTag {
        bgColor: Utils.getColorForId(model.account.colorId)
        bgRadius: 6
        height: Style.current.bigPadding
        closeButtonVisible: false
        asset {
            emoji: model.account.emoji
            emojiSize: Emoji.size.verySmall
            isLetterIdenticon: !!model.account.emoji
            name: model.account.icon
            color: Theme.palette.indirectColor1
            width: 16
            height: 16
        }
        title: Utils.appTranslation(model.account.name)
        titleText.font.pixelSize: 12
        titleText.color: Theme.palette.indirectColor1
    }

    components: [
        StatusIcon {
            visible: root.displayChevronComponent
            icon: "tiny/chevron-right"
            color: Theme.palette.baseColor1
        }
    ]

    onClicked: {
        root.keycardSelected()
    }

    QtObject {
        id: d
        property string myPublicKey: userProfile.pubKey
    }
}
