import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../../imports"
import "../../../../../shared"

ModalPopup {
    id: root
    readonly property var asset: JSON.parse(walletModel.getStatusToken())
    property string ensUsername: ""
    property string ensPrice: "10"

    title: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(ensPrice)).arg(asset.symbol)

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
        let responseStr = profileModel.ens.registerENS(root.ensUsername,
                                                       selectFromAccount.selectedAccount.address,
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

        usernameRegistered(username);
        sendingSuccess.text = qsTr("Transaction sent to the blockchain. You can watch the progress on Etherscan: %2%1").arg(response.result).arg(walletModel.etherscanLink)
        sendingSuccess.open()
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
            headerText: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(root.ensPrice)).arg(root.asset.symbol)
            footerText: qsTr("Continue")

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                label: qsTr("Choose account")
                showBalanceForAssetSymbol: root.asset.symbol
                minRequiredAssetBalance: root.ensPrice
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    selectedAccount = Qt.binding(function() { return walletModel.currentAccount })
                    showBalanceForAssetSymbol = Qt.binding(function() { return root.asset.symbol })
                    minRequiredAssetBalance = Qt.binding(function() { return root.ensPrice })
                }
                onSelectedAccountChanged: gasSelector.estimateGas()
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: walletModel.accounts
                contacts: profileModel.addedContacts
                selectedRecipient: { "address": profileModel.ens.ensRegisterAddress, "type": RecipientSelector.Type.Address }
                readOnly: true
                onSelectedRecipientChanged: gasSelector.estimateGas()
            }
            GasSelector {
                id: gasSelector
                visible: false
                slowestGasPrice: parseFloat(walletModel.safeLowGasPrice)
                fastestGasPrice: parseFloat(walletModel.fastestGasPrice)
                getGasEthValue: walletModel.getGasEthValue
                getFiatValue: walletModel.getFiatValue
                defaultCurrency: walletModel.defaultCurrency
                reset: function() {
                    slowestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.safeLowGasPrice) })
                    fastestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.fastestGasPrice) })
                }
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    if (!(root.ensUsername !== "" && selectFromAccount.selectedAccount)) {
                        selectedGasLimit = 380000
                        return
                    }
                    selectedGasLimit = profileModel.ens.registerENSGasEstimate(root.ensUsername, selectFromAccount.selectedAccount.address)
                })
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: selectFromAccount.selectedAccount
                selectedAsset: root.asset
                selectedAmount: parseFloat(ensPrice)
                selectedGasEthValue: gasSelector.selectedGasEthValue
                reset: function() {
                    selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    selectedAsset = Qt.binding(function() { return root.asset })
                    selectedAmount = Qt.binding(function() { return parseFloat(ensPrice) })
                    selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
                }
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(root.ensPrice)).arg(root.asset.symbol)
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
                asset: root.asset
                currency: walletModel.defaultCurrency
                amount: {
                    const fiatValue = walletModel.getFiatValue(root.ensPrice || 0, root.asset.symbol, currency)
                    return { "value": root.ensPrice, "fiatValue": fiatValue }
                }
                reset: function() {
                    fromAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    toAccount = Qt.binding(function() { return selectRecipient.selectedRecipient })
                    asset = Qt.binding(function() { return root.asset })
                    amount = Qt.binding(function() { return { "value": root.ensPrice, "fiatValue": walletModel.getFiatValue(root.ensPrice, root.asset.symbol, currency) } })
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
            headerText: qsTr("Send %1 %2").arg(Utils.stripTrailingZeros(root.ensPrice)).arg(root.asset.symbol)
            footerText: qsTr("Sign with password")

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
            id: btnNext
            anchors.right: parent.right
            label: qsTr("Next")
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
