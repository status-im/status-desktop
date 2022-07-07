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
import "../panels"

StatusModal {
    id: popup

    property int marginBetweenInputs: Style.dp(38)
    property string passwordValidationError: ""
    property bool loading: false
    property var emojiPopup: null

    closePolicy: Popup.CloseOnEscape

    signal afterAddAccount()

    header.title: qsTr("Generate an account")

    QtObject {
        id: _internal

        property int numOfItems: 100
        property int pageNumber: 1
        function getDerivedAddressList() {
            if(advancedSelection.expandableItem) {
                var errMessage = ""
                if(advancedSelection.expandableItem.addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase &&
                        !!advancedSelection.expandableItem.path &&
                        !!advancedSelection.expandableItem.mnemonicText) {
                    RootStore.getDerivedAddressListForMnemonic(advancedSelection.expandableItem.mnemonicText, advancedSelection.expandableItem.path, numOfItems, pageNumber)
                }
                else if(!!advancedSelection.expandableItem.path && !!advancedSelection.expandableItem.derivedFromAddress && (passwordInput.text.length >= 6)) {
                    RootStore.getDerivedAddressList(passwordInput.text, advancedSelection.expandableItem.derivedFromAddress, advancedSelection.expandableItem.path, numOfItems, pageNumber)
                }
            }
        }

        property string derivedPathError: RootStore.derivedAddressesError

        onDerivedPathErrorChanged: {
            if(Utils.isInvalidPasswordMessage(derivedPathError))
                popup.passwordValidationError = qsTr("Wrong password")
        }

        function showPasswordError(errMessage) {
            if (errMessage) {
                if (Utils.isInvalidPasswordMessage(errMessage)) {
                    popup.passwordValidationError = qsTr("Wrong password")
                } else {
                    accountError.text = errMessage;
                    accountError.open();
                }
            }
        }

        property var waitTimer: Timer {
            interval: 1000
            running: false
            onTriggered: {
                _internal.getDerivedAddressList()
            }
        }
    }

    function validate() {
        if (advancedSelection.expandableItem.addAccountType === SelectGeneratedAccount.AddAccountType.WatchOnly) {
            return accountNameInput.valid
        }

        if (passwordInput.text === "") {
            passwordValidationError = qsTr("You need to enter a password")
        } else if (passwordInput.text.length < 6) {
            passwordValidationError = qsTr("Password needs to be 6 characters or more")
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
        accountNameInput.input.icon.emoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
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
        leftPadding: Style.current.padding
        rightPadding: Style.current.padding
        height: Style.dp(400)
        clip: true

        Column {
            property alias accountNameInput: accountNameInput
            width: parent.width
            spacing: Style.current.halfPadding
            topPadding: Style.dp(20)

            // To-Do Password hidden option not supported in StatusQ StatusBaseInput
            Item {
                width: parent.width
                height: passwordInput.height
                visible: advancedSelection.expandableItem.addAccountType !== SelectGeneratedAccount.AddAccountType.WatchOnly
                Input {
                    id: passwordInput
                    anchors.fill: parent

                    placeholderText: qsTr("Enter your password…")
                    label: qsTr("Password")
                    textField.echoMode: TextInput.Password
                    validationError: popup.passwordValidationError
                    inputLabel.font.pixelSize: 15
                    inputLabel.font.weight: Font.Normal
                    onTextChanged: {
                        popup.passwordValidationError = ""
                        _internal.waitTimer.restart()
                    }
                }
            }

            StatusInput {
                id: accountNameInput
                input.placeholderText: qsTr("Enter an account name...")
                label: qsTr("Account name")
                input.isIconSelectable: true
                input.icon.color: colorSelectionGrid.selectedColor ? colorSelectionGrid.selectedColor : Theme.palette.directColor1
                input.leftPadding: Style.current.padding
                onIconClicked: {
                    popup.emojiPopup.open()
                    popup.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall
                    popup.emojiPopup.x = popup.x + accountNameInput.x + Style.current.padding
                    popup.emojiPopup.y = popup.y + contentItem.y + accountNameInput.y + accountNameInput.height +  Style.current.halfPadding
                }
                validators: [
                    StatusMinLengthValidator {
                        errorMessage: qsTr("You need to enter an account name")
                        minLength: 1
                    }
                ]
            }

            StatusColorSelectorGrid {
                id: colorSelectionGrid
                anchors.horizontalCenter: parent.horizontalCenter
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

                primaryText: qsTr("Advanced")
                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                expandableComponent: AdvancedAddAccountView {
                    width: parent.width
                    Component.onCompleted: advancedSelection.isValid = Qt.binding(function(){return isValid})
                    onCalculateDerivedPath: _internal.getDerivedAddressList()
                    onEnterPressed: {
                        if (nextButton.enabled) {
                            nextButton.clicked(null)
                            return
                        }
                    }
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: nextButton
            text: loading ?
                      qsTr("Loading...") :
                      qsTr("Add account")

            enabled: {
                if (loading) {
                    return false
                }

                return (advancedSelection.expandableItem.addAccountType === SelectGeneratedAccount.AddAccountType.WatchOnly || passwordInput.text !== "") &&
                    accountNameInput.text !== "" &&
                    advancedSelection.isValid
            }

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
                    case SelectGeneratedAccount.AddAccountType.GenerateNew:
                        errMessage = RootStore.generateNewAccount(passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji, advancedSelection.expandableItem.completePath, advancedSelection.expandableItem.derivedFromAddress)
                        break
                    case SelectGeneratedAccount.AddAccountType.ImportSeedPhrase:
                        errMessage = RootStore.addAccountsFromSeed(advancedSelection.expandableItem.mnemonicText, passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji, advancedSelection.expandableItem.completePath)
                        break
                    case SelectGeneratedAccount.AddAccountType.ImportPrivateKey:
                        errMessage = RootStore.addAccountsFromPrivateKey(advancedSelection.expandableItem.privateKey, passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji)
                        break
                    case SelectGeneratedAccount.AddAccountType.WatchOnly:
                        errMessage = RootStore.addWatchOnlyAccount(advancedSelection.expandableItem.watchAddress, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji)
                        break
                    }
                } else {
                    errMessage = RootStore.generateNewAccount(passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.icon.emoji, advancedSelection.expandableItem.completePath, advancedSelection.expandableItem.derivedFromAddress)
                }

                loading = false
                _internal.showPasswordError(errMessage)

                popup.afterAddAccount();
                popup.close();
            }
        }
    ]
}
