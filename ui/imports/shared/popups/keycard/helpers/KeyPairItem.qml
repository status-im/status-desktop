import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

StatusListItem {
    id: root

    property var sharedKeycardModule
    property ButtonGroup buttonGroup
    property bool usedAsSelectOption: false

    property int keyPairType: Constants.keycard.keyPairType.unknown
    property string keyPairPubKey: ""
    property string keyPairName: ""
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property string keyPairDerivedFrom: ""
    property string keyPairAccounts: ""
    property bool keyPairCardLocked: false

    signal keyPairSelected()

    color: root.keyPairCardLocked? Theme.palette.dangerColor3 : Theme.palette.baseColor2
    title: root.keyPairName
    statusListItemTitleAside.textFormat: Text.RichText
    statusListItemTitleAside.visible: !!statusListItemTitleAside.text
    statusListItemTitleAside.text: {
        let t = ""
        if (root.keyPairType === Constants.keycard.keyPairType.profile) {
            t = Utils.getElidedCompressedPk(d.myPublicKey)
        }
        if (root.keyPairCardLocked) {
            let label = qsTr("Keycard Locked")
            t += ` <font color="${Theme.palette.dangerColor1}" size="5">${label}</font>`
        }
        return t
    }

    asset {
        width: root.keyPairIcon? 24 : 40
        height: root.keyPairIcon? 24 : 40
        name: root.keyPairImage? root.keyPairImage : root.keyPairIcon
        isImage: !!root.keyPairImage
        color: root.keyPairType === Constants.keycard.keyPairType.profile?
                   Utils.colorForPubkey(d.myPublicKey) :
                   root.keyPairCardLocked? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
        letterSize: Math.max(4, asset.width / 2.4)
        charactersLen: 2
        isLetterIdenticon: !root.keyPairIcon && !asset.name.toString()
        bgColor: root.keyPairCardLocked? Theme.palette.dangerColor3 : Theme.palette.primaryColor3
    }

    ringSettings {
        ringSpecModel: root.keyPairType === Constants.keycard.keyPairType.profile?
                           Utils.getColorHashAsJson(d.myPublicKey) : []
        ringPxSize: Math.max(asset.width / 24.0)
    }

    tagsModel: ListModel{}

    tagsDelegate: StatusListItemTag {
        bgColor: model.color
        bgRadius: 6
        height: Style.current.bigPadding
        closeButtonVisible: false
        asset {
            emoji: model.emoji
            emojiSize: Emoji.size.verySmall
            isLetterIdenticon: !!model.emoji
            name: model.icon
            color: Theme.palette.indirectColor1
            width: 16
            height: 16
        }
        title: model.name
        titleText.font.pixelSize: 12
        titleText.color: Theme.palette.indirectColor1
    }

    components: [
        StatusRadioButton {
            id: radioButton
            visible: root.usedAsSelectOption
            ButtonGroup.group: root.buttonGroup
            onCheckedChanged: {
                if (!root.usedAsSelectOption)
                    return
                if (checked) {
                    root.sharedKeycardModule.setSelectedKeyPair(root.keyPairPubKey)
                    root.keyPairSelected()
                }
            }
        }
    ]

    Component.onCompleted: {
        if (root.keyPairAccounts === "") {
            // should never be here, as it's not possible to have keypair item without at least a single account
            console.debug("accounts list is empty for selecting keycard pair")
            return
        }
        let obj = JSON.parse(root.keyPairAccounts)
        if (obj.error) {
            console.debug("error parsing accounts for selecting keycard pair, error: ", obj.error)
            return
        }

        for (var i=0; i<obj.length; i++) {
            this.tagsModel.append({"name": obj[i].Field0, "color": obj[i].Field4, "emoji": obj[i].Field3, "icon": obj[i].Field5})
        }
    }

    QtObject {
        id: d
        property string myPublicKey: userProfile.pubKey
    }

    onClicked: {
        if (!root.usedAsSelectOption)
            return
        radioButton.checked = true
    }
}
