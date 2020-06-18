import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    title: qsTr("Add account from private key")
    height: 600

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]

    onOpened: {
        passwordInput.text = ""
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: passwordInput
        placeholderText: qsTr("Enter your password…")
        label: qsTr("Password")
        textField.echoMode: TextInput.Password
    }


    StyledTextArea {
        id: accountPKeyInput
        anchors.top: passwordInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("Paste the contents of your private key")
        label: qsTr("Private key")
        customHeight: 88
    }

    Input {
        id: accountNameInput
        anchors.top: accountPKeyInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("Enter an account name...")
        label: qsTr("Account name")
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
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: qsTr("Add account >")

        disabled: passwordInput.text === "" || accountNameInput.text === "" || accountPKeyInput.textAreaText === ""

        onClicked : {
            // TODO add message to show validation errors
            if (passwordInput.text === "" || accountNameInput.text === "" || accountPKeyInput.textAreaText === "") return;

            walletModel.addAccountsFromPrivateKey(accountPKeyInput.text, passwordInput.text, accountNameInput.text, selectedColor)
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
