import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

import utils 1.0
import shared.stores.send 1.0

import StatusQ 0.1
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

    required property TransactionStore store
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
        popup.store.authenticateAndTransfer(d.uuid)
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.preSelectedAccount && !!holdingSelector.selectedItem
                && recipientLoader.ready && amountToSendInput.inputNumberValid) {
            popup.isLoading = true
            popup.store.suggestedRoutes(d.isCollectiblesTransfer ? "1" : amountToSendInput.cryptoValueToSend)
        }
    })

    QtObject {
        id: d

        property bool ensOrStickersPurpose: popup.preSelectedSendType === Constants.SendType.ENSRegister ||
                                            popup.preSelectedSendType === Constants.SendType.ENSRelease ||
                                            popup.preSelectedSendType === Constants.SendType.ENSSetPubKey ||
                                            popup.preSelectedSendType === Constants.SendType.StickersBuy

        readonly property var currencyStore: store.currencyStore
        readonly property int errorType: !amountToSendInput.input.valid && (!isCollectiblesTransfer) ? Constants.SendAmountExceedsBalance :
                                                                          (popup.bestRoutes && popup.bestRoutes.count === 0 &&
                                                                           !!amountToSendInput.input.text && recipientLoader.ready && !popup.isLoading) ?
                                                                              Constants.NoRoute : Constants.NoError
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset ? selectedHolding.currentCurrencyBalance : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset ? selectedHolding.currentBalance : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? currencyStore.currentCurrency : !!d.selectedHolding && !!d.selectedHolding.symbol ? d.selectedHolding.symbol: ""
        readonly property bool errorMode: popup.isLoading || !recipientLoader.ready ? false : errorType !== Constants.NoError || networkSelector.errorMode || !amountToSendInput.inputNumberValid
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInFiat
        property double totalAmountToReceive

        readonly property bool isBridgeTx: store.sendType === Constants.SendType.Bridge
        readonly property bool isSwapTx: store.sendType === Constants.SendType.Swap

        readonly property bool isCollectiblesTransfer: store.sendType === Constants.SendType.ERC721Transfer ||
                                                       store.sendType === Constants.SendType.ERC1155Transfer
        property var selectedHolding: null
        property var selectedHoldingType: Constants.TokenType.Unknown

        property var selectedHolding2: null
        property var selectedHolding2Type: Constants.TokenType.Unknown

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

        function setSelectedHolding2Id(holdingId, holdingType) {
            let holding = store.getHolding(holdingId, holdingType)
            setSelectedHolding2(holding, holdingType)
        }

        function setSelectedHolding2(holding, holdingType) {
            d.selectedHolding2Type = holdingType
            d.selectedHolding2 = holding
            let selectorHolding = store.holdingToSelectorHolding(holding, holdingType)
            holdingSelector2.setSelectedItem(selectorHolding, holdingType)
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
                if(!d.ensOrStickersPurpose && !d.isBridgeTx && !d.isSwapTx)
                    store.setSendType(Constants.SendType.Transfer)
                store.setSelectedAssetKey(selectedHolding.tokensKey)
                store.setSelectedTokenIsOwnerToken(false)
            } else if (d.selectedHoldingType === Constants.TokenType.ERC721 ||
                       d.selectedHoldingType === Constants.TokenType.ERC1155) {
                let sendType = d.selectedHoldingType === Constants.TokenType.ERC721 ? Constants.SendType.ERC721Transfer : Constants.SendType.ERC1155Transfer
                store.setSendType(sendType)
                amountToSendInput.input.text = 1
                store.setSelectedAssetKey(selectedHolding.contractAddress+":"+selectedHolding.tokenId)
                store.setRouteEnabledFromChains(selectedHolding.chainId)
                store.updateRoutePreferredChains(selectedHolding.chainId)
                store.setSelectedTokenIsOwnerToken(selectedHolding.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner)
            }
            store.setSelectedTokenName(selectedHolding.name)

            recalculateRoutesAndFees()
        }

        onSelectedHolding2Changed: {
            if (!d.isSwapTx) {
                return
            }
            if (d.selectedHolding2Type === Constants.TokenType.ERC20) {
                store.setSelectedToAssetKey(selectedHolding2.tokensKey)
            }
            recalculateRoutesAndFees()
        }

        function prepareForMaxSend(value, symbol) {
            if(symbol !== "ETH") {
                return value
            }

            return value - Math.max(0.0001, Math.min(0.01, value * 0.1))
        }
    }

    bottomPadding: 16
    padding: 0
    background: StatusDialogBackground {
        implicitHeight: 846
        implicitWidth: 556
        color: Theme.palette.baseColor3
    }

    onOpened: {
        amountToSendInput.input.input.edit.forceActiveFocus()

        if(popup.preSelectedSendType !== Constants.SendType.Unknown) {
            store.setSendType(popup.preSelectedSendType)
        }
        if ((popup.preSelectedHoldingType > Constants.TokenType.Native) &&
                (popup.preSelectedHoldingType < Constants.TokenType.Unknown)) {
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

        if (d.isSwapTx) {
            recipientLoader.selectedRecipientType = TabAddressSelectorView.Type.Address
            recipientLoader.selectedRecipient = {address: popup.preSelectedAccount.address}

            if (popup.store.areTestNetworksEnabled) {
                d.setSelectedHolding2Id("STT", Constants.TokenType.ERC20)
                return
            }
            d.setSelectedHolding2Id("SNT", Constants.TokenType.ERC20)
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
            if (d.isSelectedHoldingValidAsset) {
                d.setSelectedHoldingId(d.selectedHolding.symbol, d.selectedHoldingType)
            }
            popup.recalculateRoutesAndFees()
        }
    }

    ColumnLayout {
        id: group1

        anchors.fill: parent

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: assetAndAmountSelector.implicitHeight
                                    + Style.current.halfPadding
            z: 100

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
                    Layout.maximumWidth: parent.width - 2*Style.current.xlPadding

                    StatusBaseText {
                        id: modalHeader
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            if (d.isBridgeTx)
                                return qsTr("Bridge")
                            if (d.isSwapTx)
                                return qsTr("Swap")
                            return qsTr("Send")
                        }
                        font.pixelSize: 28
                        lineHeight: 38
                        lineHeightMode: Text.FixedHeight
                        font.letterSpacing: -0.4
                        color: Theme.palette.directColor1
                    }

                    HoldingSelector {
                        id: holdingSelector
                        Layout.preferredWidth: holdingSelector2.visible? 130 : -1
                        Layout.fillHeight: true
                        selectedSenderAccount: store.selectedSenderAccount.address
                        assetsModel: popup.store.processedAssetsModel
                        collectiblesModel: popup.preSelectedAccount ? popup.nestedCollectiblesModel : null
                        networksModel: popup.store.flatNetworksModel
                        currentCurrencySymbol: d.currencyStore.currentCurrencySymbol
                        visible: (!!d.selectedHolding && d.selectedHoldingType !== Constants.TokenType.Unknown) ||
                                 (!!d.hoveredHolding && d.hoveredHoldingType !== Constants.TokenType.Unknown)
                        onItemSelected: {
                            d.setSelectedHoldingId(holdingId, holdingType)
                        }
                        onSearchTextChanged: popup.store.assetSearchString = searchText
                        formatCurrentCurrencyAmount: function(balance){
                            return popup.store.currencyStore.formatCurrencyAmount(balance, popup.store.currencyStore.currentCurrency)
                        }
                        formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                            return popup.store.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
                        }
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        visible: holdingSelector2.visible
                        text: qsTr("To")
                        font.pixelSize: 28
                        lineHeight: 38
                        lineHeightMode: Text.FixedHeight
                        font.letterSpacing: -0.4
                        color: Theme.palette.directColor1
                    }

                    HoldingSelector {
                        id: holdingSelector2
                        Layout.preferredWidth: 130
                        Layout.fillHeight: true
                        selectedSenderAccount: store.selectedSenderAccount.address
                        assetsModel: popup.store.processedAssetsModel
                        collectiblesModel: popup.preSelectedAccount ? popup.nestedCollectiblesModel : null
                        networksModel: popup.store.flatNetworksModel
                        currentCurrencySymbol: d.currencyStore.currentCurrencySymbol
                        visible: d.isSwapTx && !!d.selectedHolding && d.selectedHoldingType !== Constants.TokenType.Unknown
                        onItemSelected: {
                            d.setSelectedHolding2Id(holdingId, holdingType)
                        }
                        onSearchTextChanged: popup.store.assetSearchString = searchText
                        formatCurrentCurrencyAmount: function(balance){
                            return popup.store.currencyStore.formatCurrencyAmount(balance, popup.store.currencyStore.currentCurrency)
                        }
                        formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                            return popup.store.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    StatusListItemTag {
                        Layout.maximumWidth: 300
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.preferredHeight: 22
                        visible: d.isSelectedHoldingValidAsset || d.isHoveredHoldingValidAsset && !d.isCollectiblesTransfer
                        title: {
                            if(d.isHoveredHoldingValidAsset && !!d.hoveredHolding.symbol) {
                                const input = amountToSendInput.inputIsFiat ? d.hoveredHolding.currentCurrencyBalance : d.hoveredHolding.currentBalance
                                const max = d.prepareForMaxSend(input, d.hoveredHolding.symbol)
                                if (max <= 0)
                                    return qsTr("No balances active")
                                const balance = d.currencyStore.formatCurrencyAmount(max , d.hoveredHolding.symbol)
                                return qsTr("Max: %1").arg(balance.toString())
                            }
                            const max = d.prepareForMaxSend(d.maxInputBalance, d.inputSymbol)
                            if (max <= 0)
                                return qsTr("No balances active")

                            const balance = d.currencyStore.formatCurrencyAmount(max, d.inputSymbol)
                            return qsTr("Max: %1").arg(balance.toString())
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
                    visible: d.isSelectedHoldingValidAsset && !d.isCollectiblesTransfer
                    AmountToSend {
                        id: amountToSendInput

                        Layout.fillWidth: true
                        isBridgeTx: d.isBridgeTx
                        isSwapTx: d.isSwapTx
                        interactive: popup.interactive
                        selectedHolding: d.selectedHolding
                        maxInputBalance: d.maxInputBalance
                        currentCurrency: d.currencyStore.currentCurrency

                        // Collectibles do not have decimals
                        multiplierIndex: d.isSelectedHoldingValidAsset && !!holdingSelector.selectedItem && !!holdingSelector.selectedItem.decimals
                                         ? holdingSelector.selectedItem.decimals
                                         : 0

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
                        selectedHolding: d.selectedHolding
                        selectedHolding2: d.selectedHolding2
                        isBridgeTx: d.isBridgeTx
                        isSwapTx: d.isSwapTx
                        cryptoValueToReceive: d.totalAmountToReceive
                        inputIsFiat: amountToSendInput.inputIsFiat
                        minCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                        minFiatDecimals: amountToSendInput.minReceiveFiatDecimals
                        currentCurrency: d.currencyStore.currentCurrency
                        formatCurrencyAmount: d.currencyStore.formatCurrencyAmount
                    }
                }

                // Selected Recipient
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    visible: !d.isBridgeTx && !d.isSwapTx && !!d.selectedHolding
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
                        isCollectiblesTransfer: d.isCollectiblesTransfer
                        isBridgeTx: d.isBridgeTx
                        isSwapTx: d.isSwapTx
                        interactive: popup.interactive
                        selectedAsset: d.selectedHolding
                        onIsLoading: popup.isLoading = true
                        onRecalculateRoutesAndFees: popup.recalculateRoutesAndFees()
                        onAddressTextChanged: store.setSelectedRecipient(addressText)
                    }
                }
            }
        }

        TokenListView {
            id: tokenListRect
            Layout.fillHeight: true
            Layout.fillWidth:  true
            Layout.topMargin: Style.current.padding
            Layout.leftMargin: Style.current.xlPadding
            Layout.rightMargin: Style.current.xlPadding
            Layout.bottomMargin: Style.current.xlPadding
            visible: !d.selectedHolding

            isSwapTx: d.isSwapTx
            selectedSenderAccount: store.selectedSenderAccount.address
            assets: popup.store.processedAssetsModel
            collectibles: popup.preSelectedAccount ? popup.nestedCollectiblesModel : null
            networksModel: popup.store.flatNetworksModel
            onlyAssets: holdingSelector.onlyAssets
            onTokenSelected: function (symbolOrTokenKey, holdingType) {
                d.setSelectedHoldingId(symbolOrTokenKey, holdingType)
            }
            onTokenHovered: {
                if(hovered) {
                    d.setHoveredHoldingId(symbol, holdingType)
                } else {
                    d.setHoveredHoldingId("", Constants.TokenType.Unknown)
                }
            }
            onAssetSearchStringChanged: store.assetSearchString = assetSearchString
            formatCurrentCurrencyAmount: function(balance){
                return popup.store.currencyStore.formatCurrencyAmount(balance, popup.store.currencyStore.currentCurrency)
            }
            formatCurrencyAmountFromBigInt: function(balance, symbol, decimals) {
                return popup.store.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
            }
        }

        TabAddressSelectorView {
            id: addressSelector
            Layout.fillHeight: true
            Layout.fillWidth:  true
            Layout.topMargin: Style.current.padding
            Layout.leftMargin: Style.current.xlPadding
            Layout.rightMargin: Style.current.xlPadding
            visible: !recipientLoader.ready && !d.isBridgeTx && !d.isSwapTx && !!d.selectedHolding

            store: popup.store
            selectedAccount: popup.preSelectedAccount
            onRecipientSelected:  {
                recipientLoader.selectedRecipientType = type
                recipientLoader.selectedRecipient = recipient
            }
        }

        StatusScrollView {
            id: scrollView

            padding: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Style.current.bigPadding
            Layout.leftMargin: Style.current.xlPadding
            Layout.rightMargin: Style.current.xlPadding

            contentWidth: availableWidth

            visible: recipientLoader.ready && !!d.selectedHolding && amountToSendInput.inputNumberValid

            objectName: "sendModalScroll"

            Behavior on implicitHeight {
                NumberAnimation { duration: 700; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
            }

            NetworkSelector {
                id: networkSelector

                width: scrollView.availableWidth

                store: popup.store
                interactive: popup.interactive
                selectedRecipient: recipientLoader.selectedRecipient
                ensAddressOrEmpty: recipientLoader.resolvedENSAddress
                amountToSend: amountToSendInput.cryptoValueToSendFloat
                minSendCryptoDecimals: amountToSendInput.minSendCryptoDecimals
                minReceiveCryptoDecimals: amountToSendInput.minReceiveCryptoDecimals
                selectedAsset: d.selectedHolding
                onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                errorType: d.errorType
                isLoading: popup.isLoading
                isBridgeTx: d.isBridgeTx
                isSwapTx: d.isSwapTx
                isCollectiblesTransfer: d.isCollectiblesTransfer
                bestRoutes: popup.bestRoutes
                totalFeesInFiat: d.totalFeesInFiat
            }
        }
    }

    footer: SendModalFooter {
        width: parent.width
        nextButtonText: {
            if (d.isBridgeTx)
                return qsTr("Bridge")
            if (d.isSwapTx)
                return qsTr("Swap")
            return qsTr("Send")
        }
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
            let totalTokenFeesInFiat = 0
            if (!!d.selectedHolding && !!d.selectedHolding.marketDetails && !!d.selectedHolding.marketDetails.currencyPrice)
                totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * d.selectedHolding.marketDetails.currencyPrice.amount
            d.totalFeesInFiat = d.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat

            if (d.selectedHolding.type === Constants.TokenType.ERC20 || d.selectedHolding.type === Constants.TokenType.Native) {
                // If assets
                d.totalAmountToReceive = popup.store.getWei2Eth(txRoutes.amountToReceive, d.selectedHolding.decimals)
            } else {
                // If collectible
                d.totalAmountToReceive = txRoutes.amountToReceive
            }
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

