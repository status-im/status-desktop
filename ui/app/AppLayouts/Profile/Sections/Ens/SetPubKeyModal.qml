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

    title: qsTr("Connect username with your pubkey")

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    onClosed: {
        stack.reset()
    }

    function sendTransaction() {
        let responseStr = profileModel.ens.setPubKey(root.ensUsername,
                                                       selectFromAccount.selectedAccount.address,
                                                       gasSelector.selectedGasLimit,
                                                       gasSelector.selectedGasPrice,
                                                       transactionSigner.enteredPassword)
        let response = JSON.parse(responseStr)

        if (!response.success) {
            if (response.error.message.includes("could not decrypt key with given password")){
                transactionSigner.validationError = qsTr("Wrong password")
                return
            }
            sendingError.text = response.error.message
            return sendingError.open()
        }

        usernameUpdated(root.ensUsername);
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
            headerText: qsTr("Connect username with your pubkey")
            footerText: qsTr("Continue")

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                label: qsTr("Choose account")
                showBalanceForAssetSymbol: "ETH"
                minRequiredAssetBalance: 0
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    selectedAccount = Qt.binding(function() { return walletModel.currentAccount })
                    showBalanceForAssetSymbol = Qt.binding(function() { return "ETH" })
                    minRequiredAssetBalance = Qt.binding(function() { return 0 })
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
                reset: function() {
                    selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    selectedAsset = Qt.binding(function() { return root.asset })
                    selectedAmount = Qt.binding(function() { return 0 })
                    selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
                }
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Connect username with your pubkey")
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
                    const fiatValue = walletModel.getFiatValue(0, root.asset.symbol, currency)
                    return { "value": 0, "fiatValue": fiatValue }
                }
                reset: function() {
                    fromAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    toAccount = Qt.binding(function() { return selectRecipient.selectedRecipient })
                    asset = Qt.binding(function() { return root.asset })
                    amount = Qt.binding(function() { return { "value": 0, "fiatValue": walletModel.getFiatValue(0, root.asset.symbol, currency) } })
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
            headerText: qsTr("Connect username with your pubkey")
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
