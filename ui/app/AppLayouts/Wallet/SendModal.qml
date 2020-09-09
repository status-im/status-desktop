import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"

ModalPopup {
    id: root

    //% "Send"
    title: qsTrId("command-button-send")
    height: 504

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
    property MessageDialog sendingSuccess: MessageDialog {
        id: sendingSuccess
        //% "Success sending the transaction"
        title: qsTrId("success-sending-the-transaction")
        icon: StandardIcon.NoIcon
        standardButtons: StandardButton.Ok
        onAccepted: {
            root.close()
        }
    }

    onClosed: {
        stack.reset()
    }

    function sendTransaction() {
        let responseStr = walletModel.sendTransaction(selectFromAccount.selectedAccount.address,
                                                 selectRecipient.selectedRecipient.address,
                                                 txtAmount.selectedAsset.address,
                                                 txtAmount.selectedAmount,
                                                 gasSelector.selectedGasLimit,
                                                 gasSelector.selectedGasPrice,
                                                 transactionSigner.enteredPassword)
        let response = JSON.parse(responseStr)

        if (response.error) {
            if (response.error.message.includes("could not decrypt key with given password")){
                transactionSigner.validationError = qsTr("Wrong password")
                return
            }
            sendingError.text = response.error.message
            return sendingError.open()
        }

        sendingSuccess.text = qsTr("Transaction sent to the blockchain. You can watch the progress on Etherscan: %2/%1").arg(response.result).arg(walletModel.etherscanLink)
        sendingSuccess.open()
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.label = group.footerText
        }
        TransactionFormGroup {
            id: group1
            headerText: qsTr("Send")
            footerText: qsTr("Continue")

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                label: qsTr("From account")
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    selectedAccount = Qt.binding(function() { return walletModel.currentAccount })
                }
            }
            SeparatorWithIcon {
                id: separator
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: 19
            }
            RecipientSelector {
                id: selectRecipient
                accounts: walletModel.accounts
                contacts: profileModel.addedContacts
                label: qsTr("Recipient")
                anchors.top: separator.bottom
                anchors.topMargin: 10
                width: stack.width
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    contacts = Qt.binding(function() { return profileModel.addedContacts })
                    selectedRecipient = {}
                }
            }
        }
        TransactionFormGroup {
            id: group2
            headerText: qsTr("Send")
            footerText: qsTr("Preview")

            AssetAndAmountInput {
                id: txtAmount
                selectedAccount: selectFromAccount.selectedAccount
                defaultCurrency: walletModel.defaultCurrency
                getFiatValue: walletModel.getFiatValue
                getCryptoValue: walletModel.getCryptoValue
                width: stack.width
                reset: function() {
                    selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                }
            }
            GasSelector {
                id: gasSelector
                anchors.top: txtAmount.bottom
                anchors.topMargin: Style.current.bigPadding * 2
                slowestGasPrice: parseFloat(walletModel.safeLowGasPrice)
                fastestGasPrice: parseFloat(walletModel.fastestGasPrice)
                getGasEthValue: walletModel.getGasEthValue
                getFiatValue: walletModel.getFiatValue
                defaultCurrency: walletModel.defaultCurrency
                width: stack.width
                reset: function() {
                    slowestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.safeLowGasPrice) })
                    fastestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.fastestGasPrice) })
                }
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: selectFromAccount.selectedAccount
                selectedAmount: parseFloat(txtAmount.selectedAmount)
                selectedAsset: txtAmount.selectedAsset
                selectedGasEthValue: gasSelector.selectedGasEthValue
                reset: function() {
                    selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    selectedAmount = Qt.binding(function() { return parseFloat(txtAmount.selectedAmount) })
                    selectedAsset = Qt.binding(function() { return txtAmount.selectedAsset })
                    selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
                }
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Transaction preview")
            footerText: qsTr("Sign with password")

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
                asset: txtAmount.selectedAsset
                amount: { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount }
                currency: walletModel.defaultCurrency
                reset: function() {
                    fromAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    toAccount = Qt.binding(function() { return selectRecipient.selectedRecipient })
                    asset = Qt.binding(function() { return txtAmount.selectedAsset })
                    amount = Qt.binding(function() { return { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount } })
                    gas = Qt.binding(function() {
                        return {
                            "value": gasSelector.selectedGasEthValue,
                            "symbol": "ETH",
                            "fiatValue": gasSelector.selectedGasFiatValue
                        }
                    })
                }
            }
        }
        TransactionFormGroup {
            id: group4
            headerText: qsTr("Sign with password")
            footerText: qsTr("Send %1 %2").arg(txtAmount.selectedAmount).arg(!!txtAmount.selectedAsset ? txtAmount.selectedAsset.symbol : "")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: walletModel.signingPhrase
                reset: function() {
                    signingPhrase = Qt.binding(function() { return walletModel.signingPhrase })
                }
            }
        }
    }

    footer: Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        StyledButton {
            id: btnBack
            anchors.left: parent.left
            width: 44
            height: 44
            visible: !stack.isFirstGroup
            label: ""
            background: Rectangle {
                anchors.fill: parent
                border.width: 0
                radius: width / 2
                color: btnBack.disabled ? Style.current.grey :
                        btnBack.hovered ? Qt.darker(btnBack.btnColor, 1.1) : btnBack.btnColor

                SVGImage {
                    width: 20.42
                    height: 15.75
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../../img/arrow-right.svg"
                    rotation: 180
                }
            }
            onClicked: {
                stack.back()
            }
        }
        StyledButton {
            id: btnNext
            anchors.right: parent.right
            label: qsTr("Next")
            disabled: !stack.currentGroup.isValid || stack.currentGroup.isPending
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

