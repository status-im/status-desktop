import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property string passwordValidationError: ""
    property string seedValidationError: ""
    property bool loading: false
    property var emojiPopup: null

    signal afterAddAccount()

    function reset() {
        passwordInput.text = ""
        accountNameInput.text = ""
        seedPhraseTextArea.textArea.text = ""
    }

    function validate() {
        if (passwordInput.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (passwordInput.text.length < 6) {
            //% "Password needs to be 6 characters or more"
            passwordValidationError = qsTrId("password-needs-to-be-6-characters-or-more")
        } else {
            passwordValidationError = ""
        }

        if (seedPhraseTextArea.textArea.text === "") {
            //% "You need to enter a seed phrase"
            seedValidationError = qsTrId("you-need-to-enter-a-seed-phrase")
        } else if (!Utils.isMnemonic(seedPhraseTextArea.textArea.text)) {
            //% "Enter a valid mnemonic"
            seedValidationError = qsTrId("enter-a-valid-mnemonic")
        } else {
            seedValidationError = ""
        }

        return passwordValidationError === "" && seedValidationError === "" && accountNameInput.valid
    }

    //% "Add account with a seed phrase"
    header.title: qsTrId("add-seed-account")

    onOpened: {
        seedPhraseTextArea.textArea.text = ""
        passwordInput.text = ""
        accountNameInput.text = ""
        accountNameInput.reset()
        accountNameInput.input.icon.emoji = StatusQUtils.Emoji.getRandomEmoji()
        passwordValidationError = ""
        seedValidationError = ""
        accountColorInput.selectedColorIndex = Math.floor(Math.random() * accountColorInput.model.length)
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
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

        Column {
            width: parent.width
            spacing: Style.current.xlPadding
            // To-Do Password hidden option not supported in StatusQ StatusBaseInput
            Input {
                id: passwordInput
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                width: parent.width

                //% "Enter your password…"
                placeholderText: qsTrId("enter-your-password…")
                //% "Password"
                label: qsTrId("password")
                textField.echoMode: TextInput.Password
                validationError: popup.passwordValidationError
                inputLabel.font.pixelSize: 15
                inputLabel.font.weight: Font.Normal
            }
            // To-Do use StatusInput
            SeedPhraseTextArea {
                id: seedPhraseTextArea
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                width: parent.width - 2*Style.current.padding
            }
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

            enabled: !loading && passwordInput.text !== "" && accountNameInput.text !== "" && accountNameInput.valid && seedPhraseTextArea.correctWordCount

            MessageDialog {
                id: accountError
                title: "Adding the account failed"
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                // TODO the loading doesn't work because the function freezes the view. Might need to use threads
                loading = true
                if (!validate() || !seedPhraseTextArea.validateSeed()) {
                    Global.playErrorSound();
                    return loading = false
                }

                const errMessage = RootStore.addAccountsFromSeed(seedPhraseTextArea.textArea.text, passwordInput.text, accountNameInput.text, accountColorInput.selectedColor, accountNameInput.input.icon.emoji)
                loading = false
                if (errMessage) {
                    Global.playErrorSound();
                    if (Utils.isInvalidPasswordMessage(errMessage)) {
                        //% "Wrong password"
                        popup.passwordValidationError = qsTrId("wrong-password")
                    } else {
                        accountError.text = errMessage
                        accountError.open()
                    }
                    return
                }
                popup.afterAddAccount()
                popup.reset()
                popup.close();
            }
        }
    ]
}
