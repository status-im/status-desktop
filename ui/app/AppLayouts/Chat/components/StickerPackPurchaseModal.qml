import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: root
    readonly property var asset: JSON.parse(walletModel.getStatusToken())
    property int stickerPackId: -1
    property string packPrice
    property bool showBackBtn: false
    title: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(packPrice)).arg(asset.symbol)

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
        let responseStr = chatsModel.buyStickerPack(root.stickerPackId,
                                                    selectFromAccount.selectedAccount.address,
                                                    root.packPrice,
                                                    gasSelector.selectedGasLimit,
                                                    gasSelector.selectedGasPrice,
                                                    transactionSigner.enteredPassword)
        let response = JSON.parse(responseStr)

        if (!response.success) {
            if (response.result.includes("could not decrypt key with given password")){
                transactionSigner.validationError = qsTr("Wrong password")
                return
            }
            sendingError.text = response.result
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
            headerText: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(root.packPrice)).arg(root.asset.symbol)
            footerText: qsTr("Continue")

            StackView.onActivated: {
                btnBack.visible = root.showBackBtn
            }

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                label: qsTr("Choose account")
                showBalanceForAssetSymbol: root.asset.symbol
                minRequiredAssetBalance: root.packPrice
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    selectedAccount = Qt.binding(function() { return walletModel.currentAccount })
                    showBalanceForAssetSymbol = Qt.binding(function() { return root.asset.symbol })
                    minRequiredAssetBalance = Qt.binding(function() { return root.packPrice })
                }
                onSelectedAccountChanged: gasSelector.estimateGas()
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: walletModel.accounts
                contacts: profileModel.addedContacts
                selectedRecipient: { "address": chatsModel.stickerMarketAddress, "type": RecipientSelector.Type.Address }
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
                    if (!(root.stickerPackId > -1 && selectFromAccount.selectedAccount && root.packPrice && parseFloat(root.packPrice) > 0)) {
                        selectedGasLimit = 325000
                        return
                    }
                    selectedGasLimit = chatsModel.buyPackGasEstimate(root.stickerPackId, selectFromAccount.selectedAccount.address, root.packPrice)
                })
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: selectFromAccount.selectedAccount
                selectedAsset: root.asset
                selectedAmount: parseFloat(packPrice)
                selectedGasEthValue: gasSelector.selectedGasEthValue
                reset: function() {
                    selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    selectedAsset = Qt.binding(function() { return root.asset })
                    selectedAmount = Qt.binding(function() { return parseFloat(packPrice) })
                    selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
                }
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(root.packPrice)).arg(root.asset.symbol)
            footerText: qsTr("Sign with password")

            StackView.onActivated: {
                btnBack.visible = true
            }

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
                    const fiatValue = walletModel.getFiatValue(root.packPrice || 0, root.asset.symbol, currency)
                    return { "value": root.packPrice, "fiatValue": fiatValue }
                }
                reset: function() {
                    fromAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    toAccount = Qt.binding(function() { return selectRecipient.selectedRecipient })
                    asset = Qt.binding(function() { return root.asset })
                    amount = Qt.binding(function() { return { "value": root.packPrice, "fiatValue": walletModel.getFiatValue(root.packPrice, root.asset.symbol, currency) } })
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
            headerText: qsTr("Send %1 %2").arg(Utils.stripTrailingZeros(root.packPrice)).arg(root.asset.symbol)
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
            id: btnBack
            anchors.left: parent.left
            //% "Back"
            label: qsTrId("back")
            onClicked: {
                if (stack.isFirstGroup) {
                    return root.close()
                }
                stack.back()
            }
        }
        StyledButton {
            id: btnNext
            anchors.right: parent.right
            label: qsTr("Next")
            disabled: !stack.currentGroup.isValid
            onClicked: {
                const isValid = stack.currentGroup.validate()

                if (stack.currentGroup.validate()) {
                    if (stack.isLastGroup) {
                        return root.sendTransaction()
                    }
                    stack.next()
                }
            }
        }

        Connections {
            target: chatsModel
            onTransactionWasSent: {
                toastMessage.title = qsTr("Transaction pending...")
                toastMessage.source = "../../../img/loading.svg"
                toastMessage.iconColor = Style.current.primary
                toastMessage.iconRotates = true
                toastMessage.link = `${walletModel.etherscanLink}/${txResult}`
                toastMessage.open()
            }
            onTransactionCompleted: {
                toastMessage.title = !success ? 
                                     qsTr("Could not buy Stickerpack")
                                     :
                                     qsTr("Stickerpack bought successfully");
                if (success) {
                    toastMessage.source = "../../../img/check-circle.svg"
                    toastMessage.iconColor = Style.current.success
                } else {
                    toastMessage.source = "../../../img/block-icon.svg"
                    toastMessage.iconColor = Style.current.danger
                }

                toastMessage.link = `${walletModel.etherscanLink}/${txHash}`
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

