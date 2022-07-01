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
    property var selectedAccount: store.currentAccount
    property var preSelectedRecipient
    property bool launchedFromChat: false
    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    function sendTransaction() {
        stack.currentGroup.isPending = true
        let success = false
        success = popup.store.transfer(
            popup.selectedAccount.address,
            recipientSelector.selectedRecipient.address,
            assetSelector.selectedAsset.symbol,
            amountToSendInput.text,
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

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function(disabledChainIds) {
        if (disabledChainIds === undefined) disabledChainIds = []
        networkSelector.suggestedRoutes = popup.store.suggestedRoutes(
            popup.selectedAccount.address, amountToSendInput.text, assetSelector.selectedAsset.symbol, disabledChainIds
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

    QtObject {
        id: d
        readonly property string maxFiatBalance: Utils.stripTrailingZeros(parseFloat(assetSelector.selectedAsset.totalBalance).toFixed(4))
        readonly property bool isReady: amountToSendInput.valid && !amountToSendInput.pending && recipientSelector.isValid && !recipientSelector.isPending
        readonly property bool errorMode: networkSelector.suggestedRoutes && networkSelector.suggestedRoutes.length <= 0 || networkSelector.errorMode
        onIsReadyChanged: {
            if(!isReady && stack.isLastGroup)
                stack.back()
        }
    }

    width: 556
    height: 595
    showHeader: false
    showFooter: false
    showAdvancedFooter: d.isReady && !isNaN(parseFloat(amountToSendInput.text)) && gasValidator.isValid
    showAdvancedHeader: true

    onSelectedAccountChanged: popup.recalculateRoutesAndFees()

    onOpened: {
        amountToSendInput.input.edit.forceActiveFocus()

        if(popup.launchedFromChat) {
            recipientSelector.selectedType = RecipientSelector.Type.Contact
            recipientSelector.readOnly = true
            recipientSelector.selectedRecipient = popup.preSelectedRecipient
        }

        popup.recalculateRoutesAndFees()
    }

    hasFloatingButtons: true
    advancedHeaderComponent: SendModalHeader {
        model: popup.store.accounts
        selectedAccount: popup.selectedAccount
        onUpdatedSelectedAccount: {
            popup.selectedAccount = account
        }
    }

   TransactionStackView {
        id: stack
        property alias currentGroup: stack.currentGroup
        anchors.leftMargin: Style.current.xlPadding
        anchors.topMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        anchors.bottomMargin: popup.showAdvancedFooter  && !!advancedFooter ? advancedFooter.height : Style.current.padding
        TransactionFormGroup {
            id: group1
            anchors.fill: parent

            ColumnLayout {
                id: assetAndAmmountSelector
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                RowLayout {
                    spacing: 16
                    StatusBaseText {
                        text: qsTr("Send")
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                        Layout.alignment: Qt.AlignVCenter
                    }
                    StatusListItemTag {
                        title: assetSelector.selectedAsset.totalBalance > 0 ? qsTr("Max: ") + (assetSelector.selectedAsset ? d.maxFiatBalance : "0.00") : qsTr("No balances active")
                        closeButtonVisible: false
                        titleText.font.pixelSize: 12
                        Layout.preferredHeight: 22
                        Layout.preferredWidth: childrenRect.width
                        color: d.errorMode ? Theme.palette.dangerColor2 : Theme.palette.primaryColor3
                        titleText.color: d.errorMode ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    AmountInputWithCursor {
                        id: amountToSendInput
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: parent.width - assetSelector.width
                        input.placeholderText: "0.00" + " " + assetSelector.selectedAsset.symbol
                        errorMessageCmp.anchors.rightMargin: -100
                        input.edit.color: d.errorMode ? Theme.palette.dangerColor1 : Theme.palette.directColor1
                        validators: [
                            StatusFloatValidator{
                                id: floatValidator
                                bottom: 0
                                top: d.maxFiatBalance
                                errorMessage: qsTr("Please enter a valid amount")
                            }
                        ]
                        Keys.onReleased: {
                            let amount = amountToSendInput.text.trim()

                            if (isNaN(amount)) {
                                return
                            }
                            if (amount === "") {
                                txtFiatBalance.text = "0.00"
                            } else {
                                txtFiatBalance.text = popup.store.getFiatValue(amount, assetSelector.selectedAsset.symbol, popup.store.currentCurrency)
                            }
                            gasSelector.estimateGas()
                            popup.recalculateRoutesAndFees()
                        }
                    }
                    StatusAssetSelector {
                        id: assetSelector
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        assets: popup.selectedAccount.assets
                        defaultToken: Style.png("tokens/DEFAULT-TOKEN@3x")
                        getCurrencyBalanceString: function (currencyBalance) {
                            return Utils.toLocaleString(currencyBalance.toFixed(2), popup.store.locale, {"currency": true}) + " " + popup.store.currentCurrency.toUpperCase()
                        }
                        tokenAssetSourceFn: function (symbol) {
                            return symbol ? Style.png("tokens/" + symbol) : defaultToken
                        }
                        onSelectedAssetChanged: {
                            if (!assetSelector.selectedAsset) {
                                return
                            }
                            if (amountToSendInput.text === "" || isNaN(amountToSendInput.text)) {
                                return
                            }
                            txtFiatBalance.text = popup.store.getFiatValue(amountToSendInput.text, assetSelector.selectedAsset.symbol, popup.store.currentCurrency)
                            gasSelector.estimateGas()
                            popup.recalculateRoutesAndFees()
                        }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    StyledTextField {
                        id: txtFiatBalance
                        color: txtFiatBalance.activeFocus ? Style.current.textColor : Style.current.secondaryText
                        font.weight: Font.Medium
                        font.pixelSize: 12
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0.00"
                        selectByMouse: true
                        background: Rectangle {
                            color: Style.current.transparent
                        }
                        padding: 0
                        Keys.onReleased: {
                            let balance = txtFiatBalance.text.trim()
                            if (balance === "" || isNaN(balance)) {
                                return
                            }
                            // To-Do Not refactored yet
                            // amountToSendInput.text = root.getCryptoValue(balance, popup.store.currentCurrency, assetSelector.selectedAsset.symbol)
                        }
                    }
                    StatusBaseText {
                        id: currencyText
                        text: popup.store.currentCurrency.toUpperCase()
                        font.pixelSize: 13
                        color: Theme.palette.directColor5
                    }
                }
            }

            Rectangle {
                id: border
                anchors.top: assetAndAmmountSelector.bottom
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.xlPadding

                width: popup.width
                height: 1
                color: Theme.palette.directColor8
                visible: false
            }

            DropShadow {
                anchors.fill: border
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8.0
                samples: 17
                color: Theme.palette.directColor1
                source: border
            }

            ScrollView {
                id: scrollView
                height: stack.height - assetAndAmmountSelector.height
                width: parent.width
                anchors.top: border.bottom
                anchors.topMargin: Style.current.halfPadding
                anchors.left: parent.left

                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                contentHeight: recipientSelector.height + addressSelector.height + networkSelector.height + fees.height + Style.current.halfPadding
                clip: true

                // To-do use standard StatusInput component once the flow for ens name resolution is clear
                RecipientSelector {
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.halfPadding
                    anchors.right: parent.right
                    anchors.left: parent.left

                    id: recipientSelector
                    accounts: popup.store.accounts
                    contactsStore: popup.contactsStore
                    label: qsTr("To")
                    Layout.fillWidth: true
                    input.placeholderText: qsTr("Enter an ENS name or address")
                    input.anchors.leftMargin: 0
                    input.anchors.rightMargin: 0
                    labelFont.pixelSize: 15
                    labelFont.weight: Font.Normal
                    input.height: 56
                    isSelectorVisible: false
                    addContactEnabled: false
                    onSelectedRecipientChanged: gasSelector.estimateGas()
                }

                TabAddressSelectorView {
                    id: addressSelector
                    anchors.top: recipientSelector.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                    store: popup.store
                    onContactSelected:  {
                        recipientSelector.input.text = address
                    }
                }

                NetworkSelector {
                    id: networkSelector
                    store: popup.store
                    selectedAccount: popup.selectedAccount
                    anchors.top: addressSelector.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                    amountToSend: isNaN(parseFloat(amountToSendInput.text)) ? 0 : parseFloat(amountToSendInput.text)
                    requiredGasInEth: gasSelector.selectedGasEthValue
                    assets: popup.selectedAccount.assets
                    selectedAsset: assetSelector.selectedAsset
                    onNetworkChanged: function(chainId) {
                        gasSelector.suggestedFees = popup.store.suggestedFees(chainId)
                        gasSelector.updateGasEthValue()
                    }
                    onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees(disabledChainIds)
                }

                Rectangle {
                    id: fees
                    radius: 13
                    color: Theme.palette.indirectColor1
                    anchors.top: networkSelector.bottom
                    width: parent.width
                    height: gasSelector.visible || gasValidator.visible ? feesLayout.height + gasValidator.height : 0

                    RowLayout {
                        id: feesLayout
                        spacing: 10
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: Style.current.padding

                        StatusRoundIcon {
                            id: feesIcon
                            Layout.alignment: Qt.AlignTop
                            radius: 8
                            icon.name: "fees"
                        }
                        ColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            GasSelector {
                                id: gasSelector
                                Layout.preferredWidth: fees.width - feesIcon.width - Style.current.xlPadding
                                getGasEthValue: popup.store.getGasEthValue
                                getFiatValue: popup.store.getFiatValue
                                getEstimatedTime: popup.store.getEstimatedTime
                                defaultCurrency: popup.store.currentCurrency
                                chainId: networkSelector.selectedNetwork && networkSelector.selectedNetwork.chainId ? networkSelector.selectedNetwork.chainId : 1
                                property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                                    if (!(popup.selectedAccount && popup.selectedAccount.address &&
                                          recipientSelector.selectedRecipient && recipientSelector.selectedRecipient.address &&
                                          assetSelector.selectedAsset && assetSelector.selectedAsset.symbol &&
                                          amountToSendInput.text)) {
                                        selectedGasLimit = 250000
                                        defaultGasLimit = selectedGasLimit
                                        return
                                    }

                                    var chainID = networkSelector.selectedNetwork ? networkSelector.selectedNetwork.chainId: 1

                                    let gasEstimate = JSON.parse(popup.store.estimateGas(
                                                                     popup.selectedAccount.address,
                                                                     recipientSelector.selectedRecipient.address,
                                                                     assetSelector.selectedAsset.symbol,
                                                                     amountToSendInput.text,
                                                                     chainID || Global.currentChainId,
                                                                     ""))

                                    if (!gasEstimate.success) {

                                        console.warn(qsTrId("error-estimating-gas---1").arg(gasEstimate.error.message))
                                        return
                                    }

                                    selectedGasLimit = gasEstimate.result
                                    defaultGasLimit = selectedGasLimit
                                })
                            }
                            GasValidator {
                                id: gasValidator
                                anchors.horizontalCenter: undefined
                                Layout.alignment: Qt.AlignHCenter
                                selectedAccount: popup.selectedAccount
                                selectedAmount: amountToSendInput.text === "" ? 0.0 :
                                                parseFloat(amountToSendInput.text)
                                selectedAsset: assetSelector.selectedAsset
                                selectedGasEthValue: gasSelector.selectedGasEthValue
                                selectedNetwork: networkSelector.selectedNetwork ? networkSelector.selectedNetwork: null
                            }
                        }
                    }
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
        estimatedTxTimeFlag: gasSelector.estimatedTxTimeFlag
        currentGroupPending: stack.currentGroup.isPending
        currentGroupValid: stack.currentGroup.isValid
        isLastGroup: stack.isLastGroup
        onNextButtonClicked: {
            const validity = stack.currentGroup.validate()
            if (validity.isValid && !validity.isPending) {
                if (stack.isLastGroup) {
                    return popup.sendTransaction()
                }

                if(gasSelector.suggestedFees.eip1559Enabled && stack.currentGroup === group1 && gasSelector.advancedMode){
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

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup {}
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
                        transactionSigner.validationError = qsTr("Wrong password")
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
        //                    Global.toastMessage.title = qsTr("Wrong password")
        //                    Global.toastMessage.source = Style.svg("check-circle")
        //                    Global.toastMessage.iconColor = Style.current.success
        //                } else {
        //                    //% "Transaction failed"
        //                    Global.toastMessage.title = qsTr("Wrong password")
        //                    Global.toastMessage.source = Style.svg("block-icon")
        //                    Global.toastMessage.iconColor = Style.current.danger
        //                }
        //                Global.toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txHash}`
        //                Global.toastMessage.open()
        //            }
    }
}

