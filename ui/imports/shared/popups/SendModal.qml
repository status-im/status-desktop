import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0
import StatusQ.Controls.Validators 0.1

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../panels"
import "../controls"
import "../views"

StatusModal {
    id: popup

    property alias stack: stack

    property var store
    property var contactsStore
    property var preSelectedAccount
    property var preSelectedRecipient
    property bool launchedFromChat: false
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
        success = popup.store.transfer(
            advancedHeader.accountSelector.selectedAccount.address,
            advancedHeader.recipientSelector.selectedRecipient.address,
            advancedHeader.assetSelector.selectedAsset.symbol,
            advancedHeader.amountToSendInput.text,
            gasSelector.selectedGasLimit,
            gasSelector.suggestedFees.eip1559Enabled ? "" : gasSelector.selectedGasPrice,
            gasSelector.selectedTipLimit,
            gasSelector.selectedOverallLimit,
            transactionSigner.enteredPassword,
            networkSelector.selectedNetwork.chainId || Global.currentChainId,
            stack.uuid,
            gasSelector.suggestedFees.eip1559Enabled,
        )
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if (!popup.store.isMultiNetworkEnabled) {
            return
        }

        networkSelector.suggestedRoutes = popup.store.suggestedRoutes(
            advancedHeader.accountSelector.selectedAccount.address, advancedHeader.amountToSendInput.text, advancedHeader.assetSelector.selectedAsset.symbol
        )
        if (networkSelector.suggestedRoutes.length) {
            networkSelector.selectedNetwork = networkSelector.suggestedRoutes[0]
            gasSelector.suggestedFees = popup.store.suggestedFees(networkSelector.suggestedRoutes[0].chainId)
            gasSelector.checkOptimal()
            gasSelector.visible = true
        } else {
            networkSelector.selectedNetwork = ""
            gasSelector.visible = false
        }
    })

    width: 556
    // To-Do as per design once the account selector become floating the heigth can be as defined in design as 595
    height: 670
    showHeader: false
    showFooter: false
    showAdvancedFooter: !!popup.advancedHeader ? popup.advancedHeader.isReady && gasValidator.isValid : false
    showAdvancedHeader: true

    onOpened: {
        if(!!advancedHeader) {
            advancedHeader.amountToSendInput.input.edit.forceActiveFocus()

            if(popup.launchedFromChat) {
                advancedHeader.recipientSelector.selectedType = RecipientSelector.Type.Contact
                advancedHeader.recipientSelector.readOnly = true
                advancedHeader.recipientSelector.selectedRecipient = popup.preSelectedRecipient
                
            }
            if(popup.preSelectedAccount) {
                advancedHeader.accountSelector.selectedAccount = popup.preSelectedAccount
            }
        }

        if (popup.store.isMultiNetworkEnabled) {
            popup.recalculateRoutesAndFees()
        } else {
            gasSelector.suggestedFees = popup.store.suggestedFees(Global.currentChainId)
            gasSelector.checkOptimal()
        }
    }


    advancedHeaderComponent: SendModalHeader {
        store: popup.store
        contactsStore: popup.contactsStore
        estimateGas: function() {
            if(popup.contentItem.currentGroup.isValid)
                gasSelector.estimateGas()
        }

        onAssetChanged: function() {
            popup.recalculateRoutesAndFees()
        }

        onSelectedAccountChanged: function() {
            popup.recalculateRoutesAndFees()
        }

        onAmountToSendChanged: function() {
            popup.recalculateRoutesAndFees()
        }
    }

    contentItem: TransactionStackView {
        id: stack
        property alias currentGroup: stack.currentGroup
        anchors.leftMargin: Style.current.xlPadding
        anchors.topMargin: (!!advancedHeader ? advancedHeader.height: 0) + Style.current.smallPadding
        anchors.rightMargin: Style.current.xlPadding
        anchors.bottomMargin: popup.showAdvancedFooter  && !!advancedFooter ? advancedFooter.height : Style.current.padding
        TransactionFormGroup {
            id: group1
            anchors.fill: parent
            ScrollView {
                height: stack.height
                width: parent.width
                anchors.top: parent.top
                anchors.left: parent.left

                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                contentHeight: addressSelector.height + networkSelector.height + gasSelector.height + gasValidator.height
                clip: true

                TabAddressSelectorView {
                    id: addressSelector
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    store: popup.store
                    onContactSelected:  {
                        if(!!popup.advancedHeader)
                            advancedHeader.recipientSelector.input.text = address
                    }
                }

                NetworkSelector {
                    id: networkSelector
                    anchors.top: addressSelector.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                    visible: popup.store.isMultiNetworkEnabled
                    onNetworkChanged: function(chainId) {
                        gasSelector.suggestedFees = popup.store.suggestedFees(chainId)
                    }
                }

                GasSelector {
                    id: gasSelector
                    anchors.top: networkSelector.bottom
                    getGasEthValue: popup.store.getGasEthValue
                    getFiatValue: popup.store.getFiatValue
                    defaultCurrency: popup.store.currentCurrency

                    width: stack.width
                    property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                        if (!(advancedHeader.accountSelector.selectedAccount && advancedHeader.accountSelector.selectedAccount.address &&
                            advancedHeader.recipientSelector.selectedRecipient && advancedHeader.recipientSelector.selectedRecipient.address &&
                            advancedHeader.assetSelector.selectedAsset && advancedHeader.assetSelector.selectedAsset.symbol &&
                            advancedHeader.amountToSendInput.text)) {
                            selectedGasLimit = 250000
                            defaultGasLimit = selectedGasLimit
                            return
                        }

                        let gasEstimate = JSON.parse(popup.store.estimateGas(
                                                        advancedHeader.accountSelector.selectedAccount.address,
                                                        advancedHeader.recipientSelector.selectedRecipient.address,
                                                        advancedHeader.assetSelector.selectedAsset.symbol,
                                                        advancedHeader.amountToSendInput.text,
                                                        networkSelector.selectedNetwork.chainId || Global.currentChainId,
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
                    selectedAccount: advancedHeader.accountSelector.selectedAccount
                    selectedAmount: advancedHeader.amountToSendInput.text === "" ? 0.0
                                                                                 : parseFloat(advancedHeader.amountToSendInput.text)
                    selectedAsset: advancedHeader.assetSelector.selectedAsset
                    selectedGasEthValue: gasSelector.selectedGasEthValue
                    selectedNetwork: networkSelector.selectedNetwork
                }
            }
        }
        TransactionFormGroup {
            id: group4

            StackView.onActivated: {
                transactionSigner.forceActiveFocus(Qt.MouseFocusReason)
            }

            TransactionSigner {
                id: transactionSigner
                Layout.topMargin: Style.current.smallPadding
                width: stack.width
                signingPhrase: popup.store.signingPhrase
            }
        }
    }

    advancedFooterComponent: SendModalFooter {
        maxFiatFees: gasSelector.maxFiatFees
        currentGroupPending: popup.contentItem.currentGroup.isPending
        currentGroupValid: popup.contentItem.currentGroup.isValid
        isLastGroup: popup.contentItem.isLastGroup
        onNextButtonClicked: {
            const validity = popup.contentItem.currentGroup.validate()
            if (validity.isValid && !validity.isPending) {
                if (popup.contentItem.isLastGroup) {
                    return popup.sendTransaction()
                }

                if(gasSelector.suggestedFees.eip1559Enabled && popup.contentItem.currentGroup === group1 && gasSelector.advancedMode){
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
                                                 popup.contentItem.next();
                                             }
                                         })
                        return
                    }
                }

                popup.contentItem.next()
            }
        }
    }

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup {}
    }

    Connections {
        target: advancedHeader
        onIsReadyChanged: {
            if(!advancedHeader.isReady && popup.contentItem.isLastGroup)
                popup.contentItem.back()

        }
    }

    Connections {
        target: popup.store.walletSectionTransactionsInst
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

                let url = `${popup.store.getEtherscanLink()}/${response.result}`
                Global.displayToastMessage(qsTr("Transaction pending..."),
                                           qsTr("View on etherscan"),
                                           "",
                                           true,
                                           Constants.ephemeralNotificationType.normal,
                                           url)
                popup.close()
            } catch (e) {
                console.error('Error parsing the response', e)
            }
        }
        // Not Refactored Yet
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

