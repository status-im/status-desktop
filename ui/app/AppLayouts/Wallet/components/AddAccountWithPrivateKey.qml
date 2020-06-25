import QtQuick 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    title: qsTr("Add account from private key")
    height: 600

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]
    property string passwordValidationError: ""
    property string privateKeyValidationError: ""
    property string accountNameValidationError: ""
    property bool loading: false

    function validate() {
        if (passwordInput.text === "") {
            passwordValidationError = qsTr("You need to enter a password")
        } else if (passwordInput.text.length < 4) {
            passwordValidationError = qsTr("Password needs to be 4 characters or more")
        } else {
            passwordValidationError = ""
        }

        if (accountNameInput.text === "") {
            accountNameValidationError = qsTr("You need to enter an account name")
        } else {
            accountNameValidationError = ""
        }

        if (accountPKeyInput.text === "") {
            privateKeyValidationError = qsTr("You need to enter a private key")
        } else if (!Utils.isPrivateKey(accountPKeyInput.text)) {
            privateKeyValidationError = qsTr("Enter a valid private key (64 characters hexadecimal string)")
        } else {
            privateKeyValidationError = ""
        }

        return passwordValidationError === "" && privateKeyValidationError === "" && accountNameValidationError === ""
    }

    onOpened: {
        passwordInput.text = ""
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: passwordInput
        placeholderText: qsTr("Enter your password…")
        label: qsTr("Password")
        textField.echoMode: TextInput.Password
        validationError: popup.passwordValidationError
    }


    StyledTextArea {
        id: accountPKeyInput
        anchors.top: passwordInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("Paste the contents of your private key")
        label: qsTr("Private key")
        customHeight: 88
        validationError: popup.privateKeyValidationError
    }

    Input {
        id: accountNameInput
        anchors.top: accountPKeyInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("Enter an account name...")
        label: qsTr("Account name")
        validationError: popup.accountNameValidationError
    }

    Select {
        id: accountColorInput
        anchors.top: accountNameInput.bottom
        anchors.topMargin: marginBetweenInputs
        bgColor: selectedColor
        label: qsTr("Account color")
        selectOptions: Constants.accountColors.map(color => {
            return {
                text: "",
                bgColor: color,
                height: 52,
                onClicked: function () {
                    selectedColor = color
                }
           }
        })
    }

    footer: StyledButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: loading ? qsTr("Loading...") : qsTr("Add account >")

        disabled: loading || passwordInput.text === "" || accountNameInput.text === "" || accountPKeyInput.text === ""

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

            const error = walletModel.addAccountsFromPrivateKey(accountPKeyInput.text, passwordInput.text, accountNameInput.text, selectedColor)
            loading = false
            if (error) {
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
