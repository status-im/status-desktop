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

import shared.panels 1.0
import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property int marginBetweenInputs: 38
    property string passwordValidationError: ""
    property string privateKeyValidationError: ""
    property bool loading: false
    property var emojiPopup: null

    signal afterAddAccount()

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

        if (accountPKeyInput.text === "") {
            //% "You need to enter a private key"
            privateKeyValidationError = qsTrId("you-need-to-enter-a-private-key")
        } else if (!Utils.isPrivateKey(accountPKeyInput.text)) {
            //% "Enter a valid private key (64 characters hexadecimal string)"
            privateKeyValidationError = qsTrId("enter-a-valid-private-key-(64-characters-hexadecimal-string)")
        } else {
            privateKeyValidationError = ""
        }

        return passwordValidationError === "" && privateKeyValidationError === "" && accountNameInput.valid
    }

    //% "Add account from private key"
    header.title: qsTrId("add-private-key-account")

    onOpened: {
        passwordInput.text = ""
        accountPKeyInput.text = ""
        accountNameInput.reset()
        accountNameInput.text = ""
        accountNameInput.input.icon.emoji = StatusQUtils.Emoji.getRandomEmoji()
        passwordValidationError = ""
        privateKeyValidationError = ""
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
            StyledTextArea {
                id: accountPKeyInput
                customHeight: 88
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding

                validationError: popup.privateKeyValidationError
                //% "Private key"
                label: qsTrId("private-key")
                textField.wrapMode: Text.WordWrap
                textField.horizontalAlignment: TextEdit.AlignHCenter
                textField.verticalAlignment: TextEdit.AlignVCenter
                textField.font.weight: Font.DemiBold
                //% "Paste the contents of your private key"
                placeholderText: qsTrId("paste-the-contents-of-your-private-key")
                textField.placeholderTextColor: Style.current.secondaryText
                textField.selectByKeyboard: true
                textField.selectionColor: Style.current.secondaryBackground
                textField.selectedTextColor: Style.current.secondaryText
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

            enabled: !loading && passwordInput.text !== "" && accountNameInput.text !== "" && accountNameInput.valid && accountPKeyInput.text !== ""

            MessageDialog {
                id: accountError
                title: "Adding the account failed"
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                // TODO the loaidng doesn't work because the function freezes th eview. Might need to use threads
                loading = true
                if (!validate()) {
                    return loading = false
                }

                const errMessage = RootStore.addAccountsFromPrivateKey(accountPKeyInput.text, passwordInput.text, accountNameInput.text, accountColorInput.selectedColor, accountNameInput.input.icon.emoji)

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
                popup.close();
            }
        }
    ]
}
