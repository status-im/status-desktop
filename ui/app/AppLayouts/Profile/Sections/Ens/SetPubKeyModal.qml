import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../../imports"
import "../../../../../shared"

ModalPopup {
    id: root
    readonly property var asset: {"name": "Ethereum", "symbol": "ETH"}
    property string ensUsername: ""

    //% "Connect username with your pubkey"
    title: qsTrId("connect-username-with-your-pubkey")

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    function sendTransaction() {
        try {
            let responseStr = profileModel.ens.setPubKey(root.ensUsername,
                                                        selectFromAccount.selectedAccount.address,
                                                        gasSelector.selectedGasLimit,
                                                        gasSelector.selectedGasPrice,
                                                        transactionSigner.enteredPassword)
            let response = JSON.parse(responseStr)

            if (!response.success) {
                if (response.error.message.includes("could not decrypt key with given password")){
                    //% "Wrong password"
                    transactionSigner.validationError = qsTrId("wrong-password")
                    return
                }
                sendingError.text = response.error.message
                return sendingError.open()
            }

            usernameUpdated(root.ensUsername);
        } catch (e) {
            console.error('Error sending the transaction', e)
            sendingError.text = "Error sending the transaction: " + e.message;
            return sendingError.open()
        }
    }

    TransactionStackView {
        id: stack
        height: parent.height
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.label = group.footerText
        }
        TransactionFormGroup {
            id: group1
            //% "Connect username with your pubkey"
            headerText: qsTrId("connect-username-with-your-pubkey")
            //% "Continue"
            footerText: qsTrId("continue")

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                //% "Choose account"
                label: qsTrId("choose-account")
                showBalanceForAssetSymbol: "ETH"
                minRequiredAssetBalance: 0
                onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: walletModel.accounts
                contacts: profileModel.contacts.addedContacts
                selectedRecipient: { "address": utilsModel.ensRegisterAddress, "type": RecipientSelector.Type.Address }
                readOnly: true
                onSelectedRecipientChanged: if (isValid) { gasSelector.estimateGas() }
            }
            GasSelector {
                id: gasSelector
                visible: false
                slowestGasPrice: parseFloat(walletModel.safeLowGasPrice)
                fastestGasPrice: parseFloat(walletModel.fastestGasPrice)
                getGasEthValue: walletModel.getGasEthValue
                getFiatValue: walletModel.getFiatValue
                defaultCurrency: walletModel.defaultCurrency
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    if (!(root.ensUsername !== "" && selectFromAccount.selectedAccount)) {
                        selectedGasLimit = 80000;
                        return;
                    }
                    selectedGasLimit = profileModel.ens.setPubKeyGasEstimate(root.ensUsername, selectFromAccount.selectedAccount.address)
                })
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: selectFromAccount.selectedAccount
                selectedAsset: root.asset
                selectedAmount: 0
                selectedGasEthValue: gasSelector.selectedGasEthValue
            }
        }
        TransactionFormGroup {
            id: group3
            //% "Connect username with your pubkey"
            headerText: qsTrId("connect-username-with-your-pubkey")
            //% "Sign with password"
            footerText: qsTrId("sign-with-password")

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: selectFromAccount.selectedAccount
                gas: {
                    "value": gasSelector.selectedGasEthValue,
                    "symbol": "ETH",
                    "fiatValue": gasSelector.selectedGasFiatValue
                }
                toAccount: selectRecipient.selectedRecipient
                asset: root.asset
                currency: walletModel.defaultCurrency
                amount: {
                    const fiatValue = walletModel.getFiatValue(0, root.asset.symbol, currency)
                    return { "value": 0, "fiatValue": fiatValue }
                }
            }
        }
        TransactionFormGroup {
            id: group4
            //% "Connect username with your pubkey"
            headerText: qsTrId("connect-username-with-your-pubkey")
            //% "Sign with password"
            footerText: qsTrId("sign-with-password")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: walletModel.signingPhrase
            }
        }
    }

    footer: Item {
        width: parent.width
        height: btnNext.height
        
        StyledButton {
            id: btnNext
            anchors.right: parent.right
            //% "Next"
            label: qsTrId("next")
            disabled: !stack.currentGroup.isValid
            onClicked: {
                const validity = stack.currentGroup.validate() 
                if (validity.isValid && !validity.isPending) { 
                    if (stack.isLastGroup) {
                        return root.sendTransaction()
                    }
                    stack.next()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
