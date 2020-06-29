import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: sendModalContent
    property alias amountInput: txtAmount
    property var accounts: []
    property var assets: []
    property string defaultAccount: "0x1234"

    property int selectedAccountIndex: 0
    property string selectedAccountAddress: accounts && accounts.length ? accounts[selectedAccountIndex].address : ""
    property string selectedAccountName: accounts && accounts.length ? accounts[selectedAccountIndex].name : ""
    property string selectedAccountIconColor: accounts && accounts.length ? accounts[selectedAccountIndex].iconColor : ""

    property int selectedAssetIndex: 0
    property string selectedAssetName: assets && assets.length ? assets[selectedAssetIndex].name : ""
    property string selectedAssetSymbol: assets && assets.length ? assets[selectedAssetIndex].symbol : ""
    property string selectedAccountValue: assets && assets.length ? assets[selectedAssetIndex].value : ""

    property string passwordValidationError: ""
    property string toValidationError: ""
    property string amountValidationError: ""

    function send() {
        if (!validate()) {
            return;
        }

        let result = walletModel.onSendTransaction(selectedAccountAddress,
                                                   txtTo.text,
                                                   txtAmount.text,
                                                   txtPassword.text)
        console.log(result)
    }

    function validate() {
        if (txtPassword.text === "") {
            passwordValidationError = qsTr("You need to enter a password")
        } else if (txtPassword.text.length < 4) {
            passwordValidationError = qsTr("Password needs to be 4 characters or more")
        } else {
            passwordValidationError = ""
        }

        if (txtTo.text === "") {
            toValidationError = qsTr("You need to enter a destination address")
        } else if (!Utils.isAddress(txtTo.text)) {
            toValidationError = qsTr("This needs to be a valid address (starting with 0x)")
        } else {
            toValidationError = ""
        }

        if (txtAmount.text === "") {
            amountValidationError = qsTr("You need to enter an amount")
        } else if (isNaN(txtAmount.text)) {
            amountValidationError = qsTr("This needs to be a number")
        } else if (parseInt(txtAmount.text, 10) > parseInt(selectedAccountValue, 10)) {
            amountValidationError = qsTr("Amount needs to be lower than your balance (%1)").arg(selectedAccountValue)
        } else {
            amountValidationError = ""
        }

        return passwordValidationError === "" && toValidationError === "" && amountValidationError === ""
    }

    anchors.left: parent.left
    anchors.right: parent.right

    Input {
        id: txtAmount
        label: qsTr("Amount")
        anchors.top: parent.top
        placeholderText: qsTr("Enter amount...")
        validationError: amountValidationError
    }


    Select {
        id: assetTypeSelect
        iconHeight: 24
        iconWidth: 24
        icon:  "../../../img/tokens/" + selectedAssetSymbol.toUpperCase() + ".png"
        label: qsTr("Select the asset")
        anchors.top: txtAmount.bottom
        anchors.topMargin: Theme.padding
        selectedText: selectedAssetName
        selectOptions: sendModalContent.assets.map(function (asset, index) {
            return {
                text: asset.name,
                onClicked: function () {
                    selectedAssetIndex = index
                }
            }
        })
    }

    StyledText {
        id: currentBalanceText
        text: qsTr("Balance: %1").arg(selectedAccountValue)
        font.pixelSize: 13
        color: Theme.darkGrey
        anchors.top: assetTypeSelect.top
        anchors.topMargin: 0
        anchors.right: assetTypeSelect.right
        anchors.rightMargin: 0
    }

    Select {
        id: txtFrom
        iconHeight: 12
        iconWidth: 12
        icon: "../../../img/walletIcon.svg"
        iconColor: selectedAccountIconColor
        label: qsTr("From account")
        anchors.top: assetTypeSelect.bottom
        anchors.topMargin: Theme.padding
        selectedText: selectedAccountName
        selectOptions: sendModalContent.accounts.map(function (account, index) {
            return {
                text: account.name,
                onClicked: function () {
                    selectedAccountIndex = index
                }
            }
        })
    }

    StyledText {
        id: textSelectAccountAddress
        text: selectedAccountAddress
        font.family: Theme.fontHexRegular.name
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: 2
        elide: Text.ElideMiddle
        anchors.top: txtFrom.bottom
        font.pixelSize: 12
        color: Theme.darkGrey
    }

    Input {
        id: txtTo
        label: qsTr("Recipient")
        text: defaultAccount
        placeholderText: qsTr("Send to")
        anchors.top: textSelectAccountAddress.bottom
        anchors.topMargin: Theme.padding
        validationError: toValidationError
    }

    Input {
        id: txtPassword
        label: qsTr("Password")
        placeholderText: qsTr("Enter Password")
        anchors.top: txtTo.bottom
        anchors.topMargin: Theme.padding
        textField.echoMode: TextInput.Password
        validationError: passwordValidationError
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
