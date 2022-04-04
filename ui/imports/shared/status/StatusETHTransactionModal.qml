import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Controls 0.1

import shared.views 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.controls 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: root

    property var ensUsernamesStore
    property var contactsStore
    property string ensUsername

    property int chainId
    readonly property var asset: {"name": "Ethereum", "symbol": "ETH"}

    title: qsTr("Contract interaction")

    property var estimateGasFunction: (function(userAddress) { return 0; })
    property var onSendTransaction: (function(userAddress, gasLimit, gasPrice, password){ return ""; })
    property var onSuccess: (function(){})

    height: 540

    function sendTransaction() {
        try {
            let responseStr = root.ensUsernamesStore.setPubKey(root.ensUsername,
                                                        selectFromAccount.selectedAccount.address,
                                                        gasSelector.selectedGasLimit,
                                                        gasSelector.suggestedFees.eip1559Enabled ? "" : gasSelector.selectedGasPrice,
                                                        gasSelector.selectedTipLimit,
                                                        gasSelector.selectedOverallLimit,
                                                        transactionSigner.enteredPassword,
                                                        gasSelector.suggestedFees.eip1559Enabled)
            let response = JSON.parse(responseStr)

            if (!response.success) {
                if (Utils.isInvalidPasswordMessage(response.result)){
                    transactionSigner.validationError = qsTr("Wrong password")
                    return
                }
                sendingError.text = response.result
                return sendingError.open()
            }

            onSuccess();
            root.close();
        } catch (e) {
            console.error('Error sending the transaction', e)
            sendingError.text = "Error sending the transaction: " + e.message;
            return sendingError.open()
        }
    }

    onOpened: {
        gasSelector.suggestedFees = root.ensUsernamesStore.suggestedFees(root.chainId)
        gasSelector.checkOptimal()
    }

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    TransactionStackView {
        id: stack
        height: parent.height
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }
        TransactionFormGroup {
            id: group1
            headerText: root.title
            footerText: qsTr("Continue")

            StatusAccountSelector {
                id: selectFromAccount
                accounts: walletSectionAccounts.model
                selectedAccount: {
                    const currAcc = walletSectionCurrent
                    if (currAcc.walletType !== Constants.watchWalletType) {
                        return currAcc
                    }
                    return null
                }
                currency: root.ensUsernamesStore.getCurrentCurrency()
                width: stack.width
                chainId: root.chainId
                label: qsTr("Choose account")
                showBalanceForAssetSymbol: "ETH"
                minRequiredAssetBalance: 0
                onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: root.ensUsernamesStore.walletAccounts
                contactsStore: root.contactsStore
                selectedRecipient: { "address": root.ensUsernamesStore.getEnsRegisteredAddress(), "type": RecipientSelector.Type.Address }
                readOnly: true
                onSelectedRecipientChanged: if (isValid) { gasSelector.estimateGas() }
            }
            GasSelector {
                id: gasSelector
                visible: true
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: Style.current.padding
                getGasEthValue: root.ensUsernamesStore.getGasEthValue
                getFiatValue: root.ensUsernamesStore.getFiatValue
                defaultCurrency: root.ensUsernamesStore.getCurrentCurrency()
                
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    let estimatedGas = root.estimateGasFunction(selectFromAccount.selectedAccount);
                    gasSelector.selectedGasLimit = estimatedGas
                    return estimatedGas;
                })
            }
            GasValidator {
                id: gasValidator
                anchors.top: gasSelector.bottom
                selectedAccount: selectFromAccount.selectedAccount
                selectedAsset: root.asset
                selectedAmount: 0
                selectedGasEthValue: gasSelector.selectedGasEthValue
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: root.title
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
                currency: root.ensUsernamesStore.getCurrentCurrency()
                amount: {
                    const fiatValue = root.ensUsernamesStore.getFiatValue(0, root.asset.symbol, currency)
                    return { "value": 0, "fiatValue": fiatValue }
                }
            }
        }
        TransactionFormGroup {
            id: group4
            headerText: root.title
            footerText: qsTr("Sign with password")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: root.ensUsernamesStore.getSigningPhrase()
            }
        }
    }

    footer: Item {
        width: parent.width
        height: btnNext.height

         StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
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

        Component {
            id: transactionSettingsConfirmationPopupComponent
            TransactionSettingsConfirmationPopup {

            }
        }

        StatusButton {
            id: btnNext
            anchors.right: parent.right
            text: qsTr("Next")
            enabled: stack.currentGroup.isValid
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        return root.sendTransaction()
                    }

                    if(gasSelector.suggestedFees.eip1559Enabled && stack.currentGroup === group3 && gasSelector.advancedMode){
                        if(gasSelector.showPriceLimitWarning || gasSelector.showTipLimitWarning){
                            Global.openPopup(transactionSettingsConfirmationPopupComponent, {
                                currentBaseFee: gasSelector.suggestedFees.baseFee,
                                currentMinimumTip: gasSelector.perGasTipLimitFloor,
                                currentAverageTip: gasSelector.perGasTipLimitAverage,
                                tipLimit: gasSelector.selectedTipLimit,
                                suggestedTipLimit: gasSelector.perGasTipLimitFloor,
                                priceLimit: gasSelector.selectedOverallLimit,
                                suggestedPriceLimit: gasSelector.suggestedFees.baseFee + gasSelector.perGasTipLimitFloor,
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
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
