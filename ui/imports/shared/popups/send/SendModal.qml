import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
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

    property var preSelectedAccount: selectedAccount

    // Recipient properties definition
    property alias preSelectedRecipient: recipientInputLoader.selectedRecipient
    property alias preSelectedRecipientType: recipientInputLoader.selectedRecipientType

    property string preDefinedAmountToSend
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

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    readonly property var selectedAccount: {
        selectedSenderAccountEntry.value // Item changed is not triggered when the value is changed
        return selectedSenderAccountEntry.item ?? SQUtils.ModelUtils.get(store.accounts, 0)
    }

    property var sendTransaction: function() {
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(d.uuid)
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        if(!!popup.preSelectedAccount && !!holdingSelector.selectedItem
                && recipientInputLoader.ready && (amountToSendInput.inputNumberValid || d.isCollectiblesTransfer)) {
            popup.isLoading = true
            popup.store.suggestedRoutes(d.isCollectiblesTransfer ? "1" : amountToSendInput.cryptoValueToSend)
        }
    })

    QtObject {
        id: d

        readonly property WalletAccountsAdaptor accountsAdaptor: WalletAccountsAdaptor {
            accountsModel: popup.store.accounts
            flatNetworksModel: popup.store.flatNetworksModel
            areTestNetworksEnabled: popup.store.areTestNetworksEnabled
        }

        property bool ensOrStickersPurpose: popup.preSelectedSendType === Constants.SendType.ENSRegister ||
                                            popup.preSelectedSendType === Constants.SendType.ENSRelease ||
                                            popup.preSelectedSendType === Constants.SendType.ENSSetPubKey ||
                                            popup.preSelectedSendType === Constants.SendType.StickersBuy

        readonly property var currencyStore: store.currencyStore
        readonly property int errorType: !amountToSendInput.input.valid && (!isCollectiblesTransfer) ? Constants.SendAmountExceedsBalance :
                                                                          (popup.bestRoutes && popup.bestRoutes.count === 0 &&
                                                                           !!amountToSendInput.input.text && recipientInputLoader.ready && !popup.isLoading) ?
                                                                              Constants.NoRoute : Constants.NoError
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset ? selectedHolding.currentCurrencyBalance : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset ? selectedHolding.currentBalance : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? currencyStore.currentCurrency : !!d.selectedHolding && !!d.selectedHolding.symbol ? d.selectedHolding.symbol: ""
        readonly property bool errorMode: popup.isLoading || !recipientInputLoader.ready ? false : errorType !== Constants.NoError || networkSelector.errorMode || !(amountToSendInput.inputNumberValid || d.isCollectiblesTransfer)
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
        amountToSendInput.input.input.edit.forceActiveFocus()

        if(popup.preSelectedSendType !== Constants.SendType.Unknown) {
            store.setSendType(popup.preSelectedSendType)
        }
        if (!!popup.preSelectedHoldingID
                && popup.preSelectedHoldingType > Constants.TokenType.Native
                && popup.preSelectedHoldingType < Constants.TokenType.Unknown) {

            if (popup.preSelectedHoldingType === Constants.TokenType.ERC20) {
                const entry = SQUtils.ModelUtils.getByKey(
                                assetsAdaptor.outputAssetsModel, "tokensKey",
                                popup.preSelectedHoldingID)
                d.selectedHoldingType = Constants.TokenType.ERC20
                d.selectedHolding = entry

                holdingSelector.setCustom(entry.symbol, entry.iconSource,
                                          popup.preSelectedHoldingID)
                holdingSelector.selectedItem = entry
            } else {
                const entry = SQUtils.ModelUtils.getByKey(
                                popup.store.collectiblesModel,
                                "uid", popup.preSelectedHoldingID)

                d.selectedHoldingType = entry.tokenType
                d.selectedHolding = entry

                const id = entry.communityId ? entry.collectionUid : entry.uid

                holdingSelector.setCustom(entry.name,
                                          entry.imageUrl || entry.mediaUrl,
                                          id)
                holdingSelector.selectedItem = entry
                holdingSelector.currentTab = TokenSelectorPanel.Tabs.Collectibles
            }
        }

        if(!!popup.preDefinedAmountToSend) {
            amountToSendInput.input.text = Number(popup.preDefinedAmountToSend).toLocaleString(Qt.locale(), 'f', -128)
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
                sourceModel: popup.store.accounts

                filters: [
                    ValueFilter {
                        roleName: "canSend"
                        value: true
                    }
                ]
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
                    d.selectedHolding = SQUtils.ModelUtils.getByKey(
                                holdingSelector.assetsModel, "tokensKey",
                                d.selectedHolding.tokensKey)
                }

                popup.recalculateRoutesAndFees()
            }
        }
    }

    ColumnLayout {
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

                    TokenSelectorNew {
                        id: holdingSelector

                        property var selectedItem
                        property bool onlyAssets: false

                        assetsModel: assetsAdaptor.outputAssetsModel
                        collectiblesModel: collectiblesAdaptorLoader.active
                                           ? collectiblesAdaptorLoader.item.model : null

                        TokenSelectorViewAdaptor {
                            id: assetsAdaptor

                            assetsModel: popup.store.walletAssetStore.groupedAccountAssetsModel

                            flatNetworksModel: popup.store.flatNetworksModel
                            currentCurrency: popup.store.currencyStore.currentCurrency
                            accountAddress: popup.preSelectedAccount ? popup.preSelectedAccount.address : ""
                            showCommunityAssets: popup.store.tokensStore.showCommunityAssetsInSend
                        }

                        Loader {
                            id: collectiblesAdaptorLoader

                            active: !d.isBridgeTx

                            sourceComponent: CollectiblesSelectionAdaptor {
                                accountKey: popup.preSelectedAccount ? popup.preSelectedAccount.address : ""
                                collectiblesModel: collectiblesStore
                                                   ? collectiblesStore.jointCollectiblesBySymbolModel
                                                   : null
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
                                            popup.store.collectiblesModel,
                                            "uid", key)
                            d.selectedHoldingType = entry.tokenType
                            d.selectedHolding = entry
                            selectedItem = entry
                        }

                        onCollectionSelected: {
                            const entry = SQUtils.ModelUtils.getByKey(
                                            popup.store.collectiblesModel,
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
                        input.input.tabNavItem: recipientInputLoader.item
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
                        onRecalculateRoutesAndFees: popup.recalculateRoutesAndFees()
                        onAddressTextChanged: store.setSelectedRecipient(addressText)
                    }
                }
            }
        }

        RecipientSelectorPanel {
            id: recipientsPanel

            Layout.fillHeight: true
            Layout.fillWidth:  true
            Layout.topMargin: Style.current.padding
            Layout.leftMargin: Style.current.xlPadding
            Layout.rightMargin: Style.current.xlPadding
            Layout.bottomMargin: Style.current.padding

            visible: !recipientInputLoader.ready && !d.isBridgeTx

            savedAddressesModel: popup.store.savedAddressesModel
            myAccountsModel: d.accountsAdaptor.model
            recentRecipientsModel: popup.store.tempActivityController1Model // Use Layer1 controller since this could go on top of other activity lists

            onRecipientSelected:  {
                popup.preSelectedRecipientType = type
                popup.preSelectedRecipient = recipient
            }

            // Only request transactions history update if visually needed:
            onRecentRecipientsTabSelected: popup.store.updateRecentRecipientsActivity(popup.preSelectedAccount)

            Connections {
                target: popup
                function onPreSelectedAccountChanged() {
                    // Only request transactions history update if visually needed:
                    if(recipientsPanel.recentRecipientsTabVisible) {
                        popup.store.updateRecentRecipientsActivity(popup.preSelectedAccount)
                    }
                }
            }
        }

        StatusScrollView {
            id: scrollView

            padding: 0
            bottomPadding: Style.current.padding

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Style.current.bigPadding
            Layout.leftMargin: Style.current.xlPadding
            Layout.rightMargin: Style.current.xlPadding

            contentWidth: availableWidth

            visible: recipientInputLoader.ready &&
                     (amountToSendInput.inputNumberValid || d.isCollectiblesTransfer)

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
                ensAddressOrEmpty: recipientInputLoader.resolvedENSAddress
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

    footer: TransactionModalFooter {
        width: parent.width
        nextButtonText: d.isBridgeTx ? qsTr("Bridge") : qsTr("Send")
        nextButtonIconName: !!popup.selectedAccount && popup.selectedAccount.migratedToKeycard ? Constants.authenticationIconByType[Constants.LoginType.Keycard]
                                                                                               : Constants.authenticationIconByType[popup.loginType]
        maxFiatFees: popup.isLoading ? "..." : d.currencyStore.formatCurrencyAmount(d.totalFeesInFiat, d.currencyStore.currentCurrency)
        totalTimeEstimate: popup.isLoading? "..." : d.totalTimeEstimate
        pending: d.isPendingTx || popup.isLoading
        visible: recipientInputLoader.ready && (amountToSendInput.inputNumberValid || d.isCollectiblesTransfer) && !d.errorMode
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
