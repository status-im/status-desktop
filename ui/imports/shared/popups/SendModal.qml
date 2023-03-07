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

    property bool isBridgeTx: false

    property string preSelectedRecipient
    property string preDefinedAmountToSend
    property var preSelectedAsset
    property bool interactive: true

    property alias modalHeader: modalHeader.text

    property var store: TransactionStore{}
    property var contactsStore: store.contactStore
    property var currencyStore: store.currencyStore
    property var selectedAccount: store.currentAccount
    property var bestRoutes
    property string addressText
    property bool isLoading: false
    property int sendType: isBridgeTx ? Constants.SendType.Bridge : Constants.SendType.Transfer
    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    Connections {
        target: store.currentAccount.assets
        function onModelReset() {
            popup.selectedAccount =  null
            popup.selectedAccount = store.currentAccount
        }
    }

    property var sendTransaction: function() {
        let recipientAddress = Utils.isValidAddress(popup.addressText) ? popup.addressText : d.resolvedENSAddress
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(
                    popup.selectedAccount.address,
                    recipientAddress,
                    d.selectedSymbol,
                    amountToSendInput.cryptoValueToSend,
                    d.uuid,
                    JSON.stringify(popup.bestRoutes)
                    )
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.selectedAccount && !!assetSelector.selectedAsset && d.recipientReady && amountToSendInput.input.valid) {
            popup.isLoading = true
            let amount = Math.round(amountToSendInput.cryptoValueToSend * Math.pow(10, assetSelector.selectedAsset.decimals))
            popup.store.suggestedRoutes(popup.selectedAccount.address, amount.toString(16), assetSelector.selectedAsset.symbol,
                                        store.disabledChainIdsFromList, store.disabledChainIdsToList,
                                        store.preferredChainIds, popup.sendType, store.lockedInAmounts)
        }
    })

    QtObject {
        id: d
        readonly property int errorType: !amountToSendInput.input.valid ? Constants.SendAmountExceedsBalance :
                                                                          (networkSelector.bestRoutes && networkSelector.bestRoutes.length <= 0 && !!amountToSendInput.input.text && recipientReady && !popup.isLoading) ?
                                                                              Constants.NoRoute : Constants.NoError
        readonly property double maxFiatBalance: !!assetSelector.selectedAsset ? assetSelector.selectedAsset.totalCurrencyBalance.amount : 0
        readonly property double maxCryptoBalance: !!assetSelector.selectedAsset ? assetSelector.selectedAsset.totalBalance.amount : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string selectedSymbol: !!assetSelector.selectedAsset ? assetSelector.selectedAsset.symbol : ""
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? popup.store.currentCurrency : selectedSymbol
        readonly property bool errorMode: popup.isLoading || !recipientReady ? false : errorType !== Constants.NoError || networkSelector.errorMode || isNaN(amountToSendInput.input.text)
        readonly property bool recipientReady: (isAddressValid || isENSValid) && !recipientSelector.isPending
        property bool isAddressValid: Utils.isValidAddress(popup.addressText)
        property bool isENSValid: false
        readonly property var resolveENS: Backpressure.debounce(popup, 500, function (ensName) {
            store.resolveENS(ensName)
        })
        property string resolvedENSAddress
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInEth
        property double totalFeesInFiat
        property double totalAmountToReceive

        property Timer waitTimer: Timer {
            interval: 1500
            onTriggered: {
                if (recipientSelector.isPending) {
                    return
                }
                if (d.isENSValid)  {
                    recipientSelector.input.text = d.resolvedENSAddress
                    popup.addressText = d.resolvedENSAddress
                } else {
                    let result = store.splitAndFormatAddressPrefix(recipientSelector.input.text, isBridgeTx, networkSelector.showUnpreferredNetworks)
                    popup.addressText = result.address
                    recipientSelector.input.text = result.formattedText
                }
                
                popup.recalculateRoutesAndFees()
            }
        }

        onErrorTypeChanged: {
            if(errorType === Constants.SendAmountExceedsBalance)
                bestRoutes = []
        }
    }

    width: 556
    topMargin: 64 + header.height

    padding: 0
    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    onIsLoadingChanged: if(isLoading) bestRoutes = []

    onSelectedAccountChanged: popup.recalculateRoutesAndFees()

    onOpened: {
        if(!isBridgeTx) {
            store.setDefaultPreferredDisabledChains()
        }
        else {
            store.setAllNetworksAsPreferredChains()
        }

        amountToSendInput.input.input.edit.forceActiveFocus()

        if(!!popup.preSelectedAsset) {
            assetSelector.selectedAsset = popup.preSelectedAsset
        }

        if(!!popup.preDefinedAmountToSend) {
            amountToSendInput.input.text = popup.preDefinedAmountToSend
        }

        if(!!popup.preSelectedRecipient) {
            recipientSelector.input.text = popup.preSelectedRecipient
            d.waitTimer.restart()
        }

        if(popup.isBridgeTx) {
            recipientSelector.input.text = popup.selectedAccount.address
            d.waitTimer.restart()
        }
    }

    onClosed: popup.store.resetTxStoreProperties()

    header: AccountsModalHeader {
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        model: popup.store.accounts
        selectedAccount: popup.selectedAccount
        changeSelectedAccount: function(newAccount, newIndex) {
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
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: assetAndAmountSelector.implicitHeight + Style.current.halfPadding

                color: Theme.palette.baseColor3
                z: 100

                layer.enabled: scrollView.contentY > 0
                layer.effect: DropShadow {
                    verticalOffset: 0
                    radius: 8
                    samples: 17
                    color: Theme.palette.dropShadow
                }

                ColumnLayout {
                    id: assetAndAmountSelector

                    anchors.fill: parent
                    anchors.leftMargin: Style.current.xlPadding
                    anchors.rightMargin: Style.current.xlPadding

                    z: 1
                    spacing: 16

                    RowLayout {
                        spacing: 8
                        StatusBaseText {
                            id: modalHeader
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            text: popup.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
                            font.pixelSize: 28
                            lineHeight: 38
                            lineHeightMode: Text.FixedHeight
                            font.letterSpacing: -0.4
                            color: Theme.palette.directColor1
                            Layout.maximumWidth: contentWidth
                        }
                        StatusAssetSelector {
                            id: assetSelector
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            enabled: popup.interactive
                            assets: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : []
                            defaultToken: Style.png("tokens/DEFAULT-TOKEN@3x")
                            placeholderText: qsTr("Select token")
                            currentCurrencySymbol: RootStore.currencyStore.currentCurrencySymbol
                            tokenAssetSourceFn: function (symbol) {
                                return symbol ? Style.png("tokens/%1".arg(symbol)) : defaultToken
                            }
                            searchTokenSymbolByAddressFn: function (address) {
                                if(popup.selectedAccount) {
                                    return popup.selectedAccount.findTokenSymbolByAddress(address)
                                }
                                return ""
                            }
                            getNetworkIcon: function(chainId){
                                return RootStore.getNetworkIcon(chainId)
                            }
                            onSelectedAssetChanged: {
                                if (!assetSelector.selectedAsset || !amountToSendInput.input.text || isNaN(amountToSendInput.input.text)) {
                                    return
                                }
                                popup.recalculateRoutesAndFees()
                            }
                        }
                        StatusListItemTag {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.preferredHeight: 22
                            title: {
                                if (d.maxInputBalance <= 0)
                                    return qsTr("No balances active")
                                const balance = popup.currencyStore.formatCurrencyAmount(d.maxInputBalance, d.inputSymbol)
                                return qsTr("Max: %1").arg(balance)
                            }
                            closeButtonVisible: false
                            titleText.font.pixelSize: 12
                            bgColor: amountToSendInput.input.valid ? Theme.palette.primaryColor3 : Theme.palette.dangerColor2
                            titleText.color: amountToSendInput.input.valid ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
                        }
                    }
                    RowLayout {
                        AmountToSend {
                            id: amountToSendInput
                            Layout.fillWidth:true
                            isBridgeTx: popup.isBridgeTx
                            interactive: popup.interactive
                            selectedSymbol: d.selectedSymbol
                            maxInputBalance: d.maxInputBalance
                            currentCurrency: popup.store.currentCurrency
                            getFiatValue: function(cryptoValue) {
                                return selectedSymbol ? popup.currencyStore.getFiatValue(cryptoValue, selectedSymbol, currentCurrency) : 0.0
                            }
                            getCryptoValue: function(fiatValue) {
                                return selectedSymbol ? popup.currencyStore.getCryptoValue(fiatValue, selectedSymbol, currentCurrency) : 0.0
                            }
                            formatCurrencyAmount: popup.currencyStore.formatCurrencyAmount
                            onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                        }

                        // Horizontal spacer
                        RowLayout {}

                        AmountToReceive {
                            id: amountToReceive
                            Layout.alignment: Qt.AlignRight
                            Layout.fillWidth:true
                            visible: popup.bestRoutes !== undefined && popup.bestRoutes.length > 0 && !!amountToSendInput.input.text && amountToSendInput.input.valid
                            store: popup.store
                            isLoading: popup.isLoading
                            selectedSymbol: d.selectedSymbol
                            isBridgeTx: popup.isBridgeTx
                            cryptoValueToReceive: d.totalAmountToReceive
                            inputIsFiat: amountToSendInput.inputIsFiat
                            minCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                            minFiatDecimals: amountToSendInput.minReceiveFiatDecimals
                            currentCurrency: popup.store.currentCurrency
                            getFiatValue: function(cryptoValue) {
                                return popup.currencyStore.getFiatValue(cryptoValue, selectedSymbol, currentCurrency)
                            }
                            formatCurrencyAmount: popup.currencyStore.formatCurrencyAmount
                        }
                    }
                    TokenListView {
                        id: tokenListRect

                        Layout.fillWidth: true

                        visible: !assetSelector.selectedAsset
                        assets: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : []
                        searchTokenSymbolByAddressFn: function (address) {
                            if(popup.selectedAccount) {
                                return popup.selectedAccount.findTokenSymbolByAddress(address)
                            }
                            return ""
                        }
                        getNetworkIcon: function(chainId){
                            return RootStore.getNetworkIcon(chainId)
                        }
                        onTokenSelected: {
                            assetSelector.userSelectedToken = selectedToken.symbol
                            assetSelector.selectedAsset = selectedToken
                        }
                    }
                }
            }

            StatusScrollView {
                id: scrollView
                topPadding: 12

                implicitWidth: contentWidth + leftPadding + rightPadding
                implicitHeight: contentHeight + topPadding + bottomPadding
                Layout.fillWidth: true
                Layout.fillHeight: true

                contentHeight: layout.height + Style.current.padding

                z: 0
                objectName: "sendModalScroll"

                Column {
                    id: layout
                    width: scrollView.availableWidth
                    spacing: Style.current.bigPadding
                    anchors.left: parent.left

                    StatusInput {
                        id: recipientSelector
                        property bool isPending: false

                        height: visible ? implicitHeight: 0
                        visible: !isBridgeTx && !!assetSelector.selectedAsset

                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding

                        label: qsTr("To")
                        placeholderText: qsTr("Enter an ENS name or address")
                        text: popup.addressText
                        input.background.color: Theme.palette.indirectColor1
                        input.background.border.width: 0
                        input.implicitHeight: 56
                        input.clearable: popup.interactive
                        input.edit.readOnly: !popup.interactive
                        multiline: false
                        input.edit.textFormat: TextEdit.RichText
                        input.rightComponent: RowLayout {
                            StatusIcon {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                icon: "tiny/checkmark"
                                color: Theme.palette.primaryColor1
                                visible: d.recipientReady
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
                                onClicked: {
                                    popup.isLoading = true
                                    recipientSelector.input.edit.clear()
                                    d.waitTimer.restart()
                                }
                            }
                        }
                        Keys.onReleased: {
                            popup.isLoading = true
                            d.waitTimer.restart()
                            if(!d.isAddressValid) {
                                isPending = true
                                Qt.callLater(d.resolveENS, store.plainText(input.edit.text))
                            }
                        }
                    }

                    Connections {
                        target: store.mainModuleInst
                        function onResolvedENS(resolvedPubKey: string, resolvedAddress: string, uuid: string) {
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
                            popup.isLoading = true
                            d.waitTimer.restart()
                        }
                        visible: !d.recipientReady && !isBridgeTx && !!assetSelector.selectedAsset
                    }

                    NetworkSelector {
                        id: networkSelector
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        interactive: popup.interactive
                        selectedAccount: popup.selectedAccount
                        ensAddressOrEmpty: d.isENSValid ? d.resolvedENSAddress : ""
                        amountToSend: amountToSendInput.cryptoValueToSend
                        minSendCryptoDecimals: amountToSendInput.minSendCryptoDecimals
                        minReceiveCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                        requiredGasInEth: d.totalFeesInEth
                        selectedAsset: assetSelector.selectedAsset
                        onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                        visible: d.recipientReady && !!assetSelector.selectedAsset && !!amountToSendInput.input.text
                        errorType: d.errorType
                        isLoading: popup.isLoading
                        bestRoutes: popup.bestRoutes
                        isBridgeTx: popup.isBridgeTx
                    }

                    FeesView {
                        id: fees
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        visible: d.recipientReady && !!assetSelector.selectedAsset && networkSelector.advancedOrCustomMode && !!amountToSendInput.input.text
                        selectedTokenSymbol: d.selectedSymbol
                        isLoading: popup.isLoading
                        bestRoutes: popup.bestRoutes
                        store: popup.store
                        gasFiatAmount: d.totalFeesInFiat
                        errorType: d.errorType
                    }
                }
            }
        }
    }

    footer: SendModalFooter {
        nextButtonText: popup.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
        maxFiatFees: popup.isLoading ? "..." : popup.currencyStore.formatCurrencyAmount(d.totalFeesInFiat, popup.store.currentCurrency)
        totalTimeEstimate: popup.isLoading? "..." : d.totalTimeEstimate
        pending: d.isPendingTx || popup.isLoading
        visible: d.recipientReady && amountToSendInput.cryptoValueToSend >= 0 && !d.errorMode && !!amountToSendInput.input.text && amountToSendInput.input.valid
        onNextButtonClicked: popup.sendTransaction()
    }

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup {}
    }

    Connections {
        target: popup.store.walletSectionTransactionsInst
        function onSuggestedRoutesReady(suggestedRoutes: string) {
            let response = JSON.parse(suggestedRoutes)
            if(!!response.error) {
                popup.isLoading = false
                return
            }
            popup.bestRoutes =  response.suggestedRoutes.best
            let gasTimeEstimate = response.suggestedRoutes.gasTimeEstimate
            d.totalTimeEstimate = popup.store.getLabelForEstimatedTxTime(gasTimeEstimate.totalTime)
            d.totalFeesInEth = gasTimeEstimate.totalFeesInEth
            d.totalFeesInFiat = popup.currencyStore.getFiatValue( gasTimeEstimate.totalFeesInEth, "ETH", popup.store.currentCurrency) +
                popup.currencyStore.getFiatValue(gasTimeEstimate.totalTokenFees, fees.selectedTokenSymbol, popup.store.currentCurrency)
            d.totalAmountToReceive = popup.store.getWei2Eth(response.suggestedRoutes.amountToReceive, assetSelector.selectedAsset.decimals)
            networkSelector.toNetworksList = response.suggestedRoutes.toNetworks
            popup.isLoading = false
        }
    }

    Connections {
        target: popup.store.walletSectionTransactionsInst
        function onTransactionSent(txResult: string) {
            d.isPendingTx = false
            try {
                let response = JSON.parse(txResult)
                if (response.uuid !== d.uuid) return

                if (!response.success) {
                    if (response.error.includes(Constants.walletSection.cancelledMessage)) {
                        return
                    }
                    sendingError.text = response.error
                    return sendingError.open()
                }
                for(var i=0; i<popup.bestRoutes.length; i++) {
                    let txHash = response.result[popup.bestRoutes[i].fromNetwork.chainId]
                    let url =  "%1/%2".arg(popup.store.getEtherscanLink(popup.bestRoutes[i].fromNetwork.chainId)).arg(txHash)
                    Global.displayToastMessage(qsTr("Transaction pending..."),
                                               qsTr("View on etherscan"),
                                               "",
                                               true,
                                               Constants.ephemeralNotificationType.normal,
                                               url)
                }

                popup.close()
            } catch (e) {
                console.error('Error parsing the response', e)
            }
        }
    }
}

