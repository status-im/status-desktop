import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property int marginBetweenInputs: 38
    property string passwordValidationError: ""
    property bool loading: false
    property var emojiPopup: null

    signal afterAddAccount()

    //% "Generate an account"
    header.title: qsTrId("generate-a-new-account")

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
            return passwordValidationError === "" && accountNameInput.valid
        }

    onOpened: {
        passwordValidationError = "";
        passwordInput.text = "";
        accountNameInput.reset()
        accountNameInput.text = "";
        accountNameInput.input.icon.emoji = StatusQUtils.Emoji.getRandomEmoji()
        colorSelectionGrid.selectedColorIndex = Math.floor(Math.random() * colorSelectionGrid.model.length)
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

        // To-Do Password hidden option not supported in StatusQ StatusBaseInput
        Item {
            width: parent.width
            height: passwordInput.height
            Input {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding

                //% "Enter your password…"
                placeholderText: qsTrId("enter-your-password…")
                //% "Password"
                label: qsTrId("password")
                textField.echoMode: TextInput.Password
                validationError: popup.passwordValidationError
                inputLabel.font.pixelSize: 15
                inputLabel.font.weight: Font.Normal
            }
        }

        StatusInput {
            id: accountNameInput
            //% "Enter an account name..."
            input.placeholderText: qsTrId("enter-an-account-name...")
            //% "Account name"
            label: qsTrId("account-name")
            input.isIconSelectable: true
            input.icon.color: colorSelectionGrid.selectedColor ? colorSelectionGrid.selectedColor : Theme.palette.directColor1
            onIconClicked: {
                popup.emojiPopup.open()
                popup.emojiPopup.x = Global.applicationWindow.width/2 - popup.emojiPopup.width/2 + popup.width/2
                popup.emojiPopup.y = Global.applicationWindow.height/2 - popup.emojiPopup.height/2
            }
            validators: [
                StatusMinLengthValidator {
                    //% "You need to enter an account name"
                    errorMessage: qsTrId("you-need-to-enter-an-account-name")
                    minLength: 1
                }
            ]
        }

        StatusColorSelectorGrid {
            id: colorSelectionGrid
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

            enabled: !loading && passwordInput.text !== "" && accountNameInput.text !== ""

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
                    Global.playErrorSound();
                    return loading = false
                }

                const errMessage = RootStore.generateNewAccount(passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji)
                console.log(errMessage)
                loading = false
                if (errMessage) {
                    Global.playErrorSound();
                    if (Utils.isInvalidPasswordMessage(errMessage)) {
                        //% "Wrong password"
                        popup.passwordValidationError = qsTrId("wrong-password")
                    } else {
                        accountError.text = errMessage;
                        accountError.open();
                    }
                    return
                }
                popup.afterAddAccount();
                popup.close();
            }
        }
    ]
}
