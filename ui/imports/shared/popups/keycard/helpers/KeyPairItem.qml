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
    property bool tagClickable: false
    property bool tagDisplayRemoveAccountButton: false

    property int keyPairType: Constants.keycard.keyPairType.unknown
    property string keyPairPubKey: ""
    property string keyPairName: ""
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property string keyPairDerivedFrom: ""
    property bool keyPairCardLocked: false
    property var keyPairAccounts

    signal keyPairSelected()
    signal removeAccount(int index, string name)
    signal accountClicked(int index)

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

    tagsModel: root.keyPairAccounts

    tagsDelegate: StatusListItemTag {
        bgColor: model.account.color
        height: Style.current.bigPadding
        bgRadius: 6
        tagClickable: root.tagClickable
        closeButtonVisible: root.tagDisplayRemoveAccountButton?
                                index > 0 : false
        asset {
            emoji: model.account.emoji
            emojiSize: Emoji.size.verySmall
            isLetterIdenticon: !!model.account.emoji
            name: model.account.icon
            color: Theme.palette.indirectColor1
            width: 16
            height: 16
        }
        title: model.account.name
        titleText.font.pixelSize: 12
        titleText.color: Theme.palette.indirectColor1

        onClicked: {
            root.removeAccount(index, model.account.name)
        }

        onTagClicked: {
            root.accountClicked(index)
        }
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
