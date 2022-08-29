import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared.stores 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

import "../panels"
import "../controls"
import "../views"

StatusDialog {
    id: popup

    property alias addressText: recipientSelector.input.text

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
        let recipientAddress = Utils.isValidAddress(popup.addressText) ? popup.addressText : d.resolvedENSAddress
        let success = false
        d.isPending = true
        success = popup.store.transfer(
                    popup.selectedAccount.address,
                    recipientAddress,
                    assetSelector.selectedAsset.symbol,
                    amountToSendInput.text,
                    gasSelector.selectedGasLimit,
                    gasSelector.suggestedFees.eip1559Enabled ? "" : gasSelector.selectedGasPrice,
                    gasSelector.selectedTipLimit,
                    gasSelector.selectedOverallLimit,
                    transactionSigner.enteredPassword,
                    networkSelector.selectedNetwork.chainId,
                    d.uuid,
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

    enum StackGroup {
        SendDetailsGroup = 0,
        AuthenticationGroup = 1
    }

    QtObject {
        id: d
        readonly property string maxFiatBalance: Utils.stripTrailingZeros(parseFloat(assetSelector.selectedAsset.totalBalance).toFixed(4))
        readonly property bool isReady: amountToSendInput.valid && !amountToSendInput.pending && recipientReady
        readonly property bool errorMode: networkSelector.suggestedRoutes && networkSelector.suggestedRoutes.length <= 0 || networkSelector.errorMode
        readonly property bool recipientReady: (isAddressValid || isENSValid) && !recipientSelector.isPending
        readonly property bool isAddressValid: Utils.isValidAddress(recipientSelector.input.text)
        property bool isENSValid: false
        readonly property var resolveENS: Backpressure.debounce(popup, 500, function (ensName) {
            store.resolveENS(ensName)
        })
        property string resolvedENSAddress
        onIsReadyChanged: {
            if(!isReady && isLastGroup)
                stack.currentIndex = SendModal.StackGroup.SendDetailsGroup
        }
        readonly property string uuid: Utils.uuid()
        readonly property bool isLastGroup: stack.currentIndex === (stack.count - 1)
        property bool isPending: false
    }

    width: 556
    topMargin: 64 + header.height

    padding: 0
    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    onSelectedAccountChanged: popup.recalculateRoutesAndFees()

    onOpened: {
        amountToSendInput.input.edit.forceActiveFocus()

        if(popup.launchedFromChat) {
            recipientSelector.input.edit.readOnly = true
            recipientSelector.input.text = popup.preSelectedRecipient.name
        }

        popup.recalculateRoutesAndFees()
    }

    header: SendModalHeader {
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        model: popup.store.accounts
        selectedAccount: popup.selectedAccount
        changeSelectedAccount: function(newIndex) {
            if (newIndex > popup.store.accounts) {
                return
            }
            popup.store.switchAccount(newIndex)
        }
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: 0
        clip: true
        ColumnLayout {
            id: group1
            Layout.preferredWidth: parent.width
            spacing: Style.current.padding

            Rectangle {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: assetAndAmmountSelector.height + Style.current.padding
                color: Theme.palette.baseColor3

                layer.enabled: scrollView.contentY > -8
                layer.effect: DropShadow {
                    verticalOffset: 2
                    radius: 16
                    samples: 17
                    color: Theme.palette.dropShadow
                }


                Column {
                    id: assetAndAmmountSelector
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.current.xlPadding
                    anchors.rightMargin: Style.current.xlPadding
                    z: 1

                    Row {
                        spacing: 16
                        StatusBaseText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Send")
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                        }
                        StatusListItemTag {
                            height: 22
                            width: childrenRect.width
                            title: assetSelector.selectedAsset.totalBalance > 0 ? qsTr("Max: %1").arg(assetSelector.selectedAsset ? d.maxFiatBalance : "0.00") : qsTr("No balances active")
                            closeButtonVisible: false
                            titleText.font.pixelSize: 12
                            color: d.errorMode ? Theme.palette.dangerColor2 : Theme.palette.primaryColor3
                            titleText.color: d.errorMode ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
                        }
                    }
                    Item {
                        width: parent.width
                        height: amountToSendInput.height
                        AmountInputWithCursor {
                            id: amountToSendInput
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: -Style.current.padding
                            width: parent.width - assetSelector.width
                            placeholderText: "0.00  %1".arg(assetSelector.selectedAsset.symbol)
                            input.edit.color: d.errorMode ? Theme.palette.dangerColor1 : Theme.palette.directColor1
                            validators: [
                                StatusFloatValidator{
                                    id: floatValidator
                                    bottom: 0
                                    top: d.maxFiatBalance
                                    errorMessage: ""
                                }
                            ]
                            Keys.onReleased: {
                                let amount = amountToSendInput.text.trim()

                                if (!Utils.containsOnlyDigits(amount) || isNaN(amount)) {
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
                                return "%1 %2".arg(Utils.toLocaleString(currencyBalance.toFixed(2), popup.store.locale, {"currency": true})).arg(popup.store.currentCurrency.toUpperCase())
                            }
                            tokenAssetSourceFn: function (symbol) {
                                return symbol ? Style.png("tokens/%1".arg(symbol)) : defaultToken
                            }
                            searchTokenSymbolByAddressFn: function (address) {
                                if(popup.selectedAccount) {
                                    return popup.selectedAccount.findTokenSymbolByAddress(address)
                                }
                                return ""
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
                    StatusInput {
                        id: txtFiatBalance
                        anchors.left: parent.left
                        anchors.leftMargin: -12
                        leftPadding: 0
                        rightPadding: 0
                        font.weight: Font.Medium
                        font.pixelSize: 13
                        input.placeholderFont.pixelSize: 13
                        input.leftPadding: 0
                        input.rightPadding: 0
                        input.topPadding: 0
                        input.bottomPadding: 0
                        input.edit.padding: 0
                        input.background.color: "transparent"
                        input.background.border.width: 0
                        input.edit.color: txtFiatBalance.input.edit.activeFocus ? Theme.palette.directColor1 : Theme.palette.baseColor1
                        text: "0.00"
                        placeholderText: "0.00"
                        input.implicitHeight: 15
                        implicitWidth: txtFiatBalance.input.edit.contentWidth + 50
                        input.rightComponent: StatusBaseText {
                            id: currencyText
                            text: popup.store.currentCurrency.toUpperCase()
                            font.pixelSize: 13
                            color: Theme.palette.directColor5
                        }
                        Keys.onReleased: {
                            let balance = txtFiatBalance.text.trim()
                            if (balance === "" || isNaN(balance)) {
                                return
                            }
                            // To-Do Not refactored yet
                            // amountToSendInput.text = root.getCryptoValue(balance, popup.store.currentCurrency, assetSelector.selectedAsset.symbol)
                        }
                    }
                }
            }

            StatusScrollView {
                id: scrollView
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width
                contentHeight: layout.height
                contentWidth: parent.width
                z: 0
                objectName: "sendModalScroll"

                Column {
                    id: layout
                    width: scrollView.availableWidth
                    spacing: Style.current.halfPadding
                    anchors.left: parent.left

                    StatusInput {
                        id: recipientSelector
                        property bool isPending: false

                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding

                        label: qsTr("To")
                        placeholderText: qsTr("Enter an ENS name or address")
                        input.background.color: Theme.palette.indirectColor1
                        input.background.border.width: 0
                        input.implicitHeight: 56
                        input.clearable: true
                        multiline: false
                        input.rightComponent: RowLayout {
                            StatusButton {
                                visible: recipientSelector.text === ""
                                borderColor: Theme.palette.primaryColor1
                                size: StatusBaseButton.Size.Tiny
                                text: qsTr("Paste")
                                onClicked: recipientSelector.input.edit.paste()
                            }
                            StatusFlatRoundButton {
                                visible: recipientSelector.text !== ""
                                type: StatusFlatRoundButton.Type.Secondary
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                icon.name: "clear"
                                icon.width: 16
                                icon.height: 16
                                icon.color: Theme.palette.baseColor1
                                backgroundHoverColor: "transparent"
                                onClicked: recipientSelector.input.edit.clear()
                            }
                        }
                        Keys.onReleased: {
                            if(!d.isAddressValid) {
                                isPending = true
                                Qt.callLater(d.resolveENS, input.edit.text)
                            }
                        }
                    }

                    Connections {
                        target: store.mainModuleInst
                        onResolvedENS: {
                            recipientSelector.isPending = false
                            if(Utils.isValidAddress(resolvedAddress)) {
                                d.resolvedENSAddress = resolvedAddress
                                d.isENSValid = true
                            }
                        }
                    }

                    TabAddressSelectorView {
                        id: addressSelector
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        onContactSelected:  {
                            recipientSelector.input.text = address
                        }
                        visible: !d.recipientReady
                    }

                    NetworkSelector {
                        id: networkSelector
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        selectedAccount: popup.selectedAccount
                        amountToSend: isNaN(parseFloat(amountToSendInput.text)) ? 0 : parseFloat(amountToSendInput.text)
                        requiredGasInEth: gasSelector.selectedGasEthValue
                        assets: popup.selectedAccount.assets
                        selectedAsset: assetSelector.selectedAsset
                        onNetworkChanged: function(chainId) {
                            gasSelector.suggestedFees = popup.store.suggestedFees(chainId)
                            gasSelector.updateGasEthValue()
                        }
                        onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees(disabledChainIds)
                        visible: d.recipientReady
                    }

                    Rectangle {
                        id: fees
                        radius: 13
                        color: Theme.palette.indirectColor1
                        height: text.height + gasSelector.height + gasValidator.height + Style.current.xlPadding
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        visible: d.recipientReady

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
                                asset.name: "fees"
                            }
                            Column {
                                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                                Layout.preferredWidth: fees.width - feesIcon.width - Style.current.xlPadding
                                StatusBaseText {
                                    id: text
                                    width: 410
                                    font.pixelSize: 15
                                    font.weight: Font.Medium
                                    color: Theme.palette.directColor1
                                    text: qsTr("Fees")
                                    wrapMode: Text.WordWrap
                                }
                                GasSelector {
                                    id: gasSelector
                                    width: parent.width
                                    getGasEthValue: popup.store.getGasEthValue
                                    getFiatValue: popup.store.getFiatValue
                                    getEstimatedTime: popup.store.getEstimatedTime
                                    defaultCurrency: popup.store.currentCurrency
                                    chainId: networkSelector.selectedNetwork && networkSelector.selectedNetwork.chainId ? networkSelector.selectedNetwork.chainId : 1
                                    property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                                        if (!(popup.selectedAccount && popup.selectedAccount.address &&
                                              popup.addressText && assetSelector.selectedAsset &&
                                              assetSelector.selectedAsset.symbol && amountToSendInput.text)) {
                                            selectedGasLimit = 250000
                                            defaultGasLimit = selectedGasLimit
                                            return
                                        }

                                        var chainID = networkSelector.selectedNetwork ? networkSelector.selectedNetwork.chainId: 1

                                        var recipientAddress = popup.launchedFromChat ? popup.preSelectedRecipient.address : popup.addressText

                                        let gasEstimate = JSON.parse(popup.store.estimateGas(
                                                                         popup.selectedAccount.address,
                                                                         recipientAddress,
                                                                         assetSelector.selectedAsset.symbol,
                                                                         amountToSendInput.text,
                                                                         chainID,
                                                                         ""))

                                        if (!gasEstimate.success) {
                                            console.warn("error estimating gas: ", gasEstimate.error.message)
                                            return
                                        }

                                        selectedGasLimit = gasEstimate.result
                                        defaultGasLimit = selectedGasLimit
                                    })
                                }
                                GasValidator {
                                    id: gasValidator
                                    width: parent.width
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
        }

        Column{
            id: group2
            Layout.preferredWidth: parent.width
            TransactionSigner {
                id: transactionSigner
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: Style.current.smallPadding
                anchors.margins: 32
                signingPhrase: popup.store.signingPhrase
            }
        }
    }

    footer: SendModalFooter {
        maxFiatFees: gasSelector.maxFiatFees
        estimatedTxTimeFlag: gasSelector.estimatedTxTimeFlag
        pending: d.isPending
        isLastGroup: d.isLastGroup
        visible: d.isReady && !isNaN(parseFloat(amountToSendInput.text)) && gasValidator.isValid
        onNextButtonClicked: {
            if (isLastGroup) {
                return popup.sendTransaction()
            }

            if(gasSelector.suggestedFees.eip1559Enabled && gasSelector.advancedMode){
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
                                             stack.currentIndex = SendModal.StackGroup.AuthenticationGroup
                                         }
                                     })
                    return
                }
            }
            stack.currentIndex = SendModal.StackGroup.AuthenticationGroup
        }
    }

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup {}
    }

    Connections {
        target: popup.store.walletSectionTransactionsInst
        onTransactionSent: {
            d.isPending = false
            try {
                let response = JSON.parse(txResult)
                if (response.uuid !== d.uuid) return

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

