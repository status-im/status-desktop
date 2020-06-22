import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    title: qsTr("Add a watch-only account")

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]
    property string addressError: ""
    property string accountNameValidationError: ""

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
        label: "Add account >"

        disabled: addressInput.text === "" || accountNameInput.text === ""

        onClicked : {
            if (!validate()) {
                return
            }

            walletModel.addWatchOnlyAccount(addressInput.text, accountNameInput.text, selectedColor);
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
