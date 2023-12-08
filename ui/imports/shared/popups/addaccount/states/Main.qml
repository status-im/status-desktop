import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../stores"
import "../panels"
import "../../common"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (root.store.addAccountModule.selectedColorId === "") {
            colorSelection.selectedColorIndex = Math.floor(Math.random() * colorSelection.model.length)
        }
        else {
            let ind = d.evaluateColorIndex(Utils.getColorForId(root.store.addAccountModule.selectedColorId))
            colorSelection.selectedColorIndex = ind
        }

        if (root.store.addAccountModule.selectedEmoji === "") {
            root.store.addAccountModule.selectedEmoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
        }

        accountName.text = root.store.addAccountModule.accountName
        if (d.isEdit) {
            accountName.input.asset.emoji = root.store.addAccountModule.selectedEmoji;
        } else {
            accountName.input.asset.isLetterIdenticon = true;
        }
        accountName.input.edit.forceActiveFocus()
        accountName.validate(true)
    }

    QtObject {
        id: d
        readonly property bool isEdit: root.store.editMode

        function evaluateColorIndex(color) {
            for (let i = 0; i < Theme.palette.customisationColorsArray.length; i++) {
                if(Theme.palette.customisationColorsArray[i] === color) {
                    return i
                }
            }
            return 0
        }

        function openEmojiPopup(showLeft) {
            if (!root.store.emojiPopup) {
                return
            }
            let inputCoords = accountName.mapToItem(appMain, 0, 0)
            root.store.emojiPopup.open()
            root.store.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall
            root.store.emojiPopup.x = inputCoords.x
            if (!showLeft) {
                root.store.emojiPopup.x += accountName.width - root.store.emojiPopup.width
            }
            root.store.emojiPopup.y = inputCoords.y + accountName.height + Style.current.halfPadding
        }
    }

    Connections {
        target: root.store.emojiPopup

        function onEmojiSelected (emojiText, atCursor) {
            let emoji = StatusQUtils.Emoji.deparse(emojiText)
            root.store.addAccountModule.selectedEmoji = emoji
            accountName.input.asset.isLetterIdenticon = false
            accountName.input.asset.emoji = emojiText
        }
    }

    Component {
        id: spacer
        Rectangle {
            color: Theme.palette.baseColor4
        }
    }

    ColumnLayout {
        id: layout
        width: parent.width
        spacing: 0

        Loader {
            Layout.preferredHeight: Style.current.padding
            Layout.fillWidth: true
            sourceComponent: spacer
        }

        Column {
            Layout.fillWidth: true
            spacing: Style.current.padding
            topPadding: Style.current.padding
            bottomPadding: Style.current.padding

            StatusInput {
                id: accountName
                objectName: "AddAccountPopup-AccountName"
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: qsTr("Enter an account name...")
                label: qsTr("Name")
                charLimit: 20
                text: root.store.addAccountModule.accountName
                input.isIconSelectable: true
                input.leftPadding: Style.current.padding
                input.asset.color: Utils.getColorForId(root.store.addAccountModule.selectedColorId)
                onIconClicked: {
                    d.openEmojiPopup(true)
                }
                input.rightComponent: StatusFlatRoundButton {
                    objectName: "AddAccountPopup-AccountEmoji"
                    width: 30
                    height: 30
                    radius: 30
                    icon.name: "emojis"
                    icon.width: 24
                    icon.height: 24
                    onClicked: {
                        d.openEmojiPopup(false)
                    }
                }
                validators: [
                    StatusMinLengthValidator {
                        minLength: 1
                        errorMessage: Utils.getErrorMessage(accountName.errors, qsTr("wallet account name"))
                    },
                    StatusRegularExpressionValidator {
                        regularExpression: Constants.regularExpressions.alphanumericalWithSpace
                        errorMessage: Constants.errorMessages.alphanumericalWithSpaceRegExp
                    }
                ]

                onTextChanged: {
                    root.store.addAccountModule.accountName = text
                    if (input.asset.emoji === "") {
                        input.letterIconName = text;
                    }
                }

                onKeyPressed: {
                    root.store.submitPopup(event)
                }

                onValidChanged: {
                    root.store.accountNameIsValid = accountName.valid
                }
            }

            StatusColorSelectorGrid {
                id: colorSelection
                objectName: "AddAccountPopup-AccountColor"
                anchors.horizontalCenter: parent.horizontalCenter
                model: Theme.palette.customisationColorsArray
                title.color: Theme.palette.directColor1
                title.font.pixelSize: Constants.addAccountPopup.labelFontSize1
                title.text: qsTr("Colour")
                selectedColorIndex: -1

                onSelectedColorChanged: {
                    root.store.addAccountModule.selectedColorId = Utils.getIdForColor(selectedColor)
                }
            }

            SelectOrigin {
                anchors.horizontalCenter: parent.horizontalCenter

                userProfilePublicKey: root.store.userProfilePublicKey
                originModel: root.store.editMode? [] : root.store.originModel
                selectedOrigin: root.store.selectedOrigin
                caretVisible: !root.store.editMode
                enabled: !root.store.editMode

                onOriginSelected: {
                    if (keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddNewMasterKey) {
                        root.store.currentState.doSecondaryAction()
                        return
                    }
                    root.store.changeSelectedOrigin(keyUid)
                }
            }

            WatchOnlyAddressSection {
                width: parent.width - 2 * Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Style.current.padding
                visible: !root.store.editMode &&
                         root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.unknown &&
                         root.store.selectedOrigin.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc

                store: root.store

                onVisibleChanged: {
                    reset()
                }
            }
        }

        Loader {
            Layout.preferredHeight: Style.current.padding
            Layout.fillWidth: true
            sourceComponent: spacer
        }

        DerivationPathSection {
            id: derivationPathSection
            Layout.fillWidth: true
            visible: root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.profile ||
                     root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.seedImport
            store: root.store
        }

        AddressWithAddressDetails {
            id: addressWithDetails
            Layout.fillWidth: true
            Layout.margins: Style.current.padding
            spacing: Style.current.halfPadding
            visible: root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.privateKeyImport ||
                     root.store.editMode &&
                     root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.unknown &&
                     root.store.selectedOrigin.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc

            addressText: root.store.editMode? qsTr("Account") : qsTr("Public address of private key")
            addressDetailsItem: root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.privateKeyImport?
                                    root.store.privateKeyAccAddress
                                  : root.store.watchOnlyAccAddress
            displayDetails: !root.store.editMode
            displayCopyButton: root.store.editMode
            addressColor: root.store.editMode? Theme.palette.baseColor1 : Theme.palette.directColor1
        }

        Loader {
            Layout.preferredHeight: Style.current.padding
            Layout.fillWidth: true
            visible: derivationPathSection.visible || addressWithDetails.visible
            sourceComponent: spacer
        }
    }
}
