import QtQuick 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../sounds"

ModalPopup {
    id: popup
    title: qsTr("Add a watch-only account")

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]
    property string addressError: ""
    property string accountNameValidationError: ""
    property bool loading: false

    function validate() {
        if (addressInput.text === "") {
            addressError = qsTr("You need to enter an address")
        } else if (!Utils.isAddress(addressInput.text)) {
            addressError = qsTr("This needs to be a valid address (starting with 0x)")
        } else {
            addressError = ""
        }

        if (accountNameInput.text === "") {
            accountNameValidationError = qsTr("You need to enter an account name")
        } else {
            accountNameValidationError = ""
        }

        return addressError === "" && accountNameValidationError === ""
    }

    onOpened: {
        addressInput.text = "";
        addressInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Item {
        ErrorSound {
            id: errorSound
        }
    }

    Input {
        id: addressInput
        // TODO add QR code reader for the address
        placeholderText: qsTr("Enter address...")
        label: qsTr("Account address")
        validationError: popup.addressError
    }

    Input {
        id: accountNameInput
        anchors.top: addressInput.bottom
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

        disabled: loading || addressInput.text === "" || accountNameInput.text === ""

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

            const error = walletModel.addWatchOnlyAccount(addressInput.text, accountNameInput.text, selectedColor);
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
