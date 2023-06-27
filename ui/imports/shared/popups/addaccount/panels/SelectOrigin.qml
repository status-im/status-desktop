import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

StatusSelect {
    id: root

    property string userProfilePublicKey
    property var originModel
    property var selectedOrigin

    signal originSelected(string keyUid)

    label: qsTr("Origin")

    model: root.originModel

    selectedItemComponent: StatusListItem {
        objectName: "AddAccountPopup-SelectedOrigin"
        title: Utils.appTranslation(root.selectedOrigin.name)
        statusListItemTitle.color: Theme.palette.directColor1
        border.width: 1
        border.color: Theme.palette.baseColor2

        asset {
            width: root.selectedOrigin.icon? 24 : 40
            height: root.selectedOrigin.icon? 24 : 40
            name: root.selectedOrigin.image? root.selectedOrigin.image : root.selectedOrigin.icon
            isImage: !!root.selectedOrigin.image
            color: root.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.profile?
                       Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.primaryColor1
            letterSize: Math.max(4, asset.width / 2.4)
            charactersLen: 2
            isLetterIdenticon: !root.selectedOrigin.icon && !asset.name.toString()
            bgColor: "transparent"
        }

        ringSettings {
            ringSpecModel: root.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.profile?
                               Utils.getColorHashAsJson(root.userProfilePublicKey) : []
            ringPxSize: Math.max(asset.width / 24.0)
        }

        tagsModel : root.selectedOrigin.accounts

        tagsDelegate: StatusListItemTag {
            bgColor: Utils.getColorForId(model.account.colorId)
            height: Style.current.bigPadding
            bgRadius: 6
            tagClickable: false
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
            title: model.account.name
            titleText.font.pixelSize: 12
            titleText.color: Theme.palette.indirectColor1
        }
    }
    menuDelegate: StatusListItem {
        id: menu
        objectName: "AddAccountPopup-OriginOption-" +
                    (model.keyPair.pairType === Constants.addAccountPopup.keyPairType.unknown? model.keyPair.keyUid : model.keyPair.name)

        property bool isProfileKeypair: model.keyPair.pairType === Constants.addAccountPopup.keyPairType.profile
        property bool isOption: model.keyPair.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddNewMasterKey ||
                                model.keyPair.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc
        property bool isHeader: model.keyPair.pairType === Constants.addAccountPopup.keyPairType.unknown && !menu.isOption

        title: model.keyPair.pairType === Constants.addAccountPopup.keyPairType.unknown?
                   Utils.appTranslation(model.keyPair.keyUid) :
                   model.keyPair.name
        subTitle: {
            if (menu.isOption) {
                if (model.keyPair.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddNewMasterKey)
                    return qsTr("From Keycard, private key or seed phrase")
                if (model.keyPair.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc)
                    return qsTr("Any ETH address")
            }
            return ""
        }
        enabled: !menu.isHeader && model.keyPair.pairType !== Constants.addAccountPopup.keyPairType.privateKeyImport

        asset {
            width: model.keyPair.icon? 24 : 40
            height: model.keyPair.icon? 24 : 40
            name: model.keyPair.image? model.keyPair.image : model.keyPair.icon
            isImage: !!model.keyPair.image
            color: menu.isProfileKeypair? Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.baseColor1
            letterSize: Math.max(4, asset.width / 2.4)
            charactersLen: 2
            isLetterIdenticon: !menu.isHeader && !model.keyPair.icon && !asset.name.toString()
            bgColor: "transparent"
        }

        ringSettings {
            ringSpecModel: menu.isProfileKeypair? Utils.getColorHashAsJson(root.userProfilePublicKey) : []
            ringPxSize: Math.max(asset.width / 24.0)
        }

        tagsModel: menu.isHeader || menu.isOption? [] : model.keyPair.accounts

        tagsDelegate: StatusListItemTag {
            bgColor: Utils.getColorForId(model.account.colorId)
            height: Style.current.bigPadding
            bgRadius: 6
            tagClickable: false
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
            title: model.account.name
            titleText.font.pixelSize: 12
            titleText.color: Theme.palette.indirectColor1
        }

        components: [
            StatusIcon {
                visible: icon != ""
                icon: {
                    if (menu.isOption) {
                        return "tiny/chevron-right"
                    }

                    if (!menu.isHeader && model.keyPair.name === root.selectedOrigin.name) {
                        return "checkmark"
                    }

                    return ""
                }
                color: menu.isOption? Theme.palette.baseColor1 : Theme.palette.primaryColor1
            }
        ]

        onClicked: {
            root.originSelected(model.keyPair.keyUid)
            root.selectMenu.close()
        }
    }
}
