import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Controls 0.1

import "../panels"
import "../controls"
import "../views"
import "."

// TODO: replace with StatusModal
ModalPopup {
    id: root
    property alias selectFromAccount: selectFromAccount
    property alias selectRecipient: selectRecipient
    property alias stack: stack
    property var store

    //% "Send"
    title: qsTrId("command-button-send")
    height: 540

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    function sendTransaction() {
        stack.currentGroup.isPending = true
        let success = false
        if(txtAmount.selectedAsset.address === "" || txtAmount.selectedAsset.address === Constants.zeroAddress){
            success = walletModel.transactionsView.transferEth(
                                                 selectFromAccount.selectedAccount.address,
                                                 selectRecipient.selectedRecipient.address,
                                                 txtAmount.selectedAmount,
                                                 gasSelector.selectedGasLimit,
                                                 gasSelector.eip1599Enabled ? "" : gasSelector.selectedGasPrice,
                                                 gasSelector.selectedTipLimit,
                                                 gasSelector.selectedOverallLimit,
                                                 transactionSigner.enteredPassword,
                                                 stack.uuid)
        } else {
            success = walletModel.transactionsView.transferTokens(
                                                 selectFromAccount.selectedAccount.address,
                                                 selectRecipient.selectedRecipient.address,
                                                 txtAmount.selectedAsset.address,
                                                 txtAmount.selectedAmount,
                                                 gasSelector.selectedGasLimit,
                                                 gasSelector.eip1599Enabled ? "" : gasSelector.selectedGasPrice,
                                                 gasSelector.selectedTipLimit,
                                                 gasSelector.selectedOverallLimit,
                                                 transactionSigner.enteredPassword,
                                                 stack.uuid)
        }

        if(!success){
            //% "Invalid transaction parameters"
            sendingError.text = qsTrId("invalid-transaction-parameters")
            sendingError.open()
        }
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }
        TransactionFormGroup {
            id: group1
            //% "Send"
            headerText: qsTrId("command-button-send")
            //% "Continue"
            footerText: qsTrId("continue")

            StatusAccountSelector {
                id: selectFromAccount
                accounts: root.store.accounts
                selectedAccount: {
                    const currAcc = root.store.currentAccount
                    if (currAcc.walletType !== Constants.watchWalletType) {
                        return currAcc
                    }
                    return null
                }
                currency: walletModel.balanceView.defaultCurrency
                width: stack.width
                //% "From account"
                label: qsTrId("from-account")
                onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            SeparatorWithIcon {
                id: separator
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: 19
            }
            RecipientSelector {
                id: selectRecipient
                accounts: root.store.accounts
                contacts: popup.store.addedContacts
                //% "Recipient"
                label: qsTrId("recipient")
                anchors.top: separator.bottom
                anchors.topMargin: 10
                width: stack.width
                onSelectedRecipientChanged: if (isValid) { gasSelector.estimateGas() }
            }
        }
        TransactionFormGroup {
            id: group2
            //% "Send"
            headerText: qsTrId("command-button-send")
            //% "Preview"
            footerText: qsTr("Continue")

            AssetAndAmountInput {
                id: txtAmount
                selectedAccount: selectFromAccount.selectedAccount
                defaultCurrency: walletModel.balanceView.defaultCurrency
                currentCurrency: walletSection.currentCurrency
                getFiatValue: walletModel.balanceView.getFiatValue
                getCryptoValue: walletModel.balanceView.getCryptoValue
                width: stack.width
                onSelectedAssetChanged: if (isValid) { gasSelector.estimateGas() }
                onSelectedAmountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            GasSelector {
                id: gasSelector
                anchors.top: txtAmount.bottom
                anchors.topMargin: Style.current.padding
                gasPrice: parseFloat(walletModel.gasView.gasPrice)
                getGasEthValue: walletModel.gasView.getGasEthValue
                getFiatValue: walletModel.balanceView.getFiatValue
                defaultCurrency: walletModel.balanceView.defaultCurrency
                
                width: stack.width
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    if (!(selectFromAccount.selectedAccount && selectFromAccount.selectedAccount.address &&
                        selectRecipient.selectedRecipient && selectRecipient.selectedRecipient.address &&
                        txtAmount.selectedAsset && txtAmount.selectedAsset.address &&
                        txtAmount.selectedAmount)) return
                    
                    let gasEstimate = JSON.parse(walletModel.gasView.estimateGas(
                        selectFromAccount.selectedAccount.address,
                        selectRecipient.selectedRecipient.address,
                        txtAmount.selectedAsset.address,
                        txtAmount.selectedAmount,
                        ""))

                    if (!gasEstimate.success) {
                        //% "Error estimating gas: %1"
                        console.warn(qsTrId("error-estimating-gas---1").arg(gasEstimate.error.message))
                        return
                    }

                    selectedGasLimit = gasEstimate.result
                    defaultGasLimit = selectedGasLimit
                })
            }
            GasValidator {
                id: gasValidator
                anchors.top: gasSelector.bottom
                selectedAccount: selectFromAccount.selectedAccount
                selectedAmount: parseFloat(txtAmount.selectedAmount)
                selectedAsset: txtAmount.selectedAsset
                selectedGasEthValue: gasSelector.selectedGasEthValue
            }
        }
        TransactionFormGroup {
            id: group3
            //% "Transaction preview"
            headerText: qsTrId("transaction-preview")
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
                asset: txtAmount.selectedAsset
                amount: { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount }
                currency: walletModel.balanceView.defaultCurrency
            }
            SendToContractWarning {
                id: sendToContractWarning
                anchors.top: pvwTransaction.bottom
                selectedRecipient: selectRecipient.selectedRecipient
            }
        }
        TransactionFormGroup {
            id: group4
            //% "Sign with password"
            headerText: qsTrId("sign-with-password")
            //% "Send %1 %2"
            footerText: qsTrId("send--1--2").arg(txtAmount.selectedAmount).arg(!!txtAmount.selectedAsset ? txtAmount.selectedAsset.symbol : "")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: walletModel.utilsView.signingPhrase
            }
        }
    }

    footer: Item {
        width: parent.width
        height: btnNext.height

        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            visible: !stack.isFirstGroup
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            icon.rotation: 180
            onClicked: {
                stack.back()
            }
        }

        Component {
            id: transactionSettingsConfirmationPopupComponent
            TransactionSettingsConfirmationPopup {
                
            }
        }

        StatusButton {
            id: btnNext
            anchors.right: parent.right
            //% "Next"
            text: qsTrId("next")
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            loading: stack.currentGroup.isPending
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        return root.sendTransaction()
                    }

                    if(gasSelector.eip1599Enabled && stack.currentGroup === group2 && gasSelector.advancedMode){
                        if(gasSelector.showPriceLimitWarning || gasSelector.showTipLimitWarning){
                            openPopup(transactionSettingsConfirmationPopupComponent, {
                                currentBaseFee: gasSelector.latestBaseFeeGwei,
                                currentMinimumTip: gasSelector.perGasTipLimitFloor,
                                currentAverageTip: gasSelector.perGasTipLimitAverage,
                                tipLimit: gasSelector.selectedTipLimit,
                                suggestedTipLimit: gasSelector.perGasTipLimitFloor,
                                priceLimit: gasSelector.selectedOverallLimit,
                                suggestedPriceLimit: gasSelector.latestBaseFeeGwei + gasSelector.perGasTipLimitFloor,
                                showPriceLimitWarning: gasSelector.showPriceLimitWarning,
                                showTipLimitWarning: gasSelector.showTipLimitWarning,
                                onConfirm: function(){
                                    stack.next();
                                }
                            })
                            return
                        }
                    }

                    stack.next()
                }
            }
        }

        Connections {
            target: walletModel.transactionsView
            onTransactionWasSent: {
                try {
                    let response = JSON.parse(txResult)

                    if (response.uuid !== stack.uuid) return
                    
                    stack.currentGroup.isPending = false

                    if (!response.success) {
                        if (Utils.isInvalidPasswordMessage(response.result)){
                            //% "Wrong password"
                            transactionSigner.validationError = qsTrId("wrong-password")
                            return
                        }
                        sendingError.text = response.result
                        return sendingError.open()
                    }

                    //% "Transaction pending..."
                    toastMessage.title = qsTrId("ens-transaction-pending")
                    toastMessage.source = Style.svg("loading")
                    toastMessage.iconColor = Style.current.primary
                    toastMessage.iconRotates = true
                    toastMessage.link = `${walletModel.utilsView.etherscanLink}/${response.result}`
                    toastMessage.open()
                    root.close()
                } catch (e) {
                    console.error('Error parsing the response', e)
                }
            }
            onTransactionCompleted: {
                if (success) {
                    //% "Transaction completed"
                    toastMessage.title = qsTrId("transaction-completed")
                    toastMessage.source = Style.svg("check-circle")
                    toastMessage.iconColor = Style.current.success
                } else {
                    //% "Transaction failed"
                    toastMessage.title = qsTrId("ens-registration-failed-title")
                    toastMessage.source = Style.svg("block-icon")
                    toastMessage.iconColor = Style.current.danger
                }
                toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txHash}`
                toastMessage.open()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

