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

    property string preSelectedRecipient
    property string preDefinedAmountToSend
    property var preSelectedHolding
    property string preSelectedHoldingID
    property var preSelectedHoldingType
    property bool interactive: true
    property alias onlyAssets: holdingSelector.onlyAssets

    property alias modalHeader: modalHeader.text

    property var store: TransactionStore{}
    property var currencyStore: store.currencyStore
    property var selectedAccount: store.selectedSenderAccount
    property var collectiblesModel: store.collectiblesModel
    property var nestedCollectiblesModel: store.nestedCollectiblesModel
    property var bestRoutes
    property alias addressText: recipientLoader.addressText
    property bool isLoading: false
    property int sendType: Constants.SendType.Transfer

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
                    d.uuid,
                    sendType)
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.selectedAccount && !!d.selectedHolding && recipientLoader.ready && amountToSendInput.inputNumberValid) {
            popup.isLoading = true
            let amount = d.isERC721Transfer ? 1: Math.round(amountToSendInput.cryptoValueToSend * Math.pow(10, d.selectedHolding.decimals))
            popup.store.suggestedRoutes(amount.toString(16), popup.sendType)
        }
    })

    QtObject {
        id: d
        readonly property int errorType: !amountToSendInput.input.valid && !isERC721Transfer ? Constants.SendAmountExceedsBalance :
                                                                          (popup.bestRoutes && popup.bestRoutes.count === 0 &&
                                                                           !!amountToSendInput.input.text && recipientLoader.ready && !popup.isLoading) ?
                                                                              Constants.NoRoute : Constants.NoError
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset ? selectedHolding.totalCurrencyBalance.amount : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset ? selectedHolding.totalBalance.amount : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string selectedSymbol: store.selectedAssetSymbol
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? popup.currencyStore.currentCurrency : selectedSymbol
        readonly property bool errorMode: popup.isLoading || !recipientLoader.ready ? false : errorType !== Constants.NoError || networkSelector.errorMode || !amountToSendInput.inputNumberValid
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInFiat
        property double totalAmountToReceive
        readonly property bool isBridgeTx: popup.sendType === Constants.SendType.Bridge
        readonly property bool isERC721Transfer: popup.sendType === Constants.SendType.ERC721Transfer
        property var selectedHolding: null
        property var selectedHoldingType: Constants.HoldingType.Unknown
        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding && selectedHoldingType === Constants.HoldingType.Asset
        property var hoveredHolding: null
        property var hoveredHoldingType: Constants.HoldingType.Unknown
        readonly property bool isHoveredHoldingValidAsset: !!hoveredHolding && hoveredHoldingType === Constants.HoldingType.Asset

        function setSelectedHoldingId(holdingId, holdingType) {
            let holding = store.getHolding(holdingId, holdingType)
            setSelectedHolding(holding, holdingType)
        }

        function setSelectedHolding(holding, holdingType) {
            d.selectedHoldingType = holdingType
            d.selectedHolding = holding
            let selectorHolding = store.holdingToSelectorHolding(holding, holdingType)
            holdingSelector.setSelectedItem(selectorHolding, holdingType)
        }

        function setHoveredHoldingId(holdingId, holdingType) {
            let holding = store.getHolding(holdingId, holdingType)
            setHoveredHolding(holding, holdingType)
        }

        function setHoveredHolding(holding, holdingType) {
            d.hoveredHoldingType = holdingType
            d.hoveredHolding = holding
            let selectorHolding = store.holdingToSelectorHolding(holding, holdingType)
            holdingSelector.setHoveredItem(selectorHolding, holdingType)
        }

        onSelectedHoldingChanged: {
            if (d.selectedHoldingType === Constants.HoldingType.Asset) {
                popup.sendType = Constants.SendType.Transfer
                store.setSelectedAssetSymbol(selectedHolding.symbol)
            } else if (d.selectedHoldingType === Constants.HoldingType.Collectible) {
                popup.sendType = Constants.SendType.ERC721Transfer
                amountToSendInput.input.text = 1
                store.setSelectedAssetSymbol(selectedHolding.contractAddress+":"+selectedHolding.tokenId)
                store.setRouteEnabledFromChains(selectedHolding.chainId)
                store.updateRoutePreferredChains(selectedHolding.chainId)
            }
            recalculateRoutesAndFees()
        }
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

        if (popup.preSelectedHoldingType !== Constants.HoldingType.Unknown) {
            if(!!popup.preSelectedHolding) {
                d.setSelectedHolding(popup.preSelectedHolding, popup.preSelectedHoldingType)
            } else if (!!popup.preSelectedHoldingID) {
                d.setSelectedHoldingId(popup.preSelectedHoldingID, popup.preSelectedHoldingType)
            }
        }

        if(!!popup.preDefinedAmountToSend) {
            amountToSendInput.input.text = popup.preDefinedAmountToSend
        }

        if(!!popup.preSelectedRecipient) {
            recipientLoader.selectedRecipientType = TabAddressSelectorView.Type.Address
            recipientLoader.selectedRecipient = {address: popup.preSelectedRecipient}
        }

        if(d.isBridgeTx) {
            recipientLoader.selectedRecipientType = TabAddressSelectorView.Type.Address
            recipientLoader.selectedRecipient = {address: popup.selectedAccount.address}
        }
    }

    onClosed: popup.store.resetStoredProperties()

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
                            verticalAlignment: Text.AlignVCenter
                            text: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
                            font.pixelSize: 28
                            lineHeight: 38
                            lineHeightMode: Text.FixedHeight
                            font.letterSpacing: -0.4
                            color: Theme.palette.directColor1
                            Layout.maximumWidth: contentWidth
                        }
                        HoldingSelector {
                            id: holdingSelector
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            assetsModel: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : null
                            collectiblesModel: popup.selectedAccount ? popup.nestedCollectiblesModel : null
                            currentCurrencySymbol: RootStore.currencyStore.currentCurrencySymbol
                            visible: (!!d.selectedHolding && d.selectedHoldingType !== Constants.HoldingType.Unknown) ||
                                     (!!d.hoveredHolding && d.hoveredHoldingType !== Constants.HoldingType.Unknown)
                            getNetworkIcon: function(chainId){
                                return RootStore.getNetworkIcon(chainId)
                            }
                            onItemSelected: {
                                d.setSelectedHoldingId(holdingId, holdingType)
                            }
                        }

                        StatusListItemTag {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.preferredHeight: 22
                            visible: d.isSelectedHoldingValidAsset || d.isHoveredHoldingValidAsset && !d.isERC721Transfer
                            title: {
                                if(d.isHoveredHoldingValidAsset && !!d.hoveredHolding.symbol) {
                                    const balance = popup.currencyStore.formatCurrencyAmount((amountToSendInput.inputIsFiat ? d.hoveredHolding.totalCurrencyBalance.amount : d.hoveredHolding.totalBalance.amount) , d.hoveredHolding.symbol)
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

                        visible: !d.selectedHolding
                        assets: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : null
                        searchTokenSymbolByAddressFn: function (address) {
                            return store.findTokenSymbolByAddress(address)
                        }
                        getNetworkIcon: function(chainId){
                            return RootStore.getNetworkIcon(chainId)
                        }
                        onTokenSelected: {
                            d.setSelectedHoldingId(symbol, Constants.HoldingType.Asset)
                        }
                        onTokenHovered: {
                            if(hovered) {
                                d.setHoveredHoldingId(symbol, Constants.HoldingType.Asset)
                            } else {
                                d.setHoveredHoldingId("", Constants.HoldingType.Unknown)
                            }
                        }
                    }
                    RowLayout {
                        visible: d.isSelectedHoldingValidAsset && !d.isERC721Transfer
                        AmountToSend {
                            id: amountToSendInput
                            Layout.fillWidth:true
                            isBridgeTx: d.isBridgeTx
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
                            visible: !!popup.bestRoutes && popup.bestRoutes !== undefined &&
                                     popup.bestRoutes.count > 0 && amountToSendInput.inputNumberValid
                            isLoading: popup.isLoading
                            selectedSymbol: d.selectedSymbol
                            isBridgeTx: d.isBridgeTx
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
                        visible: !d.isBridgeTx && !!d.selectedHolding
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
                            isERC721Transfer: d.isERC721Transfer
                            isBridgeTx: d.isBridgeTx
                            interactive: popup.interactive
                            selectedAsset: d.selectedHolding
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
                        visible: !recipientLoader.ready && !d.isBridgeTx && !!d.selectedHolding
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
                        selectedAsset: d.selectedHolding
                        onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                        visible: recipientLoader.ready && !!d.selectedHolding && amountToSendInput.inputNumberValid
                        errorType: d.errorType
                        isLoading: popup.isLoading
                        isBridgeTx: d.isBridgeTx
                        isERC721Transfer: d.isERC721Transfer
                    }

                    FeesView {
                        id: fees
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        visible: recipientLoader.ready && !!d.selectedHolding && networkSelector.advancedOrCustomMode && amountToSendInput.inputNumberValid
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
        nextButtonText: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
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
            d.totalAmountToReceive = popup.store.getWei2Eth(txRoutes.amountToReceive, d.selectedHolding.decimals)
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

