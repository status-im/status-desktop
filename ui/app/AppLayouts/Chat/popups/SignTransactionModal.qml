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
import "../../Wallet/"

//TODO remove dynamic scoping
StatusModal {
    id: root
    //% "Send"
    header.title: qsTrId("command-button-send")
    height: 540

    property var store
    property var selectedAccount
    property var selectedRecipient
    property var selectedAsset
    property var selectedAmount
    property var selectedFiatAmount
    property bool outgoing: true

    property string trxData: ""

    property alias transactionSigner: transactionSigner

    property var sendTransaction: function(selectedGasLimit, selectedGasPrice, selectedTipLimit, selectedOveralLimit, enteredPassword) {
        let success = false
        if(root.selectedAsset.address == Constants.zeroAddress){
            success = root.store.walletModelInst.transactionsView.transferEth(
                                                selectFromAccount.selectedAccount.address,
                                                 selectRecipient.selectedRecipient.address,
                                                 root.selectedAmount,
                                                 selectedGasLimit,
                                                 gasSelector.eip1599Enabled ? "" : gasSelector.selectedGasPrice,
                                                 gasSelector.selectedTipLimit,
                                                 gasSelector.selectedOverallLimit,
                                                 enteredPassword,
                                                 stack.uuid)
        } else {
            success = root.store.walletModelInst.transactionsView.transferTokens(
                                                 selectFromAccount.selectedAccount.address,
                                                 selectRecipient.selectedRecipient.address,
                                                 root.selectedAsset.address,
                                                 root.selectedAmount,
                                                 selectedGasLimit,
                                                 gasSelector.eip1599Enabled ? "" : gasSelector.selectedGasPrice,
                                                 gasSelector.selectedTipLimit,
                                                 gasSelector.selectedOverallLimit,
                                                 enteredPassword,
                                                 stack.uuid)
        }

        if(!success){
            //% "Invalid transaction parameters"
            sendingError.text = qsTrId("invalid-transaction-parameters")
            sendingError.open()
        }
    }

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

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
                root.title = group.headerText
                btnNext.text = group.footerText
            }
            TransactionFormGroup {
                id: groupSelectAcct
                headerText: {
                    if(trxData.startsWith("0x095ea7b3")){
                        const approveData = JSON.parse(root.store.walletModelInst.tokensView.decodeTokenApproval(selectedRecipient.address, trxData))
                        if(approveData.symbol)
                            //% "Authorize %1 %2"
                            return qsTrId("authorize--1--2").arg(approveData.amount).arg(approveData.symbol)    
                    }
                    return qsTrId("command-button-send");
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
                    accounts: root.store.walletModelInst.accountsView.accounts
                    currency: root.store.walletModelInst.balanceView.defaultCurrency
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
                    accounts: root.store.walletModelInst.accountsView.accounts
                    contacts: root.store.addedContacts
                    selectedRecipient: root.selectedRecipient
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
                    gasPrice: parseFloat(root.store.walletModelInst.gasView.gasPrice)
                    getGasEthValue: root.store.walletModelInst.gasView.getGasEthValue
                    getFiatValue: root.store.walletModelInst.balanceView.getFiatValue
                    defaultCurrency: root.store.walletModelInst.balanceView.defaultCurrency
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
                        
                        let gasEstimate = JSON.parse(root.store.walletModelInst.gasView.estimateGas(
                            selectFromAccount.selectedAccount.address,
                            selectRecipient.selectedRecipient.address,
                            root.selectedAsset.address,
                            root.selectedAmount,
                            trxData))

                        if (!gasEstimate.success) {
                            //% "Error estimating gas: %1"
                            let message = qsTrId("error-estimating-gas---1").arg(gasEstimate.error.message)

                            //% ". The transaction will probably fail."
                            gasEstimateErrorPopup.confirmationText = message + qsTrId("--the-transaction-will-probably-fail-")
                            gasEstimateErrorPopup.open()
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
                    currency: root.store.walletModelInst.balanceView.defaultCurrency
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
                    signingPhrase: root.store.walletModelInst.utilsView.signingPhrase
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
            anchors.right: parent.right
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
                            openPopup(transactionSettingsConfirmationPopupComponent, {
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
        TransactionSettingsConfirmationPopup {

        }
    }

    Connections {
        target: root.store.walletModelInst.transactionsView
        onTransactionWasSent: {
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

                chatsModel.transactions.acceptRequestTransaction(transactionId,
                                                        messageId,
                                                        root.store.profileModelInst.profile.pubKey + transactionId.substr(2))

                //% "Transaction pending..."
                toastMessage.title = qsTrId("ens-transaction-pending")
                toastMessage.source = Style.svg("loading")
                toastMessage.iconColor = Style.current.primary
                toastMessage.iconRotates = true
                toastMessage.link = `${root.store.walletModelInst.utilsView.etherscanLink}/${transactionId}`
                toastMessage.open()

                root.close()
            } catch (e) {
                console.error('Error parsing the response', e)
            }
        }
    }
}

