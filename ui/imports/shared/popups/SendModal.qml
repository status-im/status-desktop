import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

import utils 1.0
import shared.stores 1.0
import shared.panels 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

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
    property var currencyStore: store.currencyStore
    property var selectedAccount: store.selectedSenderAccount
    property var bestRoutes
    property alias addressText: recipientLoader.addressText
    property bool isLoading: false
    property int sendType: isBridgeTx ? Constants.SendType.Bridge : Constants.SendType.Transfer
    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    property var sendTransaction: function() {
        let recipientAddress = Utils.isValidAddress(popup.addressText) ? popup.addressText : recipientLoader.resolvedENSAddress
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(
                    popup.selectedAccount.address,
                    recipientAddress,
                    d.selectedSymbol,
                    amountToSendInput.cryptoValueToSend,
                    d.uuid)
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.selectedAccount && !!assetSelector.selectedAsset && recipientLoader.ready && amountToSendInput.inputNumberValid) {
            popup.isLoading = true
            let amount = Math.round(amountToSendInput.cryptoValueToSend * Math.pow(10, assetSelector.selectedAsset.decimals))
            popup.store.suggestedRoutes(amount.toString(16), popup.sendType)
        }
    })

    QtObject {
        id: d
        readonly property int errorType: !amountToSendInput.input.valid ? Constants.SendAmountExceedsBalance :
                                                                          (popup.bestRoutes && popup.bestRoutes.count === 0 &&
                                                                           !!amountToSendInput.input.text && recipientLoader.ready && !popup.isLoading) ?
                                                                              Constants.NoRoute : Constants.NoError
        readonly property double maxFiatBalance: !!assetSelector.selectedAsset ? assetSelector.selectedAsset.totalCurrencyBalance.amount : 0
        readonly property double maxCryptoBalance: !!assetSelector.selectedAsset ? assetSelector.selectedAsset.totalBalance.amount : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string selectedSymbol: store.selectedAssetSymbol
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? popup.currencyStore.currentCurrency : selectedSymbol
        readonly property bool errorMode: popup.isLoading || !recipientLoader.ready ? false : errorType !== Constants.NoError || networkSelector.errorMode || !amountToSendInput.inputNumberValid
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInFiat
        property double totalAmountToReceive
    }

    width: 556
    topMargin: 64 + header.height
    bottomPadding: footer.visible ? footer.height : 32

    padding: 0
    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    onSelectedAccountChanged: popup.recalculateRoutesAndFees()

    onOpened: {
        amountToSendInput.input.input.edit.forceActiveFocus()

        if(!!popup.preSelectedAsset) {
            assetSelector.selectedAsset = popup.preSelectedAsset
        }

        if(!!popup.preDefinedAmountToSend) {
            amountToSendInput.input.text = popup.preDefinedAmountToSend
        }

        if(!!popup.preSelectedRecipient) {
            recipientLoader.selectedRecipientType = TabAddressSelectorView.Type.Address
            recipientLoader.selectedRecipient = {address: popup.preSelectedRecipient}
        }

        if(popup.isBridgeTx) {
            recipientLoader.selectedRecipientType = TabAddressSelectorView.Type.Address
            recipientLoader.selectedRecipient = {address: popup.selectedAccount.address}
        }
    }

    onClosed: popup.store.resetTxStoreProperties()

    header: AccountsModalHeader {
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        model: SortFilterProxyModel {
            sourceModel: popup.store.senderAccounts

            sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        }
        selectedAccount: !!popup.selectedAccount ? popup.selectedAccount: {}
        getNetworkShortNames: function(chainIds) {return store.getNetworkShortNames(chainIds)}
        onSelectedIndexChanged: store.switchSenderAccount(selectedIndex)
    }


    ColumnLayout {
        id: group1

        anchors.fill: parent

        ClippingWrapper {
            Layout.fillWidth: true
            Layout.preferredHeight: assetAndAmountSelector.implicitHeight
                                    + Style.current.halfPadding
            z: 100

            clipBottomMargin: 20

            Rectangle {
                anchors.fill: parent

                color: Theme.palette.baseColor3

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
                        Layout.preferredHeight: 44
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
                            assets: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : null
                            defaultToken: Style.png("tokens/DEFAULT-TOKEN@3x")
                            placeholderText: qsTr("Select token")
                            currentCurrencySymbol: RootStore.currencyStore.currentCurrencySymbol
                            tokenAssetSourceFn: function (symbol) {
                                return symbol ? Style.png("tokens/%1".arg(symbol)) : defaultToken
                            }
                            searchTokenSymbolByAddressFn: function (address) {
                                    return store.findTokenSymbolByAddress(address)
                            }
                            getNetworkIcon: function(chainId){
                                return RootStore.getNetworkIcon(chainId)
                            }
                            onAssetsChanged: {
                                // Todo we should not need to do this, this should be automatic when selected account changes
                                if(!!selectedAccount && !!assetSelector.selectedAsset)
                                    assetSelector.selectedAsset = store.getAsset(selectedAccount.assets, assetSelector.selectedAsset.symbol)
                            }
                            onSelectedAssetChanged: {
                                store.setSelectedAssetSymbol(assetSelector.selectedAsset.symbol)
                                if (!assetSelector.selectedAsset || !amountToSendInput.inputNumberValid) {
                                    return
                                }
                                popup.recalculateRoutesAndFees()
                            }
                            visible: !!assetSelector.selectedAsset || !!assetSelector.hoveredToken
                        }
                        StatusListItemTag {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.preferredHeight: 22
                            visible: !!assetSelector.selectedAsset || !!assetSelector.hoveredToken
                            title: {
                                if(!!assetSelector.hoveredToken) {
                                    const balance = popup.currencyStore.formatCurrencyAmount((amountToSendInput.inputIsFiat ? assetSelector.hoveredToken.totalCurrencyBalance.amount : assetSelector.hoveredToken.totalBalance.amount) , assetSelector.hoveredToken.symbol)
                                    return qsTr("Max: %1").arg(balance)
                                }
                                if (d.maxInputBalance <= 0)
                                    return qsTr("No balances active")
                                const balance = popup.currencyStore.formatCurrencyAmount(d.maxInputBalance, d.inputSymbol)
                                return qsTr("Max: %1").arg(balance)
                            }
                            tagClickable: true
                            closeButtonVisible: false
                            titleText.font.pixelSize: 12
                            bgColor: amountToSendInput.input.valid || !amountToSendInput.input.text ? Theme.palette.primaryColor3 : Theme.palette.dangerColor2
                            titleText.color: amountToSendInput.input.valid || !amountToSendInput.input.text ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
                            onTagClicked: {
                                amountToSendInput.input.text = popup.currencyStore.formatCurrencyAmount(d.maxInputBalance, d.inputSymbol, {noSymbol: true, rawAmount: true}, LocaleUtils.userInputLocale)
                            }
                        }
                    }
                    TokenListView {
                        id: tokenListRect

                        Layout.fillWidth: true

                        visible: !assetSelector.selectedAsset
                        assets: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : null
                        searchTokenSymbolByAddressFn: function (address) {
                            return store.findTokenSymbolByAddress(address)
                        }
                        getNetworkIcon: function(chainId){
                            return RootStore.getNetworkIcon(chainId)
                        }
                        onTokenSelected: {
                            assetSelector.selectedAsset = selectedToken
                        }
                        onTokenHovered: {
                            if(hovered)
                                assetSelector.hoveredToken = selectedToken
                            else
                                assetSelector.hoveredToken = null
                        }
                    }
                    RowLayout {
                        visible: !!assetSelector.selectedAsset
                        AmountToSend {
                            id: amountToSendInput
                            Layout.fillWidth:true
                            isBridgeTx: popup.isBridgeTx
                            interactive: popup.interactive
                            selectedSymbol: d.selectedSymbol
                            maxInputBalance: d.maxInputBalance
                            currentCurrency: popup.currencyStore.currentCurrency
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
                            visible: !!popup.bestRoutes && popup.bestRoutes !== undefined && popup.bestRoutes.count > 0 && amountToSendInput.inputNumberValid
                            isLoading: popup.isLoading
                            selectedSymbol: d.selectedSymbol
                            isBridgeTx: popup.isBridgeTx
                            cryptoValueToReceive: d.totalAmountToReceive
                            inputIsFiat: amountToSendInput.inputIsFiat
                            minCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                            minFiatDecimals: amountToSendInput.minReceiveFiatDecimals
                            currentCurrency: popup.currencyStore.currentCurrency
                            getFiatValue: function(cryptoValue) {
                                return popup.currencyStore.getFiatValue(cryptoValue, selectedSymbol, currentCurrency)
                            }
                            formatCurrencyAmount: popup.currencyStore.formatCurrencyAmount
                        }
                    }
                }
            }
        }

        ClippingWrapper {
            Layout.fillWidth: true
            Layout.fillHeight: true

            implicitWidth: scrollView.implicitWidth
            implicitHeight: scrollView.implicitHeight

            clipTopMargin: 40
            clipBottomMargin: popup.bottomPadding

            StatusScrollView {
                id: scrollView

                topPadding: 12
                anchors.fill: parent
                contentWidth: availableWidth

                clip: false
                objectName: "sendModalScroll"

                Column {
                    id: layout
                    width: scrollView.availableWidth
                    spacing: Style.current.bigPadding
                    anchors.left: parent.left

                    ColumnLayout {
                        spacing: 8
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        visible: !isBridgeTx && !!assetSelector.selectedAsset
                        StatusBaseText {
                            id: label
                            elide: Text.ElideRight
                            text: qsTr("To")
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                        }
                        RecipientView {
                            id: recipientLoader
                            Layout.fillWidth: true
                            store: popup.store
                            isBridgeTx: popup.isBridgeTx
                            interactive: popup.interactive
                            selectedAsset: assetSelector.selectedAsset
                            onIsLoading: popup.isLoading = true
                            onRecalculateRoutesAndFees: popup.recalculateRoutesAndFees()
                        }
                    }

                    TabAddressSelectorView {
                        id: addressSelector
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        selectedAccount: popup.selectedAccount
                        onRecipientSelected:  {
                            recipientLoader.selectedRecipientType = type
                            recipientLoader.selectedRecipient = recipient
                        }
                        visible: !recipientLoader.ready && !isBridgeTx && !!assetSelector.selectedAsset
                    }

                    NetworkSelector {
                        id: networkSelector
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        interactive: popup.interactive
                        selectedAccount: popup.selectedAccount
                        ensAddressOrEmpty: recipientLoader.isENSValid ? recipientLoader.resolvedENSAddress : ""
                        amountToSend: amountToSendInput.cryptoValueToSend
                        minSendCryptoDecimals: amountToSendInput.minSendCryptoDecimals
                        minReceiveCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                        selectedAsset: assetSelector.selectedAsset
                        onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                        visible: recipientLoader.ready && !!assetSelector.selectedAsset && amountToSendInput.inputNumberValid
                        errorType: d.errorType
                        isLoading: popup.isLoading
                        isBridgeTx: popup.isBridgeTx
                    }

                    FeesView {
                        id: fees
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        visible: recipientLoader.ready && !!assetSelector.selectedAsset && networkSelector.advancedOrCustomMode && amountToSendInput.inputNumberValid
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
        maxFiatFees: popup.isLoading ? "..." : popup.currencyStore.formatCurrencyAmount(d.totalFeesInFiat, popup.currencyStore.currentCurrency)
        totalTimeEstimate: popup.isLoading? "..." : d.totalTimeEstimate
        pending: d.isPendingTx || popup.isLoading
        visible: recipientLoader.ready && amountToSendInput.inputNumberValid && !d.errorMode
        onNextButtonClicked: popup.sendTransaction()
    }

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup {}
    }

    Connections {
        target: popup.store.walletSectionSendInst
        function onSuggestedRoutesReady(txRoutes) {
            popup.bestRoutes =  txRoutes.suggestedRoutes
            let gasTimeEstimate = txRoutes.gasTimeEstimate
            d.totalTimeEstimate = popup.store.getLabelForEstimatedTxTime(gasTimeEstimate.totalTime)
            d.totalFeesInFiat = popup.currencyStore.getFiatValue( gasTimeEstimate.totalFeesInEth, "ETH", popup.currencyStore.currentCurrency) +
                popup.currencyStore.getFiatValue(gasTimeEstimate.totalTokenFees, fees.selectedTokenSymbol, popup.currencyStore.currentCurrency)
            d.totalAmountToReceive = popup.store.getWei2Eth(txRoutes.amountToReceive, assetSelector.selectedAsset.decimals)
            networkSelector.toNetworksList = txRoutes.toNetworksModel
            popup.isLoading = false
        }
    }

    Connections {
        target: popup.store.walletSectionSendInst
        function onTransactionSent(chainId: int, txHash: string, uuid: string, error: string) {
            d.isPendingTx = false
            if (uuid !== d.uuid) return
            if (!!error) {
                if (error.includes(Constants.walletSection.cancelledMessage)) {
                    return
                }
                sendingError.text = error
                return sendingError.open()
            }
            let url =  "%1/%2".arg(popup.store.getEtherscanLink(chainId)).arg(txHash)
            Global.displayToastMessage(qsTr("Transaction pending..."),
                                       qsTr("View on etherscan"),
                                       "",
                                       true,
                                       Constants.ephemeralNotificationType.normal,
                                       url)
            popup.close()
        }
    }
}

