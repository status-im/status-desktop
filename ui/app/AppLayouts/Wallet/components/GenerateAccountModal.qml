import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    //% "Generate an account"
    title: qsTrId("generate-a-new-account")

    property int marginBetweenInputs: 38
    property string passwordValidationError: ""
    property string accountNameValidationError: ""
    property bool loading: false

    function validate() {
        if (passwordInput.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (passwordInput.text.length < 6) {
            passwordValidationError = qsTr("Password needs to be 6 characters or more")
        } else {
            passwordValidationError = ""
        }

        if (accountNameInput.text === "") {
            //% "You need to enter an account name"
            accountNameValidationError = qsTrId("you-need-to-enter-an-account-name")
        } else {
            accountNameValidationError = ""
        }

        return passwordValidationError === "" && accountNameValidationError === ""
    }

    onOpened: {
        passwordValidationError = "";
        accountNameValidationError = "";
        passwordInput.text = "";
        accountNameInput.text = "";
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

    Input {
        id: accountNameInput
        anchors.top: passwordInput.bottom
        anchors.topMargin: marginBetweenInputs
        //% "Enter an account name..."
        placeholderText: qsTrId("enter-an-account-name...")
        //% "Account name"
        label: qsTrId("account-name")
        validationError: popup.accountNameValidationError
    }

    ColorSelector {
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
        qsTr("Add account")

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
                errorSound.play()
                return loading = false
            }

            const error = walletModel.generateNewAccount(passwordInput.text, accountNameInput.text, accountColorInput.selectedColor)
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
