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

    property var store
    property var stickersStore
    property var contactsStore

    readonly property var asset: JSON.parse(root.stickersStore.getStatusToken())
    property string assetPrice
    property string contractAddress
    property int chainId
    property var estimateGasFunction: (function(userAddress, uuid) { return 0; })
    property var onSendTransaction: (function(userAddress, gasLimit, gasPrice, tipLimit, overallLimit, password, eip1559Enabled){ return ""; })
    property var onSuccess: (function(){})
    property var asyncGasEstimateTarget

    Component.onCompleted: {
        gasSelector.estimateGas();
    }

    height: 540

    title: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(assetPrice)).arg(asset.symbol)

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    function setAsyncGasLimitResult(uuid, value) {
        if (uuid === gasSelector.uuid) {
            gasSelector.selectedGasLimit = value
            gasSelector.defaultGasLimit = value
            gasSelector.updateGasEthValue();
        }
    }

    function sendTransaction() {
        let responseStr = onSendTransaction(selectFromAccount.selectedAccount.address,
                                         gasSelector.selectedGasLimit,
                                         gasSelector.suggestedFees.eip1559Enabled ? "" : gasSelector.selectedGasPrice,
                                         gasSelector.selectedTipLimit,
                                         gasSelector.selectedOverallLimit,
                                         transactionSigner.enteredPassword,
                                         gasSelector.suggestedFees.eip1559Enabled);

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
    }

    onOpened: {
        gasSelector.suggestedFees = root.store.suggestedFees(root.chainId)
        gasSelector.checkOptimal()
    }

    TransactionStackView {
        id: stack
        height: parent.height
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        initialItem: group1
        isLastGroup: stack.currentGroup === group3
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }
        TransactionFormGroup {
            id: group1
            headerText: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(root.assetPrice)).arg(root.asset.symbol)
            footerText: qsTr("Continue")
            showBackBtn: false
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
                currency: walletSection.currentCurrency
                width: stack.width
                label: qsTr("Choose account")
                showBalanceForAssetSymbol: root.asset.symbol
                minRequiredAssetBalance: root.assetPrice
                chainId: root.chainId
                onSelectedAccountChanged: if (isValid) { gasSelector.estimateGas() }
            }
            RecipientSelector {
                id: selectRecipient
                visible: false
                accounts: root.stickersStore.walletAccounts
                contactsStore: root.contactsStore
                selectedRecipient: { "address": contractAddress, "type": RecipientSelector.Type.Address }
                readOnly: true
                onSelectedRecipientChanged: if (isValid) { gasSelector.estimateGas() }
            }

            Connections {
                target: asyncGasEstimateTarget
                onGasEstimateReturned: {
                    root.setAsyncGasLimitResult(uuid, estimate)
                }
            }

            GasSelector {
                id: gasSelector
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: Style.current.padding
                getGasEthValue: root.stickersStore.getGasEthValue
                getFiatValue: root.stickersStore.getFiatValue
                defaultCurrency: root.stickersStore.getCurrentCurrency()
                width: stack.width

                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                    let estimatedGas = root.estimateGasFunction(selectFromAccount.selectedAccount, uuid);
                    if (estimatedGas !== undefined) {
                        gasSelector.selectedGasLimit = estimatedGas
                    }
                    return estimatedGas;
                })
            }
            GasValidator {
                id: gasValidator
                anchors.top: gasSelector.bottom
                selectedAccount: selectFromAccount.selectedAccount
                selectedAsset: root.asset
                selectedAmount: parseFloat(root.assetPrice)
                selectedGasEthValue: gasSelector.selectedGasEthValue
            }
        }
        TransactionFormGroup {
            id: group2
            headerText: qsTr("Authorize %1 %2").arg(Utils.stripTrailingZeros(root.assetPrice)).arg(root.asset.symbol)
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
                amount: {
                    const fiatValue = root.stickersStore.getFiatValue(root.assetPrice || 0, root.asset.symbol, currency)
                    return { "value": root.assetPrice, "fiatValue": fiatValue }
                }
                currency: root.stickersStore.getCurrentCurrency()
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Send %1 %2").arg(Utils.stripTrailingZeros(root.assetPrice)).arg(root.asset.symbol)
            footerText: qsTr("Sign with password")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: root.stickersStore.getSigningPhrase()
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
            enabled: {
                stack.currentGroup.isValid || stack.isLastGroup
            }
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
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            loading: stack.currentGroup.isPending
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        return root.sendTransaction()
                    }

                    if(gasSelector.suggestedFees.eip1559Enabled && stack.currentGroup === group2 && gasSelector.advancedMode){
                        if(gasSelector.showPriceLimitWarning || gasSelector.showTipLimitWarning){
                            Global.openPopup(transactionSettingsConfirmationPopupComponent, {
                                currentBaseFee: gasSelector.suggestedFees.baseFee,
                                currentMinimumTip: gasSelector.perGasTipLimitFloor,
                                currentAverageTip: gasSelector.perGasTipLimitAverage,
                                tipLimit: gasSelector.selectedTipLimit,
                                suggestedTipLimit: gasSelector.perGasTipLimitFloor, // TODO:
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
