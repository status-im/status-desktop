import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

import AppLayouts.Wallet 1.0

import utils 1.0
import shared.stores.send 1.0
import shared.controls 1.0

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.controls 1.0

import "./panels"
import "./controls"
import "./views"
import "./models"

StatusDialog {
    id: popup

    property var preSelectedAccount: selectedAccount
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

    readonly property var selectedAccount: selectedSenderAccountEntry.item ?? ModelUtils.get(store.accounts, 0)

    property var sendTransaction: function() {
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(d.uuid)
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.preSelectedAccount && !!holdingSelector.selectedItem
                && recipientLoader.ready && (amountToSendInput.inputNumberValid || d.isCollectiblesTransfer)) {
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
        readonly property bool errorMode: popup.isLoading || !recipientLoader.ready ? false : errorType !== Constants.NoError || networkSelector.errorMode || !(amountToSendInput.inputNumberValid || d.isCollectiblesTransfer)
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInFiat
        property double totalAmountToReceive
        readonly property bool isBridgeTx: store.sendType === Constants.SendType.Bridge
        readonly property bool isCollectiblesTransfer: store.sendType === Constants.SendType.ERC721Transfer ||
                                                       store.sendType === Constants.SendType.ERC1155Transfer
        property var selectedHolding: null
        property var selectedHoldingType: Constants.TokenType.Unknown
        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding && selectedHoldingType === Constants.TokenType.ERC20
        property var hoveredHolding: null
        property var hoveredHoldingType: Constants.TokenType.Unknown
        readonly property bool isHoveredHoldingValidAsset: !!hoveredHolding && hoveredHoldingType === Constants.TokenType.ERC20

        function getHolding(holdingId, holdingType) {
            if (holdingType === Constants.TokenType.ERC20) {
                return store.getAsset(assetsAdaptor.model, holdingId)
            } else if (holdingType === Constants.TokenType.ERC721 || holdingType === Constants.TokenType.ERC1155) {
                return store.getCollectible(holdingId)
            } else {
                return {}
            }
        }

        function setSelectedHoldingId(holdingId, holdingType) {
            let holding = getHolding(holdingId, holdingType)
            setSelectedHolding(holding, holdingType)
        }

        function setSelectedHolding(holding, holdingType) {
            d.selectedHoldingType = holdingType
            d.selectedHolding = holding
            let selectorHolding = store.holdingToSelectorHolding(holding, holdingType)
            holdingSelector.setSelectedItem(selectorHolding, holdingType)
        }

        function setHoveredHoldingId(holdingId, holdingType) {
            let holding = getHolding(holdingId, holdingType)
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
    }

    SendModalAssetsAdaptor {
        id: assetsAdaptor

        controller: popup.store.walletAssetStore.assetsController
        showCommunityAssets: popup.store.tokensStore.showCommunityAssetsInSend
        tokensModel: popup.store.walletAssetStore.groupedAccountAssetsModel
        account: popup.store.selectedSenderAccountAddress
        marketValueThreshold:
            popup.store.tokensStore.displayAssetsBelowBalance
            ? popup.store.tokensStore.getDisplayAssetsBelowBalanceThresholdDisplayAmount()
            : 0
    }

    LeftJoinModel {
        id: fromNetworksRouteModel
        leftModel: popup.store.fromNetworksRouteModel
        rightModel: popup.store.flatNetworksModel
        joinRole: "chainId"
    }
    LeftJoinModel {
        id: toNetworksRouteModel
        leftModel: popup.store.toNetworksRouteModel
        rightModel: popup.store.flatNetworksModel
        joinRole: "chainId"
    }

    ModelEntry {
        id: selectedSenderAccountEntry
        key: "address"
        sourceModel: popup.store.accounts
        value: popup.store.selectedSenderAccountAddress
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
            amountToSendInput.input.text = Number(popup.preDefinedAmountToSend).toLocaleString(Qt.locale(), 'f', -128)
        }

        if(!!popup.preSelectedRecipient) {
            recipientLoader.selectedRecipientType = popup.preSelectedRecipientType
            if (popup.preSelectedRecipientType === TabAddressSelectorView.Type.Address) {
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

    header: Item {
        implicitHeight: accountSelector.implicitHeight
        implicitWidth: accountSelector.implicitWidth
        anchors.top: parent.top
        anchors.topMargin: -height - 18

        AccountSelectorHeader {
            id: accountSelector
            model: SortFilterProxyModel {
                sourceModel: SortFilterProxyModel {
                    sourceModel: popup.store.accounts
                    filters: [
                        ValueFilter {
                            roleName: "canSend"
                            value: true
                        }
                    ]
                }

                sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
                proxyRoles: [
                    FastExpressionRole {
                        name: "colorizedChainPrefixes"
                        function getChainShortNames(chainIds) {
                            const chainShortNames = popup.store.getNetworkShortNames(chainIds)
                            return WalletUtils.colorizedChainPrefix(chainShortNames)
                        }
                        expression: getChainShortNames(model.preferredSharingChainIds)
                        expectedRoles: ["preferredSharingChainIds"]
                    }
                ]
            }
            selectedAddress: !!popup.preSelectedAccount && !!popup.preSelectedAccount.address ? popup.preSelectedAccount.address : ""
            onCurrentAccountAddressChanged: {
                store.setSenderAccount(currentAccountAddress)
                if (d.isSelectedHoldingValidAsset) {
                    d.setSelectedHoldingId(d.selectedHolding.symbol, d.selectedHoldingType)
                }
                popup.recalculateRoutesAndFees()
            }
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

                    HeaderTitleText {
                        id: modalHeader
                        Layout.maximumWidth: contentWidth
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        text: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
                    }

                    HoldingSelector {
                        id: holdingSelector
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        assetsModel: assetsAdaptor.model
                        collectiblesModel: popup.preSelectedAccount ? popup.nestedCollectiblesModel : null
                        networksModel: popup.store.flatNetworksModel
                        visible: (!!d.selectedHolding && d.selectedHoldingType !== Constants.TokenType.Unknown) ||
                                 (!!d.hoveredHolding && d.hoveredHoldingType !== Constants.TokenType.Unknown)
                        onItemSelected: {
                            d.setSelectedHoldingId(holdingId, holdingType)
                        }
                        onSearchTextChanged: assetsAdaptor.assetSearchString = assetSearchString
                        formatCurrentCurrencyAmount: function(balance){
                            return popup.store.currencyStore.formatCurrencyAmount(balance, popup.store.currencyStore.currentCurrency)
                        }
                        formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                            return popup.store.formatCurrencyAmountFromBigInt(balance, symbol, decimals, {noSymbol: true})
                        }
                    }

                    MaxSendButton {
                        Layout.maximumWidth: 300
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        visible: d.isSelectedHoldingValidAsset || d.isHoveredHoldingValidAsset && !d.isCollectiblesTransfer

                        value: d.maxInputBalance
                        symbol: d.inputSymbol
                        valid: amountToSendInput.input.valid || !amountToSendInput.input.text
                        formatCurrencyAmount: (amount, symbol) => d.currencyStore.formatCurrencyAmount(amount, symbol, {noSymbol: !amountToSendInput.inputIsFiat})

                        onClicked: {
                            if (maxSafeValue > 0)
                                amountToSendInput.input.text = maxSafeValueAsString
                            else
                                amountToSendInput.input.input.edit.clear()
                            amountToSendInput.input.forceActiveFocus()
                        }
                    }
                }
                RowLayout {
                    visible: d.isSelectedHoldingValidAsset && !d.isCollectiblesTransfer
                    AmountToSend {
                        id: amountToSendInput

                        Layout.fillWidth: true
                        isBridgeTx: d.isBridgeTx
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
                        isBridgeTx: d.isBridgeTx
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
                        isCollectiblesTransfer: d.isCollectiblesTransfer
                        isBridgeTx: d.isBridgeTx
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

            assets: assetsAdaptor.model
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
            onAssetSearchStringChanged: assetsAdaptor.assetSearchString = assetSearchString
            formatCurrentCurrencyAmount: function(balance){
                return popup.store.currencyStore.formatCurrencyAmount(balance, popup.store.currencyStore.currentCurrency)
            }
            formatCurrencyAmountFromBigInt: function(balance, symbol, decimals) {
                return popup.store.formatCurrencyAmountFromBigInt(balance, symbol, decimals, {noSymbol: true})
            }
        }

        TabAddressSelectorView {
            id: addressSelector
            Layout.fillHeight: true
            Layout.fillWidth:  true
            Layout.topMargin: Style.current.padding
            Layout.leftMargin: Style.current.xlPadding
            Layout.rightMargin: Style.current.xlPadding
            visible: !recipientLoader.ready && !d.isBridgeTx && !!d.selectedHolding

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

            visible: recipientLoader.ready && !!d.selectedHolding && (amountToSendInput.inputNumberValid || d.isCollectiblesTransfer)

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
                isCollectiblesTransfer: d.isCollectiblesTransfer
                bestRoutes: popup.bestRoutes
                totalFeesInFiat: d.totalFeesInFiat
                fromNetworksList: fromNetworksRouteModel
                toNetworksList: toNetworksRouteModel
            }
        }
    }

    footer: SendModalFooter {
        width: parent.width
        nextButtonText: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
        maxFiatFees: popup.isLoading ? "..." : d.currencyStore.formatCurrencyAmount(d.totalFeesInFiat, d.currencyStore.currentCurrency)
        totalTimeEstimate: popup.isLoading? "..." : d.totalTimeEstimate
        pending: d.isPendingTx || popup.isLoading
        visible: recipientLoader.ready && (amountToSendInput.inputNumberValid || d.isCollectiblesTransfer) && !d.errorMode
        onNextButtonClicked: popup.sendTransaction()
    }

    Connections {
        target: popup.store.walletSectionSendInst
        function onSuggestedRoutesReady(txRoutes) {
            popup.bestRoutes =  txRoutes.suggestedRoutes
            let gasTimeEstimate = txRoutes.gasTimeEstimate
            d.totalTimeEstimate = WalletUtils.getLabelForEstimatedTxTime(gasTimeEstimate.totalTime)
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
            networkSelector.suggestedToNetworksList = txRoutes.toNetworksRouteModel
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
