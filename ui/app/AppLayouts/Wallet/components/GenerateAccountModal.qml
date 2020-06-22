import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    title: qsTr("Generate an account")

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]
    property string passwordValidationError: ""
    property string accountNameValidationError: ""

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

        return passwordValidationError === "" && accountNameValidationError === ""
    }

    onOpened: {
        passwordInput.text = "";
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: passwordInput
        placeholderText: qsTr("Enter your password…")
        label: qsTr("Password")
        textField.echoMode: TextInput.Password
        validationError: popup.passwordValidationError
    }

    Input {
        id: accountNameInput
        anchors.top: passwordInput.bottom
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
        label: "Add account >"

        disabled: passwordInput.text === "" || accountNameInput.text === ""

        onClicked : {
            if (!validate()) {
                return
            }

            walletModel.generateNewAccount(passwordInput.text, accountNameInput.text, selectedColor);
            // TODO manage errors adding account
            popup.close();
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
