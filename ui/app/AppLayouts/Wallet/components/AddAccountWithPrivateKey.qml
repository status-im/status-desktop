import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    //% "Add account from private key"
    title: qsTrId("add-private-key-account")
    height: 600

    property int marginBetweenInputs: 38
    property string passwordValidationError: ""
    property string privateKeyValidationError: ""
    property string accountNameValidationError: ""
    property bool loading: false

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

        if (accountNameInput.text === "") {
            //% "You need to enter an account name"
            accountNameValidationError = qsTrId("you-need-to-enter-an-account-name")
        } else {
            accountNameValidationError = ""
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

        return passwordValidationError === "" && privateKeyValidationError === "" && accountNameValidationError === ""
    }

    onOpened: {
        passwordInput.text = ""
        accountPKeyInput.text = ""
        accountNameInput.text = ""
        passwordValidationError = ""
        privateKeyValidationError = ""
        accountNameValidationError = ""
        accountColorInput.selectedColor = Constants.accountColors[Math.floor(Math.random() * Constants.accountColors.length)]
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: passwordInput
        //% "Enter your password…"
        placeholderText: qsTrId("enter-your-password…")
        //% "Password"
        label: qsTrId("password")
        textField.echoMode: TextInput.Password
        validationError: popup.passwordValidationError
    }


    StyledTextArea {
        id: accountPKeyInput
        anchors.top: passwordInput.bottom
        anchors.topMargin: marginBetweenInputs
        //% "Paste the contents of your private key"
        placeholderText: qsTrId("paste-the-contents-of-your-private-key")
        //% "Private key"
        label: qsTrId("private-key")
        customHeight: 88
        validationError: popup.privateKeyValidationError
    }

    Input {
        id: accountNameInput
        anchors.top: accountPKeyInput.bottom
        anchors.topMargin: marginBetweenInputs
        //% "Enter an account name..."
        placeholderText: qsTrId("enter-an-account-name...")
        //% "Account name"
        label: qsTrId("account-name")
        validationError: popup.accountNameValidationError
    }

    StatusWalletColorSelect {
        id: accountColorInput
        model: Constants.accountColors
        anchors.top: accountNameInput.bottom
        anchors.topMargin: marginBetweenInputs
        anchors.left: parent.left
        anchors.right: parent.right
    }

    footer: StatusButton {
        anchors.top: parent.top
        anchors.right: parent.right
        text: loading ?
        //% "Loading..."
        qsTrId("loading") :
        //% "Add account"
        qsTrId("add-account")

        enabled: !loading && passwordInput.text !== "" && accountNameInput.text !== "" && accountPKeyInput.text !== ""

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

            const error = walletModel.addAccountsFromPrivateKey(accountPKeyInput.text, passwordInput.text, accountNameInput.text, accountColorInput.selectedColor)
            
            loading = false
            if (error) {
                errorSound.play()
                accountError.text = error
                return accountError.open()
            }

            popup.close();
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
