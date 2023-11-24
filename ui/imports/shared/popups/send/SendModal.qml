import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

import utils 1.0
import shared.stores.send 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

import "./panels"
import "./controls"
import "./views"

StatusDialog {
    id: popup

    property var preSelectedAccount: store.selectedSenderAccount
    // expected content depends on the preSelectedRecipientType value.
    // If type Address this must be a string else it expects an object. See RecipientView.selectedRecipientType
    property var preSelectedRecipient
    property int preSelectedRecipientType: TabAddressSelectorView.Type.Address
    property string preDefinedAmountToSend
    // token symbol
    property string preSelectedHoldingID
    property int preSelectedHoldingType: Constants.TokenType.Unknown
    property int preSelectedSendType
    property bool interactive: true
    property alias onlyAssets: holdingSelector.onlyAssets

    property alias modalHeader: modalHeader.text

    property TransactionStore store: TransactionStore {}
    property var nestedCollectiblesModel: store.nestedCollectiblesModel
    property var bestRoutes
    property bool isLoading: false

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    property var sendTransaction: function() {
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(amountToSendInput.cryptoValueToSend, d.uuid)
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.preSelectedAccount && !!holdingSelector.selectedItem
                && recipientLoader.ready && amountToSendInput.inputNumberValid) {
            popup.isLoading = true
            popup.store.suggestedRoutes(d.isERC721Transfer ? "1" : amountToSendInput.cryptoValueToSend)
        }
    })

    QtObject {
        id: d

        property bool ensOrStickersPurpose: popup.preSelectedSendType === Constants.SendType.ENSRegister ||
                                            popup.preSelectedSendType === Constants.SendType.ENSRelease ||
                                            popup.preSelectedSendType === Constants.SendType.ENSSetPubKey ||
                                            popup.preSelectedSendType === Constants.SendType.StickersBuy

        readonly property var currencyStore: store.currencyStore
        readonly property int errorType: !amountToSendInput.input.valid && !isERC721Transfer ? Constants.SendAmountExceedsBalance :
                                                                          (popup.bestRoutes && popup.bestRoutes.count === 0 &&
                                                                           !!amountToSendInput.input.text && recipientLoader.ready && !popup.isLoading) ?
                                                                              Constants.NoRoute : Constants.NoError
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset ? selectedHolding.totalCurrencyBalance.amount : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset ? selectedHolding.totalBalance.amount : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? currencyStore.currentCurrency : store.selectedAssetSymbol
        readonly property bool errorMode: popup.isLoading || !recipientLoader.ready ? false : errorType !== Constants.NoError || networkSelector.errorMode || !amountToSendInput.inputNumberValid
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInFiat
        property double totalAmountToReceive
        readonly property bool isBridgeTx: store.sendType === Constants.SendType.Bridge
        readonly property bool isERC721Transfer: store.sendType === Constants.SendType.ERC721Transfer
        property var selectedHolding: null
        property var selectedHoldingType: Constants.TokenType.Unknown
        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding && selectedHoldingType === Constants.TokenType.ERC20
        property var hoveredHolding: null
        property var hoveredHoldingType: Constants.TokenType.Unknown
        readonly property bool isHoveredHoldingValidAsset: !!hoveredHolding && hoveredHoldingType === Constants.TokenType.ERC20

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
            if (d.selectedHoldingType === Constants.TokenType.ERC20) {
                if(!d.ensOrStickersPurpose && store.sendType !== Constants.SendType.Bridge)
                    store.setSendType(Constants.SendType.Transfer)
                store.setSelectedAssetSymbol(selectedHolding.symbol)
                store.setSelectedTokenIsOwnerToken(false)
            } else if (d.selectedHoldingType === Constants.TokenType.ERC721) {
                store.setSendType(Constants.SendType.ERC721Transfer)
                amountToSendInput.input.text = 1
                store.setSelectedAssetSymbol(selectedHolding.contractAddress+":"+selectedHolding.tokenId)
                store.setRouteEnabledFromChains(selectedHolding.chainId)
                store.updateRoutePreferredChains(selectedHolding.chainId)
                store.setSelectedTokenIsOwnerToken(selectedHolding.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner)
            }
            store.setSelectedTokenName(selectedHolding.name)

            recalculateRoutesAndFees()
        }

        function prepareForMaxSend(value, symbol) {
            if(symbol !== "ETH") {
                return value
            }
            
            return value - Math.max(0.0001, Math.min(0.01, value * 0.1))
        }
    }

    width: 556

    padding: 0
    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    onOpened: {
        amountToSendInput.input.input.edit.forceActiveFocus()

        if(popup.preSelectedSendType !== Constants.SendType.Unknown) {
            store.setSendType(popup.preSelectedSendType)
        }
        if ((popup.preSelectedHoldingType > Constants.TokenType.Native) &&
                (popup.preSelectedHoldingType < Constants.TokenType.ERC1155)) {
            tokenListRect.browsingHoldingType = popup.preSelectedHoldingType
            if (!!popup.preSelectedHoldingID) {
                d.setSelectedHoldingId(popup.preSelectedHoldingID, popup.preSelectedHoldingType)
            }
        }

        if(!!popup.preDefinedAmountToSend) {
            amountToSendInput.input.text = popup.preDefinedAmountToSend
        }

        if(!!popup.preSelectedRecipient) {
            recipientLoader.selectedRecipientType = popup.preSelectedRecipientType
            if (popup.preSelectedRecipientType == TabAddressSelectorView.Type.Address) {
                recipientLoader.selectedRecipient = {address: popup.preSelectedRecipient}
            } else {
                recipientLoader.selectedRecipient = popup.preSelectedRecipient
            }
        }

        if(d.isBridgeTx) {
            recipientLoader.selectedRecipientType = TabAddressSelectorView.Type.Address
            recipientLoader.selectedRecipient = {address: popup.preSelectedAccount.address}
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
        selectedAccount: !!popup.preSelectedAccount ? popup.preSelectedAccount: {}
        getNetworkShortNames: function(chainIds) {return store.getNetworkShortNames(chainIds)}
        onSelectedIndexChanged: {
            store.switchSenderAccount(selectedIndex)
            d.setSelectedHoldingId(d.selectedHolding.symbol, d.selectedHoldingType)
            popup.recalculateRoutesAndFees()
        }
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
                            assetsModel: popup.preSelectedAccount && popup.preSelectedAccount.assets ? popup.preSelectedAccount.assets : null
                            collectiblesModel: popup.preSelectedAccount ? popup.nestedCollectiblesModel : null
                            networksModel: popup.store.allNetworksModel
                            currentCurrencySymbol: d.currencyStore.currentCurrencySymbol
                            visible: (!!d.selectedHolding && d.selectedHoldingType !== Constants.TokenType.Unknown) ||
                                     (!!d.hoveredHolding && d.hoveredHoldingType !== Constants.TokenType.Unknown)
                            onItemSelected: {
                                d.setSelectedHoldingId(holdingId, holdingType)
                            }
                        }

                        StatusListItemTag {
                            Layout.maximumWidth: 300
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.preferredHeight: 22
                            visible: d.isSelectedHoldingValidAsset || d.isHoveredHoldingValidAsset && !d.isERC721Transfer
                            title: {
                                if(d.isHoveredHoldingValidAsset && !!d.hoveredHolding.symbol) {
                                    const input = amountToSendInput.inputIsFiat ? d.hoveredHolding.totalCurrencyBalance.amount : d.hoveredHolding.totalBalance.amount
                                    const max = d.prepareForMaxSend(input, d.hoveredHolding.symbol)
                                    if (max <= 0)
                                        return qsTr("No balances active")

                                    const balance = d.currencyStore.formatCurrencyAmount(max , d.hoveredHolding.symbol)
                                    return qsTr("Max: %1").arg(balance)
                                }
                                const max = d.prepareForMaxSend(d.maxInputBalance, d.inputSymbol)
                                if (max <= 0)
                                    return qsTr("No balances active")

                                const balance = d.currencyStore.formatCurrencyAmount(max, d.inputSymbol)
                                return qsTr("Max: %1").arg(balance)
                            }
                            tagClickable: true
                            closeButtonVisible: false
                            titleText.font.pixelSize: 12
                            bgColor: amountToSendInput.input.valid || !amountToSendInput.input.text ? Theme.palette.primaryColor3 : Theme.palette.dangerColor2
                            titleText.color: amountToSendInput.input.valid || !amountToSendInput.input.text ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
                            onTagClicked: {
                                const max = d.prepareForMaxSend(d.maxInputBalance, d.inputSymbol)
                                amountToSendInput.input.text = d.currencyStore.formatCurrencyAmount(max, d.inputSymbol, {noSymbol: true, rawAmount: true}, LocaleUtils.userInputLocale)
                            }
                        }
                    }
                    RowLayout {
                        visible: d.isSelectedHoldingValidAsset && !d.isERC721Transfer
                        AmountToSend {
                            id: amountToSendInput

                            Layout.fillWidth: true
                            isBridgeTx: d.isBridgeTx
                            interactive: popup.interactive
                            selectedSymbol: store.selectedAssetSymbol
                            maxInputBalance: d.maxInputBalance
                            currentCurrency: d.currencyStore.currentCurrency

                            multiplierIndex: holdingSelector.selectedItem
                                             ? holdingSelector.selectedItem.decimals
                                             : 0

                            getFiatValue: function(cryptoValue) {
                                return selectedSymbol ? d.currencyStore.getFiatValue(cryptoValue, selectedSymbol, currentCurrency) : 0.0
                            }

                            getCryptoValue: function(fiatValue) {
                                return selectedSymbol ? d.currencyStore.getCryptoValue(fiatValue, selectedSymbol, currentCurrency) : 0.0
                            }

                            formatCurrencyAmount: d.currencyStore.formatCurrencyAmount
                            onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                            input.input.tabNavItem: recipientLoader.item
                            Keys.onTabPressed: event.accepted = true
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
                            selectedSymbol: store.selectedAssetSymbol
                            isBridgeTx: d.isBridgeTx
                            cryptoValueToReceive: d.totalAmountToReceive
                            inputIsFiat: amountToSendInput.inputIsFiat
                            minCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                            minFiatDecimals: amountToSendInput.minReceiveFiatDecimals
                            currentCurrency: d.currencyStore.currentCurrency
                            getFiatValue: function(cryptoValue) {
                                return d.currencyStore.getFiatValue(cryptoValue, selectedSymbol, currentCurrency)
                            }
                            formatCurrencyAmount: d.currencyStore.formatCurrencyAmount
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

                    TokenListView {
                        id: tokenListRect

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding

                        visible: !d.selectedHolding
                        assets: popup.preSelectedAccount && popup.preSelectedAccount.assets ? popup.preSelectedAccount.assets : null
                        collectibles: popup.preSelectedAccount ? popup.nestedCollectiblesModel : null
                        networksModel: popup.store.allNetworksModel
                        onlyAssets: holdingSelector.onlyAssets
                        // TODO remove this as address should be found directly in model itself
                        searchTokenSymbolByAddressFn: function (address) {
                            return store.findTokenSymbolByAddress(address)
                        }
                        onTokenSelected: {
                            d.setSelectedHoldingId(symbol, holdingType)
                        }
                        onTokenHovered: {
                            if(hovered) {
                                d.setHoveredHoldingId(symbol, holdingType)
                            } else {
                                d.setHoveredHoldingId("", Constants.TokenType.Unknown)
                            }
                        }
                    }

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
                            onAddressTextChanged: store.setSelectedRecipient(addressText)
                        }
                    }

                    TabAddressSelectorView {
                        id: addressSelector
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        selectedAccount: popup.preSelectedAccount
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
                        selectedAccount: popup.preSelectedAccount
                        ensAddressOrEmpty: recipientLoader.resolvedENSAddress
                        amountToSend: amountToSendInput.cryptoValueToSendFloat
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
                        selectedTokenSymbol: store.selectedAssetSymbol
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
        width: parent.width
        nextButtonText: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
        maxFiatFees: popup.isLoading ? "..." : d.currencyStore.formatCurrencyAmount(d.totalFeesInFiat, d.currencyStore.currentCurrency)
        totalTimeEstimate: popup.isLoading? "..." : d.totalTimeEstimate
        pending: d.isPendingTx || popup.isLoading
        visible: recipientLoader.ready && amountToSendInput.inputNumberValid && !d.errorMode
        onNextButtonClicked: popup.sendTransaction()
    }

    Connections {
        target: popup.store.walletSectionSendInst
        function onSuggestedRoutesReady(txRoutes) {
            popup.bestRoutes =  txRoutes.suggestedRoutes
            let gasTimeEstimate = txRoutes.gasTimeEstimate
            d.totalTimeEstimate = popup.store.getLabelForEstimatedTxTime(gasTimeEstimate.totalTime)
            d.totalFeesInFiat = d.currencyStore.getFiatValue( gasTimeEstimate.totalFeesInEth, "ETH", d.currencyStore.currentCurrency) +
                d.currencyStore.getFiatValue(gasTimeEstimate.totalTokenFees, fees.selectedTokenSymbol, d.currencyStore.currentCurrency)
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
                if (error.includes(Constants.walletSection.authenticationCanceled)) {
                    return
                }
                sendingError.text = error
                return sendingError.open()
            }
            popup.close()
        }
    }
}

