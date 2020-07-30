import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    height: 600

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]
    property string passwordValidationError: ""
    property string seedValidationError: ""
    property string accountNameValidationError: ""
    property bool loading: false

    function validate() {
        if (passwordInput.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (passwordInput.text.length < 4) {
            //% "Password needs to be 4 characters or more"
            passwordValidationError = qsTrId("password-needs-to-be-4-characters-or-more")
        } else {
            passwordValidationError = ""
        }

        if (accountNameInput.text === "") {
            //% "You need to enter an account name"
            accountNameValidationError = qsTrId("you-need-to-enter-an-account-name")
        } else {
            accountNameValidationError = ""
        }

        if (accountSeedInput.text === "") {
            //% "You need to enter a seed phrase"
            seedValidationError = qsTrId("you-need-to-enter-a-seed-phrase")
        } else if (!Utils.isMnemonic(accountSeedInput.text)) {
            //% "Enter a valid mnemonic"
            seedValidationError = qsTrId("enter-a-valid-mnemonic")
        } else {
            seedValidationError = ""
        }

        return passwordValidationError === "" && seedValidationError === "" && accountNameValidationError === ""
    }

    onOpened: {
        passwordInput.text = ""
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    //% "Add account with a seed phrase"
    title: qsTrId("add-seed-account")

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
        id: accountSeedInput
        anchors.top: passwordInput.bottom
        anchors.topMargin: marginBetweenInputs
        //% "Enter your seed phrase, separate words with commas or spaces..."
        placeholderText: qsTrId("enter-your-seed-phrase,-separate-words-with-commas-or-spaces...")
        //% "Seed phrase"
        label: qsTrId("recovery-phrase")
        customHeight: 88
        validationError: popup.seedValidationError
    }

    Input {
        id: accountNameInput
        anchors.top: accountSeedInput.bottom
        anchors.topMargin: marginBetweenInputs
        //% "Enter an account name..."
        placeholderText: qsTrId("enter-an-account-name...")
        //% "Account name"
        label: qsTrId("account-name")
        validationError: popup.accountNameValidationError
    }

    Select {
        id: accountColorInput
        anchors.top: accountNameInput.bottom
        anchors.topMargin: marginBetweenInputs
        bgColor: selectedColor
        //% "Account color"
        label: qsTrId("account-color")
        model: Constants.accountColors
        menu.delegate: Component {
            MenuItem {
                property bool isFirstItem: index === 0
                property bool isLastItem: index === Constants.accountColors.length - 1
                height: 52
                width: parent.width
                padding: 10
                onTriggered: function () {
                    selectedColor = Constants.accountColors[index]
                }
                background: Rectangle {
                    color: Constants.accountColors[index]
                    radius: Style.current.radius

                    // cover bottom left/right corners with square corners
                    Rectangle {
                        visible: !isLastItem
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.radius
                        color: parent.color
                    }

                    // cover top left/right corners with square corners
                    Rectangle {
                        visible: !isFirstItem
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.radius
                        color: parent.color
                    }
                }
            }
        }
    }

    footer: StyledButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        label: loading ?
        //% "Loading..."
        qsTrId("loading") :
        //% "Add account >"
        qsTrId("add-account")

        disabled: loading || passwordInput.text === "" || accountNameInput.text === "" || accountSeedInput.text === ""

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

            const error = walletModel.addAccountsFromSeed(accountSeedInput.text, passwordInput.text, accountNameInput.text, selectedColor)
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
