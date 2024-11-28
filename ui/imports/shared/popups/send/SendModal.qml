import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import SortFilterProxyModel 0.2

import AppLayouts.Wallet 1.0

import utils 1.0
import shared.stores 1.0
import shared.stores.send 1.0
import shared.controls 1.0

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.adaptors 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores

import shared.popups.send.panels 1.0
import "./controls"
import "./views"

StatusDialog {
    id: popup

    property string preSelectedAccountAddress: store.selectedSenderAccountAddress

    // Recipient properties definition
    property alias preSelectedRecipient: recipientInputLoader.selectedRecipient
    property alias preSelectedRecipientType: recipientInputLoader.selectedRecipientType

    property string preDefinedAmountToSend
    property int preSelectedChainId: 0
    property string stickersPackId

    // needed for registering ENS
    property string publicKey
    property string ensName

    // token symbol
    property string preSelectedHoldingID
    property int preSelectedHoldingType: Constants.TokenType.Unknown
    property int preSelectedSendType
    property bool interactive: true
    property alias onlyAssets: holdingSelector.onlyAssets

    property alias modalHeader: modalHeader.text

    required property TransactionStore store
    property WalletStores.CollectiblesStore collectiblesStore

    property var bestRoutes
    property bool isLoading: false
    property int loginType
    property bool showCustomRoutingMode

    // In case selected address is incorrect take first account from the list
    readonly property alias selectedAccount: selectedSenderAccountEntry.item

    property var sendTransaction: function() {
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(d.uuid)
    }

    readonly property string uuid: d.uuid

    QtObject {
        id: d

        property string extraParamsJson: ""

        property bool ensOrStickersPurpose: popup.preSelectedSendType === Constants.SendType.ENSRegister ||
                                            popup.preSelectedSendType === Constants.SendType.ENSRelease ||
                                            popup.preSelectedSendType === Constants.SendType.ENSSetPubKey ||
                                            popup.preSelectedSendType === Constants.SendType.StickersBuy

        readonly property CurrenciesStore currencyStore: store.currencyStore

        readonly property int errorType: {
            if (amountToSend.balanceExceeded && !isCollectiblesTransfer)
                return Constants.SendAmountExceedsBalance

            if (popup.bestRoutes && popup.bestRoutes.count === 0
                    && !amountToSend.empty && recipientInputLoader.ready
                    && !popup.isLoading)
                return Constants.NoRoute

            return Constants.NoError
        }

        readonly property double maxFiatBalance: isSelectedHoldingValidAsset ? selectedHolding.currencyBalance : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset ? selectedHolding.currentBalance : 0
        readonly property double maxInputBalance: amountToSend.fiatMode ? maxFiatBalance : maxCryptoBalance

        readonly property string tokenSymbol: !!d.selectedHolding && !!d.selectedHolding.symbol ? d.selectedHolding.symbol: ""
        readonly property string inputSymbol: amountToSend.fiatMode ? currencyStore.currentCurrency : tokenSymbol
        readonly property bool errorMode: {
            if (popup.isLoading || !recipientInputLoader.ready)
                return false

             return errorType !== Constants.NoError
                || networkSelector.errorMode
                || !(amountToSend.ready || d.isCollectiblesTransfer)
        }

        // This way of displaying errors is just first aid, we have to build better way of handilg errors on the UI side
        // and remove `d.errorType`
        property string routerError: ""
        property string routerErrorDetails: ""

        property string sendError: ""

        property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property string totalTimeEstimate
        property double totalFeesInFiat
        property double totalAmountToReceive
        readonly property bool isBridgeTx: store.sendType === Constants.SendType.Bridge
        readonly property bool isCollectiblesTransfer: store.sendType === Constants.SendType.ERC721Transfer ||
                                                       store.sendType === Constants.SendType.ERC1155Transfer
        property var selectedHolding: null
        property int selectedHoldingType: Constants.TokenType.Unknown
        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding && selectedHoldingType === Constants.TokenType.ERC20

        onSelectedHoldingChanged: {
            d.sendError = ""
            if (!selectedHolding) {
                return
            }

            if (d.selectedHoldingType === Constants.TokenType.ERC20) {
                if(!d.ensOrStickersPurpose && store.sendType !== Constants.SendType.Bridge)
                    store.setSendType(Constants.SendType.Transfer)
                store.setSelectedAssetKey(selectedHolding.tokensKey)
                store.setSelectedTokenIsOwnerToken(false)
            } else if (d.selectedHoldingType === Constants.TokenType.ERC721 ||
                       d.selectedHoldingType === Constants.TokenType.ERC1155) {
                let sendType = d.selectedHoldingType === Constants.TokenType.ERC721 ? Constants.SendType.ERC721Transfer : Constants.SendType.ERC1155Transfer
                store.setSendType(sendType)
                amountToSend.setValue("1")
                store.setSelectedAssetKey(selectedHolding.contractAddress+":"+selectedHolding.tokenId)
                store.setRouteEnabledFromChains(selectedHolding.chainId)
                store.updateRoutePreferredChains(selectedHolding.chainId)
                store.setSelectedTokenIsOwnerToken(selectedHolding.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner)
            }
            store.setSelectedTokenName(selectedHolding.name)

            recalculateRoutesAndFees()
        }

        function addMetricsEvent(subEventName) {
            Global.addCentralizedMetricIfEnabled(d.isBridgeTx ? "bridge" : "send", {subEvent: subEventName})
        }

        function areInputParametersValid() {
            return !!popup.selectedAccount && !!popup.selectedAccount.address && !!holdingSelector.selectedItem
                && recipientInputLoader.ready && (amountToSend.ready || d.isCollectiblesTransfer)
        }

        property var debounceRecalculateRoutesAndFees: Backpressure.debounce(popup, 1000, function() {
            if(d.areInputParametersValid()) {
                popup.store.suggestedRoutes(d.uuid, d.isCollectiblesTransfer ? "1" : amountToSend.amount, "0", d.extraParamsJson)
            }
        })

        function recalculateRoutesAndFees() {
            if(d.areInputParametersValid()) {
                popup.isLoading = true
            }
            d.uuid = Utils.uuid()
            d.routerError = ""
            d.routerErrorDetails = ""
            debounceRecalculateRoutesAndFees()
        }
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

    padding: 0
    background: StatusDialogBackground {
        implicitHeight: 846
        implicitWidth: 556
        color: Theme.palette.baseColor3
    }

    onOpened: {
        amountToSend.forceActiveFocus()

        // IMPORTANT: This step must be the first one since it's storing the send type
        // into the backend at this stage so that, before this assignement, some properties
        // should not have the correct value, like `d.isBridgeTx`
        if(popup.preSelectedSendType !== Constants.SendType.Unknown) {
            store.setSendType(popup.preSelectedSendType)
        }

        // To be removed once bridge is splitted to a different component:
        if(d.isBridgeTx && !!popup.preSelectedAccountAddress) {
            // Default preselected type is `Helpers.RecipientAddressObjectType.Address` coinciding with bridge usecase
            popup.preSelectedRecipient = popup.preSelectedAccountAddress
        }

        if (!!popup.preSelectedHoldingID
                && popup.preSelectedHoldingType >= Constants.TokenType.Native
                && popup.preSelectedHoldingType < Constants.TokenType.Unknown) {

            if (popup.preSelectedHoldingType === Constants.TokenType.Native
                    || popup.preSelectedHoldingType === Constants.TokenType.ERC20) {
                const entry = SQUtils.ModelUtils.getByKey(
                                assetsAdaptor.outputAssetsModel, "tokensKey",
                                popup.preSelectedHoldingID)
                d.selectedHoldingType = Constants.TokenType.ERC20
                d.selectedHolding = entry

                holdingSelector.setSelection(entry.symbol, entry.iconSource,
                                             popup.preSelectedHoldingID)
                holdingSelector.selectedItem = entry
            } else {
                const entry = SQUtils.ModelUtils.getByKey(
                                popup.collectiblesStore.allCollectiblesModel,
                                "symbol", popup.preSelectedHoldingID)

                d.selectedHoldingType = entry.tokenType
                d.selectedHolding = entry

                const id = entry.communityId ? entry.collectionUid : entry.uid

                holdingSelector.setSelection(entry.name,
                                             entry.imageUrl || entry.mediaUrl,
                                             id)
                holdingSelector.selectedItem = entry
                holdingSelector.currentTab = TokenSelectorPanel.Tabs.Collectibles
            }
        }
        if(!!popup.preDefinedAmountToSend) {
            // TODO: At this stage the number should not be localized. However
            // in many places when initializing popup the number is provided
            // in localized version. It should be refactored to provide raw
            // number consistently. Only the displaying component should apply
            // final localized formatting.
            const delocalized = popup.preDefinedAmountToSend.replace(LocaleUtils.userInputLocale.decimalPoint, ".")

            amountToSend.setValue(delocalized)
        }
        
        if (!!popup.preSelectedChainId) {
            popup.preDefinedAmountToSend = popup.preDefinedAmountToSend.replace(Qt.locale().decimalPoint, '.')
            store.updateRoutePreferredChains(popup.preSelectedChainId)
        }

        if (!!popup.stickersPackId) {
            d.extraParamsJson = "{\"%1\":\"%2\"}".arg(Constants.suggestedRoutesExtraParamsProperties.packId).arg(popup.stickersPackId)
        }

        if (!!popup.ensName && !!popup.publicKey) {
            d.extraParamsJson = "{\"%1\":\"%2\",\"%3\":\"%4\"}"
            .arg(Constants.suggestedRoutesExtraParamsProperties.username)
            .arg(popup.ensName)
            .arg(Constants.suggestedRoutesExtraParamsProperties.publicKey)
            .arg(popup.publicKey)
        }

        d.addMetricsEvent("popup opened")
    }

    onClosed: {
        popup.store.stopUpdatesForSuggestedRoute()
        popup.store.resetStoredProperties()
        d.addMetricsEvent("popup closed")
    }

    header: Item {
        implicitHeight: accountSelector.implicitHeight
        implicitWidth: accountSelector.implicitWidth
        anchors.top: parent.top
        anchors.topMargin: -height - 18

        AccountSelectorHeader {
            id: accountSelector
            model: SortFilterProxyModel {
                sourceModel: popup.store.accounts

                filters: [
                    ValueFilter {
                        roleName: "canSend"
                        value: true
                    }
                ]
                sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
            }
            selectedAddress: popup.preSelectedAccountAddress
            onCurrentAccountAddressChanged: {
                d.sendError = ""
                store.setSenderAccount(currentAccountAddress)

                if (d.isSelectedHoldingValidAsset) {
                    d.selectedHolding = SQUtils.ModelUtils.getByKey(
                                holdingSelector.assetsModel, "tokensKey",
                                d.selectedHolding.tokensKey)
                }

                d.recalculateRoutesAndFees()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: assetAndAmountSelector.implicitHeight
                                    + Theme.halfPadding
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
                anchors.leftMargin: Theme.xlPadding
                anchors.rightMargin: Theme.xlPadding

                z: 1
                spacing: 16

                RowLayout {
                    spacing: 8
                    Layout.preferredHeight: 44
                    Layout.maximumWidth: parent.width

                    HeaderTitleText {
                        id: modalHeader
                        objectName: "modalHeader"
                        Layout.maximumWidth: contentWidth
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        text: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
                    }

                    TokenSelector {
                        id: holdingSelector
                        objectName: "holdingSelector"

                        property var selectedItem
                        property bool onlyAssets: false

                        assetsModel: assetsAdaptor.outputAssetsModel
                        collectiblesModel: collectiblesAdaptorLoader.active
                                           ? collectiblesAdaptorLoader.item.model : null
                        Layout.fillWidth: true
                        Layout.maximumWidth: implicitWidth

                        TokenSelectorViewAdaptor {
                            id: assetsAdaptor

                            assetsModel: d.isBridgeTx ?
                                             popup.store.walletAssetStore.bridgeableGroupedAccountAssetsModel :
                                             popup.store.walletAssetStore.groupedAccountAssetsModel

                            flatNetworksModel: popup.store.flatNetworksModel
                            currentCurrency: popup.store.currencyStore.currentCurrency
                            accountAddress: popup.selectedAccount.address
                            showCommunityAssets: popup.store.tokensStore.showCommunityAssetsInSend
                        }

                        Loader {
                            id: collectiblesAdaptorLoader

                            active: !d.isBridgeTx

                            sourceComponent: CollectiblesSelectionAdaptor {
                                accountKey: popup.selectedAccount.address

                                networksModel: SortFilterProxyModel {
                                    sourceModel: popup.store.flatNetworksModel
                                    filters: ValueFilter { roleName: "isTest"; value: popup.store.areTestNetworksEnabled }
                                }
                                collectiblesModel: SortFilterProxyModel {
                                    sourceModel: collectiblesStore ? collectiblesStore.jointCollectiblesBySymbolModel : null
                                    filters: ValueFilter {
                                        roleName: "soulbound"
                                        value: false
                                    }
                                }
                            }
                        }

                        onAssetSelected: {
                            const entry = SQUtils.ModelUtils.getByKey(
                                            assetsModel, "tokensKey", key)
                            d.selectedHoldingType = Constants.TokenType.ERC20
                            d.selectedHolding = entry
                            selectedItem = entry
                        }

                        onCollectibleSelected: {
                            const entry = SQUtils.ModelUtils.getByKey(
                                            popup.collectiblesStore.allCollectiblesModel,
                                            "symbol", key)
                            d.selectedHoldingType = entry.tokenType
                            d.selectedHolding = entry
                            selectedItem = entry
                        }

                        onCollectionSelected: {
                            const entry = SQUtils.ModelUtils.getByKey(
                                            popup.collectiblesStore.allCollectiblesModel,
                                            "collectionUid", key)
                            d.selectedHoldingType = entry.tokenType
                            d.selectedHolding = entry
                            selectedItem = entry
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    MaxSendButton {
                        id: maxButton

                        readonly property double maxSafeValue: WalletUtils.calculateMaxSafeSendAmount(
                                                                   d.maxInputBalance, d.inputSymbol)

                        readonly property double maxSafeCryptoValue: WalletUtils.calculateMaxSafeSendAmount(
                                                                         d.maxCryptoBalance, d.tokenSymbol)

                        formattedValue: d.currencyStore.formatCurrencyAmount(
                                            maxSafeValue, d.inputSymbol,
                                            {   noSymbol: !amountToSend.fiatMode,
                                                roundingMode: LocaleUtils.RoundingMode.Down })

                        markAsInvalid: amountToSend.markAsInvalid

                        Layout.maximumWidth: 300
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                        visible: d.isSelectedHoldingValidAsset && !d.isCollectiblesTransfer
                        // FIXME: This should be enabled after #15709 is resolved
                        enabled: false

                        onClicked: {
                            if (maxSafeValue > 0) {
                                amountToSend.setValue(SQUtils.AmountsArithmetic.fromNumber(maxSafeValue).toString())
                            }else {
                                amountToSend.clear()
                            }

                            amountToSend.forceActiveFocus()
                        }
                    }
                }
                RowLayout {
                    visible: d.isSelectedHoldingValidAsset && !d.isCollectiblesTransfer

                    AmountToSend {
                        id: amountToSend

                        caption: d.isBridgeTx ? qsTr("Amount to bridge")
                                              : qsTr("Amount to send")
                        interactive: popup.interactive

                        readonly property bool balanceExceeded:
                            SQUtils.AmountsArithmetic.fromNumber(maxButton.maxSafeCryptoValue, multiplierIndex).cmp(amount) === -1

                        readonly property bool ready: valid && !empty && !balanceExceeded

                        readonly property string selectedSymbol:
                            !!d.selectedHolding && !!d.selectedHolding.symbol
                            ? d.selectedHolding.symbol : ""

                        // For backward compatibility. To be removed when
                        // dependent components (NetworkSelector, AmountToReceive)
                        // are refactored.
                        readonly property double asNumber: {
                            if (!valid)
                                return 0

                            return parseFloat(text.replace(LocaleUtils.userInputLocale.decimalPoint, "."))
                        }
                        readonly property int minSendCryptoDecimals:
                            !fiatMode ? LocaleUtils.fractionalPartLength(asNumber) : 0
                        readonly property int minReceiveCryptoDecimals:
                            !fiatMode ? minSendCryptoDecimals + 1 : 0
                        readonly property int minSendFiatDecimals:
                            fiatMode ? LocaleUtils.fractionalPartLength(asNumber) : 0
                        readonly property int minReceiveFiatDecimals:
                            fiatMode ? minSendFiatDecimals + 1 : 0
                        // End of to-be-removed part

                        markAsInvalid: balanceExceeded

                        // Collectibles do not have decimals
                        multiplierIndex:
                            d.isSelectedHoldingValidAsset
                            && !!holdingSelector.selectedItem
                            && !!holdingSelector.selectedItem.decimals
                            ? holdingSelector.selectedItem.decimals : 0

                        price: d.isSelectedHoldingValidAsset
                               ? (d.selectedHolding ?
                                      d.selectedHolding.marketDetails.currencyPrice.amount : 1)
                               : 1

                        formatFiat: amount => d.currencyStore.formatCurrencyAmount(
                                        amount, d.currencyStore.currentCurrency)
                        formatBalance: amount => d.currencyStore.formatCurrencyAmount(
                                           amount, selectedSymbol)

                        onValidChanged: {
                            d.sendError = ""
                            d.recalculateRoutesAndFees()
                        }

                        onAmountChanged: {
                            d.sendError = ""
                            d.recalculateRoutesAndFees()
                        }
                    }

                    // Horizontal spacer
                    RowLayout {}

                    AmountToReceive {
                        id: amountToReceive
                        Layout.alignment: Qt.AlignRight
                        Layout.fillWidth:true
                        visible: !!popup.bestRoutes && popup.bestRoutes !== undefined &&
                                 popup.bestRoutes.count > 0 && amountToSend.ready
                        isLoading: popup.isLoading
                        selectedHolding: d.selectedHolding
                        isBridgeTx: d.isBridgeTx
                        cryptoValueToReceive: d.totalAmountToReceive
                        inputIsFiat: amountToSend.fiatMode
                        minCryptoDecimals: amountToSend.minReceiveCryptoDecimals
                        minFiatDecimals: amountToSend.minReceiveFiatDecimals
                        currentCurrency: d.currencyStore.currentCurrency
                        formatCurrencyAmount: d.currencyStore.formatCurrencyAmount
                    }
                }

                // Selected Recipient
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    visible: !d.isBridgeTx
                    StatusBaseText {
                        id: label
                        elide: Text.ElideRight
                        text: qsTr("To")
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }
                    RecipientView {
                        id: recipientInputLoader

                        Layout.fillWidth: true
                        store: popup.store
                        isCollectiblesTransfer: d.isCollectiblesTransfer
                        isBridgeTx: d.isBridgeTx
                        interactive: popup.interactive
                        selectedAsset: d.selectedHolding
                        onIsLoading: popup.isLoading = true
                        onRecalculateRoutesAndFees: {
                            d.sendError = ""
                            d.recalculateRoutesAndFees()
                        }
                        onAddressTextChanged: store.setSelectedRecipient(addressText)
                    }
                }
            }
        }

        RecipientSelectorPanel {
            id: recipientsPanel

            Layout.fillHeight: true
            Layout.fillWidth:  true
            Layout.topMargin: Theme.padding
            Layout.leftMargin: Theme.xlPadding
            Layout.rightMargin: Theme.xlPadding
            Layout.bottomMargin: Theme.padding

            visible: !recipientInputLoader.ready && !d.isBridgeTx

            savedAddressesModel: popup.store.savedAddressesModel
            myAccountsModel: popup.store.accounts
            recentRecipientsModel: popup.store.tempActivityController1Model // Use Layer1 controller since this could go on top of other activity lists

            onRecipientSelected:  {
                popup.preSelectedRecipientType = type
                popup.preSelectedRecipient = recipient
            }

            // Only request transactions history update if visually needed:
            onRecentRecipientsTabSelected: popup.store.updateRecentRecipientsActivity(popup.selectedAccount.address)

            Connections {
                target: popup
                function onSelectedAccountChanged() {
                    // Only request transactions history update if visually needed:
                    if(recipientsPanel.recentRecipientsTabVisible) {
                        popup.store.updateRecentRecipientsActivity(popup.selectedAccount.address)
                    }
                }
            }
        }

        StatusScrollView {
            id: scrollView

            padding: 0
            bottomPadding: Theme.padding

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Theme.bigPadding
            Layout.leftMargin: Theme.xlPadding
            Layout.rightMargin: Theme.xlPadding

            contentWidth: availableWidth

            visible: recipientInputLoader.ready &&
                     (amountToSend.ready || d.isCollectiblesTransfer)

            onVisibleChanged: {
                if (!visible)
                    d.sendError = ""
            }

            objectName: "sendModalScroll"

            Behavior on implicitHeight {
                NumberAnimation { duration: 700; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
            }

            NetworkSelector {
                id: networkSelector

                width: scrollView.availableWidth

                store: popup.store
                interactive: popup.interactive
                selectedRecipient: popup.preSelectedRecipient
                ensAddressOrEmpty: recipientInputLoader.ready ? recipientInputLoader.resolvedENSAddress : ""
                amountToSend: amountToSend.asNumber
                minSendCryptoDecimals: amountToSend.minSendCryptoDecimals
                minReceiveCryptoDecimals: amountToSend.minReceiveCryptoDecimals
                selectedAsset: d.selectedHolding
                onReCalculateSuggestedRoute: {
                    d.sendError = ""
                    d.recalculateRoutesAndFees()
                }
                errorType: d.errorType
                isLoading: popup.isLoading
                isBridgeTx: d.isBridgeTx
                isCollectiblesTransfer: d.isCollectiblesTransfer
                bestRoutes: popup.bestRoutes
                totalFeesInFiat: d.totalFeesInFiat
                fromNetworksList: fromNetworksRouteModel
                toNetworksList: toNetworksRouteModel
                showCustomRoutingMode: popup.showCustomRoutingMode

                routerError: d.routerError
                routerErrorDetails: d.routerErrorDetails
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Theme.bigPadding
            Layout.leftMargin: Theme.xlPadding
            Layout.rightMargin: Theme.xlPadding
            Layout.bottomMargin: Theme.xlPadding
            implicitHeight: sendErrorColumn.height + Theme.padding
            color: Theme.palette.dangerColor3
            radius: 8
            border.width: 1
            border.color: Theme.palette.dangerColor2

            visible: !!d.sendError

            ColumnLayout {
                id: sendErrorColumn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                spacing: Theme.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.padding
                    font.pixelSize: Theme.secondaryTextFontSize
                    font.bold: true
                    wrapMode: Text.WrapAnywhere
                    text: qsTr("Error sending the transaction")
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: Theme.tertiaryTextFontSize
                    wrapMode: Text.WrapAnywhere
                    text: d.sendError
                }
            }
        }
    }

    footer: TransactionModalFooter {
        width: parent.width
        nextButtonText: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
        nextButtonIconName: !!popup.selectedAccount && popup.selectedAccount.migratedToKeycard ? Constants.authenticationIconByType[Constants.LoginType.Keycard]
                                                                                               : Constants.authenticationIconByType[popup.loginType]
        maxFiatFees: popup.isLoading ? "..." : d.currencyStore.formatCurrencyAmount(d.totalFeesInFiat, d.currencyStore.currentCurrency)
        totalTimeEstimate: popup.isLoading? "..." : d.totalTimeEstimate
        pending: d.isPendingTx || popup.isLoading
        visible: recipientInputLoader.ready && (amountToSend.ready || d.isCollectiblesTransfer) && !d.errorMode && !d.routerError

        onNextButtonClicked: {
            d.sendError = ""
            popup.sendTransaction()
            d.addMetricsEvent("next button clicked")
        }
    }

    Connections {
        target: popup.store.walletSectionSendInst
        function onSuggestedRoutesReady(txRoutes, errCode, errDescription) {
            if (txRoutes.uuid !== d.uuid) {
                // Suggested routes for a different fetch, ignore
                return
            }

            popup.bestRoutes =  txRoutes.suggestedRoutes

            d.routerError = WalletUtils.getRouterErrorBasedOnCode(errCode)
            d.routerErrorDetails = "%1 - %2".arg(errCode).arg(WalletUtils.getRouterErrorDetailsOnCode(errCode, errDescription))

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

        function onTransactionSent(uuid: string, chainId: int, approvalTx: bool, txHash: string, error: string) {
            d.isPendingTx = false
            if (uuid !== d.uuid) return
            if (!!error) {
                if (error.includes(Constants.walletSection.authenticationCanceled)) {
                    return
                }
                d.sendError = error
                d.addMetricsEvent("tx send error")
                return
            }
            d.addMetricsEvent("tx send successful")
            popup.close()
        }
    }
}
