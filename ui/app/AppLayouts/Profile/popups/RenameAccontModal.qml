import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.panels 1.0
import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property WalletStore walletStore
    property var account
    property var emojiPopup

    headerSettings.title: qsTr("Rename %1").arg(popup.account.name)

    property int marginBetweenInputs: 30

    onOpened: {
        accountNameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Connections {
        enabled: popup.opened
        target: emojiPopup
        function onEmojiSelected(emojiText: string, atCursor: bool) {
            let emoji = StatusQUtils.Emoji.deparse(emojiText)
            popup.contentItem.accountNameInput.input.asset.emoji = emoji
        }
    }

    contentItem: Column {
        property alias accountNameInput: accountNameInput

        width: popup.width
        spacing: marginBetweenInputs
        topPadding: Style.current.padding

        StatusInput {
            id: accountNameInput

            anchors.horizontalCenter: parent.horizontalCenter
            input.edit.objectName: "renameAccountNameInput"
            input.isIconSelectable: true
            placeholderText: qsTr("Enter an account name...")
            input.text: popup.account.name
            input.asset.emoji: popup.account.emoji
            input.asset.color: Utils.getColorForId(popup.account.colorId)
            input.asset.name: !popup.account.emoji ? "filled-account": ""

            validationMode: StatusInput.ValidationMode.Always

            onIconClicked: {
                popup.emojiPopup.open()
                popup.emojiPopup.x = popup.x + accountNameInput.x + Style.current.padding
                popup.emojiPopup.y = popup.y + contentItem.y + accountNameInput.y + accountNameInput.height +  Style.current.halfPadding
            }
            validators: [
                StatusMinLengthValidator {
                    errorMessage: qsTr("You need to enter an account name")
                    minLength: 1
                },
                StatusRegularExpressionValidator {
                    regularExpression: /^[^<>]+$/
                    errorMessage: qsTr("This is not a valid account name")
                }
            ]
            charLimit: 40
        }

        StatusColorSelectorGrid {
            id: accountColorInput
            anchors.top: selectedColor.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            model: Theme.palette.customisationColorsArray
            titleText: qsTr("COLOR")
            selectedColor: Utils.getColorForId(popup.account.colorId)
            selectedColorIndex: {
                for (let i = 0; i < model.length; i++) {
                    if(model[i] === popup.account.color)
                        return i
                }
                return -1
            }
            onSelectedColorChanged: {
                if(selectedColor !== popup.account.color) {
                    accountNameInput.input.asset.color = selectedColor
                }
            }
        }

        Item {
            width: parent.width
            height: 8
        }
    }

    rightButtons: [
        StatusButton {
            id: saveBtn
            objectName: "renameAccountModalSaveBtn"
            text: qsTr("Change Name")

            enabled: accountNameInput.text !== "" &&
                     accountNameInput.valid &&
                     (accountNameInput.text !== popup.account.name ||
                      accountColorInput.selectedColorIndex >= 0 && accountColorInput.selectedColor !== popup.account.color ||
                      accountNameInput.input.asset.emoji !== popup.account.emoji)

            MessageDialog {
                id: changeError
                title: qsTr("Changing settings failed")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                if (!accountNameInput.valid) {
                     return
                 }

                const error = walletStore.updateAccount(popup.account.address, accountNameInput.text, Utils.getIdForColor(accountColorInput.selectedColor), accountNameInput.input.asset.emoji);

                if (error) {
                    Global.playErrorSound();
                    changeError.text = error
                    changeError.open()
                    return
                }
                popup.close();
            }
        }
    ]
}
