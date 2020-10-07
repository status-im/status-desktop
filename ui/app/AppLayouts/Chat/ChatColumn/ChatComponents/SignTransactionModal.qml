import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    property var selectedAccount
    property var selectedRecipient
    property var selectedAsset
    property var selectedAmount
    property var selectedFiatAmount

    property string trxData: ""

    property alias transactionSigner: transactionSigner

    property var sendTransaction: function(selectedGasLimit, selectedGasPrice, enteredPassword) {
        let responseStr = walletModel.sendTransaction(root.selectedAccount.address,
                                                 root.selectedRecipient.address,
                                                 root.selectedAsset.address,
                                                 root.selectedAmount,
                                                 selectedGasLimit,
                                                 selectedGasPrice,
                                                 enteredPassword,
                                                 stack.uuid)

        let response = JSON.parse(responseStr)

        if (response.error) {
            if (response.result.includes("could not decrypt key with given password")){
                //% "Wrong password"
                transactionSigner.validationError = qsTrId("wrong-password")
                return
            }
            sendingError.text = response.result
            return sendingError.open()
        }
        root.close()
    }

    function estimateGas(){
        gasSelector.estimateGas()
    }

    id: root

    //% "Send"
    title: qsTrId("command-button-send")
    height: 504

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    onClosed: {
        stack.reset()
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
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
                    const approveData = JSON.parse(walletModel.decodeTokenApproval(selectedRecipient.address, trxData))
                    if(approveData.symbol)
                        return qsTr("Authorize %1 %2").arg(approveData.amount).arg(approveData.symbol)    
                }
                return qsTrId("command-button-send");
            }
            footerText: qsTr("Continue")
            showNextBtn: false
            onBackClicked: function() {
                if(validate()) {
                    stack.pop()
                }
            }
            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: root.selectedAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                //% "Choose account"
                label: qsTrId("choose-account")
                showBalanceForAssetSymbol: root.selectedAsset.symbol
                minRequiredAssetBalance: parseFloat(root.selectedAmount)
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    selectedAccount = Qt.binding(function() { return root.selectedAccount })
                    showBalanceForAssetSymbol = Qt.binding(function() { return root.selectedAsset.symbol })
                    minRequiredAssetBalance = Qt.binding(function() { return parseFloat(root.selectedAmount) })
                }
                onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: walletModel.accounts
                contacts: profileModel.addedContacts
                selectedRecipient: root.selectedRecipient
                readOnly: true
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    contacts = Qt.binding(function() { return profileModel.addedContacts })
                    selectedRecipient = Qt.binding(function() { return root.selectedRecipient })
                }
            }
        }
        TransactionFormGroup {
            id: groupSelectGas
            headerText: qsTr("Network fee")
            //% "Preview"
            footerText: qsTrId("preview")
            showNextBtn: false
            onBackClicked: function() {
                stack.pop()
            }
            GasSelector {
                id: gasSelector
                anchors.topMargin: Style.current.bigPadding
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
    
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    if (!(selectFromAccount.selectedAccount && selectFromAccount.selectedAccount.address &&
                        selectRecipient.selectedRecipient && selectRecipient.selectedRecipient.address &&
                        root.selectedAsset && root.selectedAsset.address &&
                        root.selectedAmount)) {
                        selectedGasLimit = 250000
                        return
                    }
                    
                    let gasEstimate = JSON.parse(walletModel.estimateGas(
                        selectFromAccount.selectedAccount.address,
                        selectRecipient.selectedRecipient.address,
                        root.selectedAsset.address,
                        root.selectedAmount,
                        trxData))

                    if (!gasEstimate.success) {
                        //% "Error estimating gas: %1"
                        console.warn(qsTrId("error-estimating-gas---1").arg(gasEstimate.error.message))
                        return
                    }
                    selectedGasLimit = gasEstimate.result
                })
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: root.selectedAccount
                selectedAmount: parseFloat(root.selectedAmount)
                selectedAsset: root.selectedAsset
                selectedGasEthValue: gasSelector.selectedGasEthValue
                reset: function() {
                    selectedAccount = Qt.binding(function() { return root.selectedAccount })
                    selectedAmount = Qt.binding(function() { return parseFloat(root.selectedAmount) })
                    selectedAsset = Qt.binding(function() { return root.selectedAsset })
                    selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
                }
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

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: root.selectedAccount
                gas: {
                    "value": gasSelector.selectedGasEthValue,
                    "symbol": "ETH",
                    "fiatValue": gasSelector.selectedGasFiatValue
                }
                toAccount: root.selectedRecipient
                asset: root.selectedAsset
                amount: { "value": root.selectedAmount, "fiatValue": root.selectedFiatAmount }
                currency: walletModel.defaultCurrency
                reset: function() {
                    fromAccount =  Qt.binding(function() { return root.selectedAccount })
                    gas = Qt.binding(function() {
                        return {
                            "value": gasSelector.selectedGasEthValue,
                            "symbol": "ETH",
                            "fiatValue": gasSelector.selectedGasFiatValue
                        }
                    })
                    toAccount =  Qt.binding(function() { return root.selectedRecipient })
                    asset = Qt.binding(function() { return root.selectedAsset })
                    amount = Qt.binding(function() { return { "value": root.selectedAmount, "fiatValue": root.selectedFiatAmount } })
                }
                onFromClicked: stack.push(groupSelectAcct, StackView.Immediate)
                onGasClicked: stack.push(groupSelectGas, StackView.Immediate)
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
        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            visible: stack.currentGroup.showBackBtn
            enabled: stack.currentGroup.isValid || stack.isLastGroup
            onClicked: {
                if (typeof stack.currentGroup.onBackClicked === "function") {
                    return stack.currentGroup.onBackClicked()
                }
                stack.back()
            }
        }
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
                                                    gasSelector.selectedGasPrice,
                                                    transactionSigner.enteredPassword)
                    }
                    if (typeof stack.currentGroup.onNextClicked === "function") {
                        return stack.currentGroup.onNextClicked()
                    }
                    stack.next()
                }
            }
        }

        Connections {
            target: walletModel
            onTransactionWasSent: {
                try {
                    let response = JSON.parse(txResult)

                    if (response.uuid !== stack.uuid) return
                    
                    stack.currentGroup.isPending = false

                    if (!response.success) {
                        if (response.result.includes("could not decrypt key with given password")){
                            //% "Wrong password"
                            transactionSigner.validationError = qsTrId("wrong-password")
                            return
                        }
                        sendingError.text = response.result
                        return sendingError.open()
                    }

                    //% "Transaction pending..."
                    toastMessage.title = qsTrId("ens-transaction-pending")
                    toastMessage.source = "../../img/loading.svg"
                    toastMessage.iconColor = Style.current.primary
                    toastMessage.iconRotates = true
                    toastMessage.link = `${walletModel.etherscanLink}/${response.result}`
                    toastMessage.open()
                    root.close()
                } catch (e) {
                    console.error('Error parsing the response', e)
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

