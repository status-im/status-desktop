import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

import "../stores"
import "../views"

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
        accountNameInput.text = "";
        accountNameInput.reset()
        accountNameInput.input.icon.emoji = StatusQUtils.Emoji.getRandomEmoji()
        colorSelectionGrid.selectedColorIndex = Math.floor(Math.random() * colorSelectionGrid.model.length)
        advancedSelection.expanded = false
        advancedSelection.reset()
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Connections {
        enabled: popup.opened
        target: emojiPopup
        onEmojiSelected: function (emojiText, atCursor) {
            accountNameInput.input.icon.emoji = emojiText
        }
    }

    contentItem: ScrollView {
        width: popup.width
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        topPadding: Style.current.halfPadding
        bottomPadding: Style.current.halfPadding
        height: 400
        clip: true

        Column {
            property alias accountNameInput: accountNameInput
            width: popup.width
            spacing: Style.current.halfPadding
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
                    popup.emojiPopup.x = popup.x + accountNameInput.x + Style.current.padding
                    popup.emojiPopup.y = popup.y + contentItem.y + accountNameInput.y + accountNameInput.height +  Style.current.halfPadding
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

            StatusExpandableItem {
                id: advancedSelection

                property bool isValid: true

                function validate() {
                    if(expandableItem) {
                        return expandableItem.validate()
                    }
                }

                function reset() {
                    if(expandableItem) {
                        return expandableItem.reset()
                    }
                }

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width

                //% "Advanced"
                primaryText: qsTr("Advanced")
                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                expandableComponent: AdvancedAddAccountView {
                    width: parent.width
                    Layout.margins: Style.current.padding
                    Component.onCompleted: advancedSelection.isValid = Qt.binding(function(){return isValid})
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: nextButton
            text: loading ?
                      //% "Loading..."
                      qsTrId("loading") :
                      //% "Add account"
                      qsTrId("add-account")

            enabled: !loading && passwordInput.text !== "" && accountNameInput.text !== "" && advancedSelection.isValid

            MessageDialog {
                id: accountError
                title: "Adding the account failed"
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                // TODO the loaidng doesn't work because the function freezes th eview. Might need to use threads
                loading = true
                if (!validate() || !advancedSelection.validate()) {
                    Global.playErrorSound();
                    return loading = false
                }

                let emoji =  StatusQUtils.Emoji.deparseFromParse(accountNameInput.input.icon.emoji)

                var errMessage = ""
                if(advancedSelection.expandableItem) {
                    switch(advancedSelection.expandableItem.addAccountType) {
                    case AdvancedAddAccountView.AddAccountType.GenerateNew:
                        errMessage = RootStore.generateNewAccount(passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, emoji)
                        break
                    case AdvancedAddAccountView.AddAccountType.ImportSeedPhrase:
                        errMessage = RootStore.addAccountsFromSeed(advancedSelection.expandableItem.mnemonicText, passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, emoji)
                        break
                    case AdvancedAddAccountView.AddAccountType.ImportPrivateKey:
                        errMessage = RootStore.addAccountsFromPrivateKey(advancedSelection.expandableItem.privateKey, passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, emoji)
                        break
                    case AdvancedAddAccountView.AddAccountType.WatchOnly:
                        errMessage = RootStore.addWatchOnlyAccount(advancedSelection.expandableItem.watchAddress, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji)
                        break
                    }
                } else {
                    errMessage = RootStore.generateNewAccount(passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, emoji)
                }

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
