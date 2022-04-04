import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import shared.panels 1.0
import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property WalletStore walletStore
    property var currentAccount: walletStore.currentAccount
    property var emojiPopup

    header.title: qsTr("Rename %1").arg(currentAccount.name)

    property int marginBetweenInputs: 30

    onOpened: {
        accountNameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Connections {
        enabled: popup.opened
        target: emojiPopup
        onEmojiSelected: function (emojiText, atCursor) {
            popup.contentItem.accountNameInput.input.icon.emoji = emojiText
        }
    }

    contentItem: Column {
        property alias accountNameInput: accountNameInput

        width: popup.width
        spacing: marginBetweenInputs
        topPadding: Style.current.padding

        StatusInput {
            id: accountNameInput
            input.isIconSelectable: true
            input.placeholderText: qsTr("Enter an account name...")
            input.text: currentAccount.name
            input.icon.emoji: currentAccount.emoji
            input.icon.color: currentAccount.color
            input.icon.name: !currentAccount.emoji ? "filled-account": ""
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
            titleText: qsTr("color").toUpperCase()
            selectedColor: currentAccount.color
            selectedColorIndex: {
                for (let i = 0; i < model.length; i++) {
                    if(model[i] === currentAccount.color)
                        return i
                }
            }
            onSelectedColorChanged: {
                if(selectedColor !== currentAccount.color) {
                    accountNameInput.input.icon.color = selectedColor
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
            text: qsTr("Change Name")

            enabled: accountNameInput.text !== "" && accountNameInput.valid

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

                const error = walletStore.updateCurrentAccount(currentAccount.address, accountNameInput.text, accountColorInput.selectedColor, accountNameInput.input.icon.emoji);

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
