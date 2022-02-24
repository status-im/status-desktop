import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1

import "../panels"
import "../controls"
import "../views"
import "."

// TODO: replace with StatusModal
ModalPopup {
    id: root
    property var contactsStore

    property alias selectFromAccount: selectFromAccount
    property alias selectRecipient: selectRecipient
    property alias stack: stack
    property var store
    property bool isContact: false

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
            success = root.store.transferEth(
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
            success = root.store.transferTokens(
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

        // Till the method is moved to thread this is handled by a signal to which connection is made in the end of the file
//        if(!success){
//            //% "Invalid transaction parameters"
//            sendingError.text = qsTrId("invalid-transaction-parameters")
//            sendingError.open()
//        }
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
                currency: root.store.currentCurrency
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
                contactsStore: root.contactsStore
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
                currentCurrency: root.store.currentCurrency
                // TODO make those use a debounce
                getFiatValue: root.store.getFiatValue
//                getCryptoValue: RootStore.cryptoValue
                width: stack.width
                onSelectedAssetChanged: if (isValid) { gasSelector.estimateGas() }
                onSelectedAmountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            GasSelector {
                id: gasSelector
                anchors.top: txtAmount.bottom
                anchors.topMargin: Style.current.padding
                gasPrice: parseFloat(root.store.gasPrice)
                getGasEthValue: root.store.getGasEthValue
                getFiatValue: root.store.getFiatValue
                defaultCurrency: root.store.currentCurrency

                width: stack.width
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                   if (!(selectFromAccount.selectedAccount && selectFromAccount.selectedAccount.address &&
                       selectRecipient.selectedRecipient && selectRecipient.selectedRecipient.address &&
                       txtAmount.selectedAsset && txtAmount.selectedAsset.address &&
                       txtAmount.selectedAmount)) {
                        selectedGasLimit = 250000
                        defaultGasLimit = selectedGasLimit
                        return
                    }

                   let gasEstimate = JSON.parse(root.store.estimateGas(
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
                currency: root.store.currentCurrency
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
                signingPhrase: root.store.signingPhrase
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
                            Global.openPopup(transactionSettingsConfirmationPopupComponent, {
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

        // Not Refactored Yet
        Connections {
            target: root.store.walletSectionTransactionsInst
            onTransactionSent: {
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

                    // % "Transaction pending..."
                    Global.toastMessage.title = qsTrId("ens-transaction-pending")
                    Global.toastMessage.source = Style.svg("loading")
                    Global.toastMessage.iconColor = Style.current.primary
                    Global.toastMessage.iconRotates = true
                    // Refactor this
//                    Global.toastMessage.link = `${walletModel.utilsView.etherscanLink}/${response.result}`
                    Global.toastMessage.open()
                    root.close()
                } catch (e) {
                    console.error('Error parsing the response', e)
                }
            }
//            onTransactionCompleted: {
//                if (success) {
//                    //% "Transaction completed"
//                    Global.toastMessage.title = qsTrId("transaction-completed")
//                    Global.toastMessage.source = Style.svg("check-circle")
//                    Global.toastMessage.iconColor = Style.current.success
//                } else {
//                    //% "Transaction failed"
//                    Global.toastMessage.title = qsTrId("ens-registration-failed-title")
//                    Global.toastMessage.source = Style.svg("block-icon")
//                    Global.toastMessage.iconColor = Style.current.danger
//                }
//                Global.toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txHash}`
//                Global.toastMessage.open()
//            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

