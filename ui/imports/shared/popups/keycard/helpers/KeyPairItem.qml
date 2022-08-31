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

    property string keyPairPubKey: ""
    property string keyPairName: ""
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property string keyPairDerivedFrom: ""
    property string keyPairAccounts: ""

    color: Style.current.grey
    title: root.keyPairName
    titleAsideText: Utils.getElidedCompressedPk(root.keyPairPubKey)

    image {
        width: 40
        height: 40
        source: root.keyPairImage
    }

    icon {
        width: root.keyPairIcon? 24 : 40
        height: root.keyPairIcon? 24 : 40
        name: root.keyPairIcon
        color: Utils.colorForPubkey(root.keyPairPubKey)
        letterSize: Math.max(4, this.image.width / 2.4)
        charactersLen: 2
        isLetterIdenticon: !root.keyPairIcon && !this.image.source.toString()
        background.color: Theme.palette.primaryColor3
    }

    ringSettings {
        ringSpecModel: Utils.getColorHashAsJson(root.keyPairPubKey)
        ringPxSize: Math.max(this.icon.width / 24.0)
    }

    tagsModel: ListModel{}

    tagsDelegate: StatusListItemTag {
        color: model.color
        height: Style.current.bigPadding
        radius: 6
        closeButtonVisible: false
        icon {
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
            visible: root.usedAsSelectOption
            ButtonGroup.group: root.buttonGroup
            onCheckedChanged: {
                if (!root.usedAsSelectOption)
                    return
                let checkCondition = root.sharedKeycardModule.selectedKeyPairItem.derivedFrom === root.keyPairDerivedFrom
                if (checked && checked != checkCondition) {
                    root.sharedKeycardModule.setSelectedKeyPairByTheAddressItIsDerivedFrom(root.keyPairDerivedFrom)
                }
            }
            Component.onCompleted: {
                if (!root.usedAsSelectOption)
                    return
                checked = Qt.binding(function() {
                    return root.sharedKeycardModule.selectedKeyPairItem.derivedFrom === root.keyPairDerivedFrom
                })
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

    onClicked: {
        if (!root.usedAsSelectOption)
            return
        root.sharedKeycardModule.setSelectedKeyPairByTheAddressItIsDerivedFrom(root.keyPairDerivedFrom)
    }
}
