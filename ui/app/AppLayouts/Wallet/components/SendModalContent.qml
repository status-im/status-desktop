import QtQuick 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"

Item {
    id: sendModalContent
    property var closePopup: function(){}
    property alias amountInput: txtAmount
    property alias passwordInput: txtPassword
    property var accounts: []
    property var assets: []

    property int selectedAccountIndex: 0
    property string selectedAccountAddress: accounts && accounts.length ? accounts[selectedAccountIndex].address : ""
    property string selectedAccountName: accounts && accounts.length ? accounts[selectedAccountIndex].name : ""
    property string selectedAccountIconColor: accounts && accounts.length ? accounts[selectedAccountIndex].iconColor : ""

    property int selectedAssetIndex: 0
    property string selectedAssetName: assets && assets.length ? assets[selectedAssetIndex].name : ""
    property string selectedAssetAddress: assets && assets.length ? assets[selectedAssetIndex].address : ""
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
                                                   selectedAssetAddress,
                                                   txtAmount.text,
                                                   txtPassword.text)

        if (!result.startsWith('0x')) {
            // It's an error
            sendingError.text = result
            return sendingError.open()
        }

        sendingSuccess.text = qsTr("Transaction sent to the blockchain. You can watch the progress on Etherscan: %2/%1").arg(result).arg(walletModel.etherscanLink)
        sendingSuccess.open()
    }

    function validate() {
        if (txtPassword.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (txtPassword.text.length < 4) {
            //% "Password needs to be 4 characters or more"
            passwordValidationError = qsTrId("password-needs-to-be-4-characters-or-more")
        } else {
            passwordValidationError = ""
        }

        if (txtTo.text === "") {
            //% "You need to enter a destination address"
            toValidationError = qsTrId("you-need-to-enter-a-destination-address")
        } else if (!Utils.isAddress(txtTo.text)) {
            //% "This needs to be a valid address (starting with 0x)"
            toValidationError = qsTrId("this-needs-to-be-a-valid-address-(starting-with-0x)")
        } else {
            toValidationError = ""
        }

        if (txtAmount.text === "") {
            //% "You need to enter an amount"
            amountValidationError = qsTrId("you-need-to-enter-an-amount")
        } else if (isNaN(txtAmount.text)) {
            //% "This needs to be a number"
            amountValidationError = qsTrId("this-needs-to-be-a-number")
        } else if (parseFloat(txtAmount.text) > parseFloat(selectedAccountValue)) {
            //% "Amount needs to be lower than your balance (%1)"
            amountValidationError = qsTrId("amount-needs-to-be-lower-than-your-balance-(%1)").arg(selectedAccountValue)
        } else {
            amountValidationError = ""
        }

        return passwordValidationError === "" && toValidationError === "" && amountValidationError === ""
    }

    anchors.left: parent.left
    anchors.right: parent.right

    MessageDialog {
        id: sendingError
        title: "Error sending the transaction"
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
    MessageDialog {
        id: sendingSuccess
        //% "Success sending the transaction"
        title: qsTrId("success-sending-the-transaction")
        icon: StandardIcon.NoIcon
        standardButtons: StandardButton.Ok
        onAccepted: {
            closePopup()
        }
    }

    Input {
        id: txtAmount
        //% "Amount"
        label: qsTrId("amount")
        anchors.top: parent.top
        //% "Enter amount..."
        placeholderText: qsTrId("enter-amount...")
        validationError: amountValidationError
    }


    Select {
        id: assetTypeSelect
        iconHeight: 24
        iconWidth: 24
        icon:  "../../../img/tokens/" + selectedAssetSymbol.toUpperCase() + ".png"
        //% "Select the asset"
        label: qsTrId("select-the-asset")
        anchors.top: txtAmount.bottom
        anchors.topMargin: Style.current.padding
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
        //% "Balance: %1"
        text: qsTrId("balance:-%1").arg(selectedAccountValue)
        font.pixelSize: 13
        color: Style.current.darkGrey
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
        //% "From account"
        label: qsTrId("from-account")
        anchors.top: assetTypeSelect.bottom
        anchors.topMargin: Style.current.padding
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
        font.family: Style.current.fontHexRegular.name
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: 2
        elide: Text.ElideMiddle
        anchors.top: txtFrom.bottom
        font.pixelSize: 12
        color: Style.current.darkGrey
    }

    Input {
        id: txtTo
        //% "Recipient"
        label: qsTrId("recipient")
        //% "Send to"
        placeholderText: qsTrId("send-to")
        anchors.top: textSelectAccountAddress.bottom
        anchors.topMargin: Style.current.padding
        validationError: toValidationError
    }

    Input {
        id: txtPassword
        //% "Password"
        label: qsTrId("password")
        //% "Enter Password"
        placeholderText: qsTrId("biometric-auth-login-ios-fallback-label")
        anchors.top: txtTo.bottom
        anchors.topMargin: Style.current.padding
        textField.echoMode: TextInput.Password
        validationError: passwordValidationError
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
