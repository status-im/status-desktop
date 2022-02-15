import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.controls 1.0

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import "../../../app/AppLayouts/Wallet"

StatusModal {
    id: root
    //% "Send"
    header.title: qsTrId("command-button-send")
    height: 540

    property var store
    property var contactsStore

    property var selectedAccount
    property var selectedRecipient
    property var selectedAsset
    property var selectedAmount
    property var selectedFiatAmount
    property var selectedType: RecipientSelector.Type.Address
    property bool outgoing: true
    property string msgId: ""
    property string trxData: ""

    property alias transactionSigner: transactionSigner

    property var sendTransaction: function() {
        stack.currentGroup.isPending = true
        let success = false
        if(root.selectedAsset.address === "" || root.selectedAsset.address === Constants.zeroAddress){
            success = root.store.transferEth(
                        selectFromAccount.selectedAccount.address,
                        selectRecipient.selectedRecipient.address,
                        root.selectedAmount,
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
                        root.selectedAsset.address,
                        root.selectedAmount,
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
        } else {
            // TODO remove this else once the thread and connection are back
            stack.currentGroup.isPending = false
            //% "Transaction pending..."
            Global.toastMessage.title = qsTrId("ens-transaction-pending")
            Global.toastMessage.source = Style.svg("loading")
            Global.toastMessage.iconColor = Style.current.primary
            Global.toastMessage.iconRotates = true
            // Refactor this
            // Global.toastMessage.link = `${walletModel.utilsView.etherscanLink}/${response.result}`
            Global.toastMessage.open()
            root.close()
        }
    }

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
    signal openGasEstimateErrorPopup(string message)

    onClosed: {
        stack.pop(groupPreview, StackView.Immediate)
    }

    contentItem: Item {
        width: root.width
        height: childrenRect.height
        TransactionStackView {
            id: stack
            anchors.leftMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
            initialItem: groupPreview
            isLastGroup: stack.currentGroup === groupSignTx
            onGroupActivated: {
                root.header.title = group.headerText
                btnNext.text = group.footerText
            }
            TransactionFormGroup {
                id: groupSelectAcct
                headerText: {
                    // Not Refactored Yet
//                    if(trxData.startsWith("0x095ea7b3")){
//                        const approveData = JSON.parse(root.store.walletModelInst.tokensView.decodeTokenApproval(selectedRecipient.address, trxData))
//                        if(approveData.symbol)
//                            //% "Authorize %1 %2"
//                            return qsTrId("authorize--1--2").arg(approveData.amount).arg(approveData.symbol)
//                    }
                    return qsTr("Send");
                }
                //% "Continue"
                footerText: qsTrId("continue")
                showNextBtn: false
                onBackClicked: function() {
                    if(validate()) {
                        stack.pop()
                    }
                }
                StatusAccountSelector {
                    id: selectFromAccount
                    accounts: root.store.accounts
                    currency: root.store.currentCurrency
                    width: stack.width
                    selectedAccount: root.selectedAccount
                    //% "Choose account"
                    label: qsTrId("choose-account")
                    showBalanceForAssetSymbol: root.selectedAsset.symbol
                    minRequiredAssetBalance: parseFloat(root.selectedAmount)
                    onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
                }
                RecipientSelector {
                    id: selectRecipient
                    visible: false
                    accounts: root.store.accounts
                    contactsStore: root.contactsStore
                    selectedRecipient: root.selectedRecipient
                    selectedType: root.selectedType
                    readOnly: true
                }
            }
            TransactionFormGroup {
                id: groupSelectGas
                //% "Network fee"
                headerText: qsTrId("network-fee")
                footerText: qsTr("Continue")
                showNextBtn: false
                onBackClicked: function() {
                    stack.pop()
                }
                GasSelector {
                    id: gasSelector
                    anchors.topMargin: Style.current.padding
                    gasPrice: parseFloat(root.store.gasPrice)
                    getGasEthValue: root.store.getGasEthValue
                    getFiatValue: root.store.getFiatValue
                    defaultCurrency: root.store.currentCurrency
                    width: stack.width

                    property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                       if (!(selectFromAccount.selectedAccount && selectFromAccount.selectedAccount.address &&
                           selectRecipient.selectedRecipient && selectRecipient.selectedRecipient.address &&
                           root.selectedAsset && root.selectedAsset.address &&
                           root.selectedAmount)) {
                           selectedGasLimit = 250000
                           defaultGasLimit = selectedGasLimit
                           return
                       }

                       let gasEstimate = JSON.parse(root.store.estimateGas(
                           selectFromAccount.selectedAccount.address,
                           selectRecipient.selectedRecipient.address,
                           root.selectedAsset.address,
                           root.selectedAmount,
                           trxData))

                       if (!gasEstimate.success) {
                           let message = qsTr("Error estimating gas: %1").arg(gasEstimate.error.message)
                           root.openGasEstimateErrorPopup(message);
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
                    selectedAmount: parseFloat(root.selectedAmount)
                    selectedAsset: root.selectedAsset
                    selectedGasEthValue: gasSelector.selectedGasEthValue
                }
            }

            TransactionFormGroup {
                id: groupPreview
                //% "Transaction preview"
                headerText: qsTrId("transaction-preview")
                //% "Sign with password"
                footerText: qsTrId("sign-with-password")
                showBackBtn: false
                onNextClicked: function() {
                    stack.push(groupSignTx, StackView.Immediate)
                }
                isValid: groupSelectAcct.isValid && groupSelectGas.isValid && pvwTransaction.isValid

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
                    asset: root.selectedAsset
                    amount: { "value": root.selectedAmount, "fiatValue": root.selectedFiatAmount }
                    currency: root.store.currentCurrency
                    isFromEditable: false
                    trxData: root.trxData
                    isGasEditable: true
                    fromValid: balanceValidator.isValid
                    gasValid: gasValidator.isValid
                    onFromClicked: { stack.push(groupSelectAcct, StackView.Immediate) }
                    onGasClicked: { stack.push(groupSelectGas, StackView.Immediate) }
                }
                BalanceValidator {
                    id: balanceValidator
                    anchors.top: pvwTransaction.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    account: selectFromAccount.selectedAccount
                    amount: !!root.selectedAmount ? parseFloat(root.selectedAmount) : 0.0
                    asset: root.selectedAsset
                }
                GasValidator {
                    id: gasValidator2
                    anchors.top: balanceValidator.visible ? balanceValidator.bottom : pvwTransaction.bottom
                    anchors.topMargin: balanceValidator.visible ? 5 : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    selectedAccount: selectFromAccount.selectedAccount
                    selectedAmount: parseFloat(root.selectedAmount)
                    selectedAsset: root.selectedAsset
                    selectedGasEthValue: gasSelector.selectedGasEthValue
                }
            }
            TransactionFormGroup {
                id: groupSignTx
                //% "Sign with password"
                headerText: qsTrId("sign-with-password")
                //% "Send %1 %2"
                footerText: qsTrId("send--1--2").arg(root.selectedAmount).arg(!!root.selectedAsset ? root.selectedAsset.symbol : "")
                onBackClicked: function() {
                    stack.pop()
                }

                TransactionSigner {
                    id: transactionSigner
                    width: stack.width
                   signingPhrase: root.store.signingPhrase
                }
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            id: btnBack
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            icon.rotation: 180
            visible: stack.currentGroup.showBackBtn
            enabled: stack.currentGroup.isValid || stack.isLastGroup
            onClicked: {
                if (typeof stack.currentGroup.onBackClicked === "function") {
                    return stack.currentGroup.onBackClicked()
                }
                stack.back()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnNext
            //% "Next"
            text: qsTrId("next")
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            visible: stack.currentGroup.showNextBtn
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        return root.sendTransaction(gasSelector.selectedGasLimit,
                                                    gasSelector.eip1599Enabled ? "" : gasSelector.selectedGasPrice,
                                                    gasSelector.selectedTipLimit,
                                                    gasSelector.selectedOverallLimit,
                                                    transactionSigner.enteredPassword)
                    }

                    if(gasSelector.eip1599Enabled && stack.currentGroup === groupSelectGas && gasSelector.advancedMode){
                        if(gasSelector.showPriceLimitWarning || gasSelector.showTipLimitWarning){
                            Global.openPopup(transactionSettingsConfirmationPopupComponent, {
                                currentBaseFee: gasSelector.latestBaseFeeGwei,
                                currentMinimumTip: gasSelector.perGasTipLimitFloor,
                                currentAverageTip: gasSelector.perGasTipLimitAverage,
                                tipLimit: gasSelector.selectedTipLimit,
                                suggestedTipLimit: gasSelector.perGasTipLimitFloor, // TODO:
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


                    if (typeof stack.currentGroup.onNextClicked === "function") {
                        return stack.currentGroup.onNextClicked()
                    }
                    stack.next()
                }
            }
        }
    ]

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup { }
    }

    Connections {
        target: root.store.walletSectionTransactionsInst
        onTransactionSent: {
            try {
                let response = JSON.parse(txResult)
                if (response.uuid !== stack.uuid)
                    return

                let transactionId = response.result

                if (!response.success) {
                    if (Utils.isInvalidPasswordMessage(transactionId)){
                        //% "Wrong password"
                        transactionSigner.validationError = qsTrId("wrong-password")
                        return
                    }
                    sendingError.text = transactionId
                    return sendingError.open()
                }
                root.store.acceptRequestTransaction(transactionId, msgId, root.store.getPubkey() + transactionId.substr(2))
                root.close()
            } catch (e) {
                console.error('Error parsing the response', e)
            }
        }
    }
}

