import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"

Item {
    id: sendModalContent
    property var closePopup: function(){}
    property alias amountInput: txtAmount
    property alias passwordInput: transactionSigner.passwordInput

    property string passwordValidationError: ""

    function send() {
        if (!validate() || !validatePassword()) {
            return;
        }
        let result = walletModel.onSendTransaction(selectFromAccount.selectedAccount.address,
                                                   selectRecipient.selectedRecipient,
                                                   txtAmount.selectedAsset.address,
                                                   txtAmount.text,
                                                   transactionSigner.passwordInput.text)

        if (!result.startsWith('0x')) {
            // It's an error
            sendingError.text = result
            return sendingError.open()
        }

        sendingSuccess.text = qsTr("Transaction sent to the blockchain. You can watch the progress on Etherscan: %2/%1").arg(result).arg(walletModel.etherscanLink)
        sendingSuccess.open()
    }

    function validatePassword() {
        if (transactionSigner.passwordInput.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (transactionSigner.passwordInput.text.length < 4) {
            //% "Password needs to be 4 characters or more"
            passwordValidationError = qsTrId("password-needs-to-be-4-characters-or-more")
        } else {
            passwordValidationError = ""
        }
        
        return passwordValidationError === "" 
    }

    function validate() {
        const isRecipientValid = selectRecipient.validate()
        const isAssetAndAmountValid = txtAmount.validate()

        return isRecipientValid && isAssetAndAmountValid
    }

    function showPreview() {
        pvwTransaction.visible = true
        transactionSigner.visible = true
        txtAmount.visible = selectFromAccount.visible = selectRecipient.visible = gasSelector.visible = false
    }

    function showInputs() {
        pvwTransaction.visible = false
        transactionSigner.visible = false
        txtAmount.visible = selectFromAccount.visible = selectRecipient.visible = gasSelector.visible = true
    }

    anchors.left: parent.left
    anchors.right: parent.right

    MessageDialog {
        id: sendingError
        title: "Error sending the transaction"
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
        onAccepted: {
            sendModalContent.showInputs()
        }
    }
    MessageDialog {
        id: sendingSuccess
        //% "Success sending the transaction"
        title: qsTrId("success-sending-the-transaction")
        icon: StandardIcon.NoIcon
        standardButtons: StandardButton.Ok
        onAccepted: {
            closePopup()
            sendModalContent.showInputs()
        }
    }

    AssetAndAmountInput {
        id: txtAmount
        selectedAccount: walletModel.currentAccount
        defaultCurrency: walletModel.defaultCurrency
        anchors.top: parent.top
        getFiatValue: walletModel.getFiatValue
        getCryptoValue: walletModel.getCryptoValue
    }

    AccountSelector {
        id: selectFromAccount
        accounts: walletModel.accounts
        currency: walletModel.defaultCurrency
        anchors.top: txtAmount.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right
        label: qsTr("From account")
        onSelectedAccountChanged: {
            txtAmount.selectedAccount = selectFromAccount.selectedAccount
        }
    }

    GasSelector {
      id: gasSelector
      anchors.top: selectFromAccount.bottom
      anchors.topMargin: Style.current.bigPadding
      slowestGasPrice: walletModel.safeLowGasPrice
      fastestGasPrice: walletModel.fastestGasPrice
      getGasEthValue: walletModel.getGasEthValue
      getFiatValue: walletModel.getFiatValue
      defaultCurrency: walletModel.defaultCurrency
    }

    RecipientSelector {
        id: selectRecipient
        accounts: walletModel.accounts
        contacts: profileModel.addedContacts
        label: qsTr("Recipient")
        anchors.top: gasSelector.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right
    }

    TransactionPreview {
        id: pvwTransaction
        visible: false
        anchors.left: parent.left
        anchors.right: parent.right
        fromAccount: selectFromAccount.selectedAccount
        gas: {
            const value = walletModel.getGasEthValue(gasSelector.selectedGasPrice, gasSelector.selectedGasLimit)
            const fiatValue = walletModel.getFiatValue(value, "ETH", walletModel.defaultCurrency)
            return { value, "symbol": "ETH", fiatValue }
        }
        toAccount: selectRecipient.selectedRecipient
        asset: txtAmount.selectedAsset
        amount: { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount }
        currency: walletModel.defaultCurrency
    }

    TransactionSigner {
        id: transactionSigner
        visible: false
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: pvwTransaction.bottom
        anchors.topMargin: Style.current.smallPadding
        signingPhrase: walletModel.signingPhrase
        validationError: sendModalContent.passwordValidationError
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
