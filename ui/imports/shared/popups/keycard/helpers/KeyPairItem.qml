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

    property ButtonGroup buttonGroup
    property bool usedAsSelectOption: false
    property bool tagClickable: false
    property bool tagDisplayRemoveAccountButton: false
    property bool canBeSelected: true
    property bool displayRadioButtonForSelection: true
    property bool useTransparentItemBackgroundColor: false

    property int keyPairType: Constants.keycard.keyPairType.unknown
    property string keyPairKeyUid: ""
    property string keyPairName: ""
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property string keyPairDerivedFrom: ""
    property bool keyPairCardLocked: false
    property var keyPairAccounts

    property bool displayAdditionalInfoForProfileKeypair: true
    property string additionalInfoForProfileKeypair: qsTr("Moving this key pair will require you to use your Keycard to login")

    signal keyPairSelected()
    signal removeAccount(int index, string name)
    signal accountClicked(int index)

    color: {
        if (!root.useTransparentItemBackgroundColor) {
            return root.keyPairCardLocked? Theme.palette.dangerColor3 : Theme.palette.baseColor2
        }

        if (sensor.containsMouse) {
            return Theme.palette.baseColor2
        }

        return Theme.palette.transparent
    }
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

    beneathTagsTitle: root.keyPairType === Constants.keycard.keyPairType.profile && root.displayAdditionalInfoForProfileKeypair?
                          root.additionalInfoForProfileKeypair :
                          !root.canBeSelected?
                              qsTranslate("", "Contains account(s) with Keycard incompatible derivation paths", root.keyPairAccounts.count.toString()) :
                              ""
    beneathTagsIcon: !!beneathTagsTitle? "info" : ""

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
        bgColor: Utils.getColorForId(model.account.colorId)
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
        title: Utils.appTranslation(model.account.name)
        titleText.font.pixelSize: 12
        titleText.color: Theme.palette.indirectColor1

        onClicked: {
            root.removeAccount(index, model.account.name)
        }

        onTagClicked: {
            root.accountClicked(index)
        }
    }

    components: root.canBeSelected? d.components : []

    QtObject {
        id: d
        property string myPublicKey: userProfile.pubKey

        property list<Item> components: [
            StatusRadioButton {
                id: radioButton
                visible: root.usedAsSelectOption && root.displayRadioButtonForSelection
                ButtonGroup.group: root.buttonGroup
                onCheckedChanged: {
                    d.doAction(checked)
                }
            },
            StatusIcon {
                visible: root.usedAsSelectOption && !root.displayRadioButtonForSelection
                icon: "next"
                color: Theme.palette.baseColor1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        d.doAction(true)
                    }
                }
            }
        ]

        function doAction(checked){
            if (!root.usedAsSelectOption || !root.canBeSelected)
                return
            if (checked) {
                root.keyPairSelected()
            }
        }
    }

    onClicked: {
        if (!root.usedAsSelectOption || !root.canBeSelected)
            return
        d.doAction(!root.displayRadioButtonForSelection || radioButton.checked)
    }
}
