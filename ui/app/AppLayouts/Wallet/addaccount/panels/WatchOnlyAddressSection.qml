import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../stores"

Column {
    id: root

    property AddAccountStore store

    function reset() {
        addressInput.reset()
    }

    StatusInput {
        id: addressInput
        objectName: "AddAccountPopup-WatchOnlyAddress"
        width: parent.width
        maximumHeight: Constants.addAccountPopup.itemHeight
        minimumHeight: Constants.addAccountPopup.itemHeight
        label: qsTr("Ethereum address or ENS name")
        placeholderText: qsTr("Type or paste ETH address")
        input.multiline: true
        input.rightComponent: StatusButton {
            anchors.verticalCenter: parent.verticalCenter
            borderColor: Theme.palette.primaryColor1
            size: StatusBaseButton.Size.Tiny
            text: qsTr("Paste")
            onClicked: {
                addressInput.text = ""
                addressInput.input.edit.paste()
            }
        }
        validators: [
            StatusAddressOrEnsValidator {
                errorMessage: qsTr("Please enter a valid Ethereum address or ENS name")
            }
        ]

        onTextChanged: {
            if (addressInput.valid) {
                root.store.changeWatchOnlyAccountAddressPostponed(text.trim())
                return
            }
            root.store.cleanWatchOnlyAccountAddress()
        }

        onKeyPressed: {
            root.store.submitAddAccount(event)
        }
    }

    AddressDetails {
        width: parent.width
        addressDetailsItem: root.store.watchOnlyAccAddress
        defaultMessage: qsTr("You will need to import your seed phrase or use your Keycard to transact with this account")
        defaultMessageCondition: addressInput.text === "" || !addressInput.valid
    }
}
