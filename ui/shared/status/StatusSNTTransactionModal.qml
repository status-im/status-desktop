import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../imports"
import "../../shared"
import "../../shared/status"

ModalPopup {
    id: root
    readonly property var asset: JSON.parse(walletModel.tokensView.getStatusToken())
    property string assetPrice
    property string contractAddress
    property var estimateGasFunction: (function(userAddress, uuid) { return 0; })
    property var onSendTransaction: (function(userAddress, gasLimit, gasPrice, password){ return ""; })
    property var onSuccess: (function(){})

    Component.onCompleted: {
        walletModel.gasView.getGasPricePredictions()
    }

    //% "Authorize %1 %2"
    title: qsTrId("authorize--1--2").arg(Utils.stripTrailingZeros(assetPrice)).arg(asset.symbol)

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    function setAsyncGasLimitResult(uuid, value) {
        if (uuid === gasSelector.uuid) {
            gasSelector.selectedGasLimit = value
        }
    }

    function sendTransaction() {
        let responseStr = onSendTransaction(selectFromAccount.selectedAccount.address,
                                         gasSelector.selectedGasLimit,
                                         gasSelector.selectedGasPrice,
                                         transactionSigner.enteredPassword);

        let response = JSON.parse(responseStr)

        if (!response.success) {
            if (Utils.isInvalidPasswordMessage(response.result)){
                //% "Wrong password"
                transactionSigner.validationError = qsTrId("wrong-password")
                return
            }
            sendingError.text = response.result
            return sendingError.open()
        }

        onSuccess();
        root.close();
    }

    TransactionStackView {
        id: stack
        height: parent.height
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        initialItem: group1
        isLastGroup: stack.currentGroup === group4
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }
        TransactionFormGroup {
            id: group1
            //% "Authorize %1 %2"
            headerText: qsTrId("authorize--1--2").arg(Utils.stripTrailingZeros(root.assetPrice)).arg(root.asset.symbol)
            //% "Continue"
            footerText: qsTrId("continue")
            showBackBtn: false
            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accountsView.accounts
                selectedAccount: {
                    const currAcc = walletModel.accountsView.currentAccount
                    if (currAcc.walletType !== Constants.watchWalletType) {
                        return currAcc
                    }
                    return null
                }
                currency: walletModel.balanceView.defaultCurrency
                width: stack.width
                //% "Choose account"
                label: qsTrId("choose-account")
                showBalanceForAssetSymbol: root.asset.symbol
                minRequiredAssetBalance: root.assetPrice
                onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: walletModel.accountsView.accounts
                contacts: profileModel.contacts.addedContacts
                selectedRecipient: { "address": contractAddress, "type": RecipientSelector.Type.Address }
                readOnly: true
                onSelectedRecipientChanged: if (isValid) { gasSelector.estimateGas() }
            }
            GasSelector {
                id: gasSelector
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: Style.current.bigPadding * 2
                slowestGasPrice: parseFloat(walletModel.gasView.safeLowGasPrice)
                fastestGasPrice: parseFloat(walletModel.gasView.fastestGasPrice)
                getGasEthValue: walletModel.gasView.getGasEthValue
                getFiatValue: walletModel.balanceView.getFiatValue
                defaultCurrency: walletModel.balanceView.defaultCurrency
                width: stack.width
                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    let estimatedGas = root.estimateGasFunction(selectFromAccount.selectedAccount, uuid);
                    gasSelector.selectedGasLimit = estimatedGas
                    return estimatedGas;
                })
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: selectFromAccount.selectedAccount
                selectedAsset: root.asset
                selectedAmount: parseFloat(root.assetPrice)
                selectedGasEthValue: gasSelector.selectedGasEthValue
            }
        }
        TransactionFormGroup {
            id: group3
            //% "Authorize %1 %2"
            headerText: qsTrId("authorize--1--2").arg(Utils.stripTrailingZeros(root.assetPrice)).arg(root.asset.symbol)
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
                asset: root.asset
                currency: walletModel.balanceView.defaultCurrency
                amount: {
                    const fiatValue = walletModel.balanceView.getFiatValue(root.assetPrice || 0, root.asset.symbol, currency)
                    return { "value": root.assetPrice, "fiatValue": fiatValue }
                }
            }
        }
        TransactionFormGroup {
            id: group4
            //% "Send %1 %2"
            headerText: qsTrId("send--1--2").arg(Utils.stripTrailingZeros(root.assetPrice)).arg(root.asset.symbol)
            //% "Sign with password"
            footerText: qsTrId("sign-with-password")

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
            state: stack.currentGroup.isPending ? "pending" : "default"
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
