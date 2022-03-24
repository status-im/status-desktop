import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property bool loading: false
    property var emojiPopup: null

    signal afterAddAccount()

    //% "Add a watch-only account"
    header.title: qsTrId("add-watch-account")

    onOpened: {
        addressInput.text = ""
        addressInput.reset()
        accountNameInput.text = ""
        accountNameInput.reset()
        accountNameInput.input.icon.emoji = StatusQUtils.Emoji.getRandomEmoji()
        accountColorInput.selectedColorIndex = Math.floor(Math.random() * accountColorInput.model.length)
        addressInput.forceActiveFocus(Qt.MouseFocusReason)
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
        spacing: 8
        topPadding: 20

        StatusInput {
            id: addressInput
            // TODO add QR code reader for the address
            //% "Enter address..."
            input.placeholderText: qsTrId("enter-address...")
            //% "Account address"
            label: qsTrId("wallet-key-title")
            validators: [
                StatusAddressValidator {
                    //% "This needs to be a valid address (starting with 0x)"
                    errorMessage: qsTrId("this-needs-to-be-a-valid-address-(starting-with-0x)")
                },
                StatusMinLengthValidator {
                    //% "You need to enter an address"
                    errorMessage: qsTrId("you-need-to-enter-an-address")
                    minLength: 1
                }
            ]
        }

        StatusInput {
            id: accountNameInput
            //% "Enter an account name..."
            input.placeholderText: qsTrId("enter-an-account-name...")
            //% "Account name"
            label: qsTrId("account-name")
            input.isIconSelectable: true
            input.icon.color: accountColorInput.selectedColor ? accountColorInput.selectedColor : Theme.palette.directColor1
            onIconClicked: {
                popup.emojiPopup.open()
                popup.emojiPopup.x = popup.x + Style.current.padding
                popup.emojiPopup.y = popup.y + contentItem.y + accountNameInput.y + accountNameInput.height +  Style.current.halfPadding
            }
            validators: [
                StatusMinLengthValidator {
                    //% "You need to enter an account name"
                    errorMessage: qsTrId("you-need-to-enter-an-account-name")
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
            anchors.horizontalCenter: parent.horizontalCenter
            //% "color"
            titleText: qsTr("color").toUpperCase()
        }

        Item {
            width: parent.width
            height: 8
        }
    }

    rightButtons: [
        StatusButton {
            text: loading ?
                      //% "Loading..."
                      qsTrId("loading") :
                      //% "Add account"
                      qsTrId("add-account")

            enabled: !loading && addressInput.text !== "" && accountNameInput.text !== "" && accountNameInput.valid

            MessageDialog {
                id: accountError
                title: "Adding the account failed"
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                // TODO the loaidng doesn't work because the function freezes th eview. Might need to use threads
                loading = true
                if (!addressInput.valid || !accountNameInput.valid) {
                    Global.playErrorSound();
                    return loading = false
                }
                const error = RootStore.addWatchOnlyAccount(addressInput.text, accountNameInput.text, accountColorInput.selectedColor, accountNameInput.input.icon.emoji);
                loading = false
                if (error) {
                    Global.playErrorSound();
                    accountError.text = error
                    return accountError.open()
                }
                popup.afterAddAccount()
                popup.close();
            }
        }
    ]
}
