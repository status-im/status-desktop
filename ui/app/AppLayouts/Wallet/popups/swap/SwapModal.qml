import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import SortFilterProxyModel 0.2

import utils 1.0

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1

import shared.popups.send.controls 1.0
import shared.controls 1.0
import shared.panels 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.popups.buy 1.0
import AppLayouts.Wallet.adaptors 1.0

StatusDialog {
    id: root

    /* This should be the only property which should be used to input
    parameters to the modal when being launched from elsewhere */
    required property SwapInputParamsForm swapInputParamsForm
    required property SwapModalAdaptor swapAdaptor
    required property int loginType

    signal addMetricsEvent(string subEvent)

    objectName: "swapModal"

    implicitWidth: 556
    padding: 0
    backgroundColor: Theme.palette.baseColor3

    QtObject {
        id: d
        property var debounceFetchSuggestedRoutes: Backpressure.debounce(root, 1000, function() {
            root.swapAdaptor.fetchSuggestedRoutes(payPanel.rawValue)
        })

        function fetchSuggestedRoutes() {
            root.swapAdaptor.invalidateSuggestedRoute()
            if (root.swapInputParamsForm.isFormFilledCorrectly()) {
                root.swapAdaptor.swapProposalLoading = true
                debounceFetchSuggestedRoutes()
            } else {
                root.swapAdaptor.swapProposalLoading = false
            }
        }

        readonly property bool isError: root.swapAdaptor.errorMessage !== ""

        readonly property BuyCryptoParamsForm buyFormData: BuyCryptoParamsForm {
            selectedWalletAddress: root.swapInputParamsForm.selectedAccountAddress
            selectedNetworkChainId: root.swapInputParamsForm.selectedNetworkChainId
            selectedTokenKey: root.swapInputParamsForm.fromTokensKey
        }

        readonly property WalletAccountsSelectorAdaptor accountsSelectorAdaptor : WalletAccountsSelectorAdaptor {
            accounts: root.swapAdaptor.swapStore.accounts
            assetsModel: root.swapAdaptor.walletAssetsStore.baseGroupedAccountAssetModel
            tokensBySymbolModel: root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel
            filteredFlatNetworksModel: SortFilterProxyModel {
                sourceModel: root.swapAdaptor.swapStore.flatNetworks
                filters: ValueFilter { roleName: "isTest"; value: root.swapAdaptor.swapStore.areTestNetworksEnabled }
            }

            selectedTokenKey: root.swapInputParamsForm.fromTokensKey
            selectedNetworkChainId: root.swapInputParamsForm.selectedNetworkChainId

            fnFormatCurrencyAmountFromBigInt: function(balance, symbol, decimals, options = null) {
                return root.swapAdaptor.currencyStore.formatCurrencyAmountFromBigInt(balance, symbol, decimals, options)
            }
        }

        readonly property var selectedAccount: selectedAccountEntry.item
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: d.accountsSelectorAdaptor.processedWalletAccounts
        key: "address"
        value: root.swapInputParamsForm.selectedAccountAddress
    }

    Connections {
        target: root.swapInputParamsForm
        function onFormValuesChanged() {
            d.fetchSuggestedRoutes()
        }

        // FIXME drop after SwapInputPanel uses ModelEntry to track the currently selected token
        // refresh the selected asset in payPanel when account/network changes
        function onSelectedAccountAddressChanged() {
            payPanel.reevaluateSelectedId()
        }
        function onSelectedNetworkChainIdChanged() {
            networkFilter.selection = [root.swapInputParamsForm.selectedNetworkChainId]
            payPanel.reevaluateSelectedId()
        }
    }

    // needed as the first time the value not loaded correctly without this Binding
    Binding {
        target: root.swapAdaptor
        property: "amountEnteredGreaterThanBalance"
        value: payPanel.amountEnteredGreaterThanBalance
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 1000; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
    }

    onOpened: {
        payPanel.forceActiveFocus()
        root.addMetricsEvent("popup opened")
    }
    onClosed: {
        root.swapAdaptor.stopUpdatesForSuggestedRoute()
        root.addMetricsEvent("popup closed")
    }

    header: Item {
        implicitHeight: selector.implicitHeight
        implicitWidth: selector.implicitWidth
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        AccountSelectorHeader {
            id: selector
            control.popup.width: 512
            model: d.accountsSelectorAdaptor.processedWalletAccounts
            selectedAddress: root.swapInputParamsForm.selectedAccountAddress
            onCurrentAccountAddressChanged: {
                if (currentAccountAddress !== "" && currentAccountAddress !== root.swapInputParamsForm.selectedAccountAddress) {
                    root.swapInputParamsForm.selectedAccountAddress = currentAccountAddress
                }
            }
            control.popup.onClosed: payPanel.forceActiveFocus()
        }
    }

    StatusScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        topPadding: 0
        bottomPadding: Theme.xlPadding

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: Theme.halfPadding
            anchors.right: parent.right
            anchors.rightMargin: Theme.halfPadding
            spacing: Theme.padding
            clip: true

            // without this Column, the whole popup resizing when the network selector popup is clicked
            Column {
                Layout.fillWidth: true
                spacing: 0
                RowLayout {
                    width: parent.width
                    spacing: 12
                    HeaderTitleText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        text: qsTr("Swap")
                    }
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        text: qsTr("On:")
                        color: Theme.palette.baseColor1
                        font.pixelSize: 13
                        lineHeight: 38
                        lineHeightMode: Text.FixedHeight
                        verticalAlignment: Text.AlignVCenter
                    }
                    NetworkFilter {
                        id: networkFilter
                        objectName: "networkFilter"
                        Layout.alignment: Qt.AlignVCenter
                        multiSelection: false
                        showSelectionIndicator: false
                        showTitle: false
                        flatNetworks: root.swapAdaptor.filteredFlatNetworksModel
                        selection: [root.swapInputParamsForm.selectedNetworkChainId]
                        onSelectionChanged: {
                            if (root.swapInputParamsForm.selectedNetworkChainId !== selection[0]) {
                                root.swapInputParamsForm.selectedNetworkChainId = selection[0]
                                if(!!root.swapAdaptor.fromToken && !!root.swapAdaptor.fromToken.addressPerChain) {
                                    let fromTokenAddressOnSelectedChain = SQUtils.ModelUtils.getByKey(
                                            root.swapAdaptor.fromToken.addressPerChain, "chainId",
                                            root.swapInputParamsForm.selectedNetworkChainId, "address")
                                    if(!fromTokenAddressOnSelectedChain) {
                                        // reset from token as it doesnt exist on selected network
                                        root.swapInputParamsForm.resetFromTokenValues(false)
                                    }
                                }
                                if(!!root.swapAdaptor.toToken && !!root.swapAdaptor.toToken.addressPerChain) {
                                    let toTokenAddressOnSelectedChain = SQUtils.ModelUtils.getByKey(
                                            root.swapAdaptor.toToken.addressPerChain, "chainId",
                                            root.swapInputParamsForm.selectedNetworkChainId, "address")
                                    if(!toTokenAddressOnSelectedChain) {
                                        // reset to token as it doesnt exist on selected network
                                        root.swapInputParamsForm.resetToTokenValues(false)
                                    }
                                }
                            }
                            payPanel.forceActiveFocus()
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.margins: 2
                Layout.preferredHeight: payPanel.height + receivePanel.height + 4

                SwapInputPanel {
                    id: payPanel
                    objectName: "payPanel"

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }

                    currencyStore: root.swapAdaptor.currencyStore
                    flatNetworksModel: root.swapAdaptor.swapStore.flatNetworks
                    processedAssetsModel: root.swapAdaptor.walletAssetsStore.groupedAccountAssetsModel
                    plainTokensBySymbolModel: root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel

                    tokenKey: root.swapInputParamsForm.fromTokensKey
                    tokenAmount: root.swapInputParamsForm.fromTokenAmount

                    cryptoFeesToReserve: root.swapAdaptor.swapOutputData.maxFeesToReserveRaw

                    selectedNetworkChainId: root.swapInputParamsForm.selectedNetworkChainId
                    selectedAccountAddress: root.swapInputParamsForm.selectedAccountAddress
                    nonInteractiveTokensKey: receivePanel.selectedHoldingId

                    swapSide: SwapInputPanel.SwapSide.Pay
                    swapExchangeButtonWidth: swapExchangeButton.width

                    bottomTextLoading: root.swapAdaptor.swapProposalLoading

                    onSelectedHoldingIdChanged: root.swapInputParamsForm.fromTokensKey = selectedHoldingId

                    onRawValueChanged: {
                        if(root.swapInputParamsForm.fromTokensKey === selectedHoldingId) {
                            const amount = !tokenAmount && value === 0 ? "" :
                                                                         SQUtils.AmountsArithmetic.div(SQUtils.AmountsArithmetic.fromString(rawValue),
                                                                                                       SQUtils.AmountsArithmetic.fromNumber(1, rawValueMultiplierIndex)).toString()
                            root.swapInputParamsForm.fromTokenAmount = amount
                        }
                    }
                }

                SwapInputPanel {
                    id: receivePanel
                    objectName: "receivePanel"

                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    currencyStore: root.swapAdaptor.currencyStore
                    flatNetworksModel: root.swapAdaptor.swapStore.flatNetworks
                    processedAssetsModel: root.swapAdaptor.walletAssetsStore.groupedAccountAssetsModel
                    plainTokensBySymbolModel: root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel

                    tokenKey: root.swapInputParamsForm.toTokenKey
                    tokenAmount: root.swapAdaptor.validSwapProposalReceived && root.swapAdaptor.toToken ? root.swapAdaptor.swapOutputData.toTokenAmount: root.swapInputParamsForm.toTokenAmount

                    selectedNetworkChainId: root.swapInputParamsForm.selectedNetworkChainId
                    selectedAccountAddress: root.swapInputParamsForm.selectedAccountAddress
                    nonInteractiveTokensKey: payPanel.selectedHoldingId

                    swapSide: SwapInputPanel.SwapSide.Receive
                    swapExchangeButtonWidth: swapExchangeButton.width

                    mainInputLoading: root.swapAdaptor.swapProposalLoading
                    bottomTextLoading: root.swapAdaptor.swapProposalLoading

                    onSelectedHoldingIdChanged: root.swapInputParamsForm.toTokenKey = selectedHoldingId

                    /* TODO: keep this input as disabled until the work for adding a param to handle to
                    and from tokens inputed is supported by backend under
                    https://github.com/status-im/status-desktop/issues/15095 */
                    interactive: false
                }

                SwapExchangeButton {
                    id: swapExchangeButton
                    objectName: "swapExchangeButton"
                    anchors.centerIn: parent
                    enabled: !!root.swapInputParamsForm.fromTokensKey || !!root.swapInputParamsForm.toTokenKey
                    onClicked: {
                        const tempPayToken = root.swapInputParamsForm.fromTokensKey
                        const tempPayAmount = root.swapInputParamsForm.fromTokenAmount
                        root.swapInputParamsForm.fromTokensKey = root.swapInputParamsForm.toTokenKey
                        root.swapInputParamsForm.fromTokenAmount = !!root.swapAdaptor.swapOutputData.toTokenAmount ? root.swapAdaptor.swapOutputData.toTokenAmount : root.swapInputParamsForm.toTokenAmount
                        root.swapInputParamsForm.toTokenKey = tempPayToken
                        root.swapInputParamsForm.toTokenAmount = tempPayAmount
                        payPanel.forceActiveFocus()
                    }
                }
            }

            EditSlippagePanel {
                id: editSlippagePanel
                objectName: "editSlippagePanel"
                Layout.fillWidth: true
                Layout.topMargin: Theme.padding
                visible: editSlippageButton.checked
                selectedToToken: root.swapAdaptor.toToken
                toTokenAmount: root.swapAdaptor.swapOutputData.toTokenAmount
                loading: root.swapAdaptor.swapProposalLoading
                onSlippageValueChanged: {
                    root.swapInputParamsForm.selectedSlippage = slippageValue
                }
            }

            ErrorTag {
                objectName: "errorTag"
                visible: d.isError
                Layout.maximumWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.smallPadding
                text: root.swapAdaptor.errorMessage
                buttonText: root.swapAdaptor.isTokenBalanceInsufficient ? qsTr("Add assets") : qsTr("Add ETH")
                buttonVisible: visible && (root.swapAdaptor.isTokenBalanceInsufficient || root.swapAdaptor.isEthBalanceInsufficient)
                onButtonClicked: {
                    // value dont update correctly if not done from here
                    d.buyFormData.selectedWalletAddress = root.swapInputParamsForm.selectedAccountAddress
                    d.buyFormData.selectedNetworkChainId = root.swapInputParamsForm.selectedNetworkChainId
                    d.buyFormData.selectedTokenKey = root.swapAdaptor.isTokenBalanceInsufficient ?
                                root.swapInputParamsForm.fromTokensKey :
                                Constants.ethToken
                    Global.openBuyCryptoModalRequested(d.buyFormData)
                }
            }
        }
    }

    footer: StatusDialogFooter {
        color: Theme.palette.baseColor3
        dropShadowEnabled: true
        leftButtons: ObjectModel {
            ColumnLayout {
                Layout.leftMargin: Theme.padding
                spacing: 0
                StatusBaseText {
                    objectName: "maxSlippageText"
                    text: qsTr("Max slippage:")
                    color: Theme.palette.directColor5
                    font.weight: Font.Medium
                }
                RowLayout {
                    StatusBaseText {
                        objectName: "maxSlippageValue"
                        text: editSlippagePanel.valid ? "%1%".arg(LocaleUtils.numberToLocaleString(root.swapInputParamsForm.selectedSlippage))
                                                      : qsTr("N/A")
                        color: Theme.palette.directColor4
                        font.weight: Font.Medium
                    }
                    StatusFlatButton {
                        id: editSlippageButton
                        objectName: "editSlippageButton"
                        checkable: true
                        checked: false
                        icon.name: "edit_pencil"
                        textColor: editSlippageButton.hovered ? Theme.palette.directColor1 : Theme.palette.directColor5
                        size: StatusBaseButton.Size.Tiny
                        hoverColor: Theme.palette.transparent
                        visible: !checked
                    }
                }
            }
        }
        rightButtons: ObjectModel {
            RowLayout {
                Layout.rightMargin: Theme.padding
                spacing: Theme.bigPadding
                ColumnLayout {
                    StatusBaseText {
                        objectName: "maxFeesText"
                        text: qsTr("Max fees:")
                        color: Theme.palette.directColor5
                        font.weight: Font.Medium
                    }
                    StatusTextWithLoadingState {
                        id: fees
                        objectName: "maxFeesValue"
                        text: {
                            if(fees.loading) {
                                return Constants.dummyText
                            }

                            if(root.swapAdaptor.validSwapProposalReceived) {
                                return root.swapAdaptor.currencyStore.formatCurrencyAmount(
                                            root.swapAdaptor.swapOutputData.totalFees,
                                            root.swapAdaptor.currencyStore.currentCurrency)
                            }

                            return "--"
                        }

                        onTextChanged: {
                            if (text === "" || text === "--" || text === Constants.dummyText) {
                                animation.stop()
                                return
                            }
                            animation.restart()
                        }

                        customColor: Theme.palette.directColor4
                        font.weight: Font.Medium
                        loading: root.swapAdaptor.swapProposalLoading

                        AnimatedText {
                            id: animation
                            target: fees
                        }
                    }
                }
                StatusButton {
                    objectName: "signButton"
                    readonly property string fromTokenSymbol: !!root.swapAdaptor.fromToken ? root.swapAdaptor.fromToken.symbol ?? "" : ""
                    loadingWithText: root.swapAdaptor.approvalPending
                    icon.name: d.selectedAccount.migratedToKeycard ? Constants.authenticationIconByType[Constants.LoginType.Keycard]
                                                                                  : Constants.authenticationIconByType[root.loginType]
                    text: {
                        if(root.swapAdaptor.validSwapProposalReceived) {
                            if(root.swapAdaptor.swapOutputData.approvalNeeded) {
                                if (root.swapAdaptor.approvalPending) {
                                    return qsTr("Approving %1").arg(fromTokenSymbol)
                                } else if(!root.swapAdaptor.approvalSuccessful) {
                                    return qsTr("Approve %1").arg(fromTokenSymbol)
                                }
                            }
                        }
                        return qsTr("Swap")
                    }
                    tooltip.text: {
                        if(root.swapAdaptor.validSwapProposalReceived) {
                            if(root.swapAdaptor.swapOutputData.approvalNeeded) {
                                if (root.swapAdaptor.approvalPending) {
                                    return qsTr("Approving %1 spending cap to Swap").arg(fromTokenSymbol)
                                } else if(!root.swapAdaptor.approvalSuccessful) {
                                    return qsTr("Approve %1 spending cap to Swap").arg(fromTokenSymbol)
                                }
                            }
                        }
                        return ""
                    }
                    disabledColor: Theme.palette.directColor8
                    interactive: root.swapAdaptor.validSwapProposalReceived &&
                                 editSlippagePanel.valid &&
                                 !d.isError &&
                                 !root.swapAdaptor.approvalPending
                    onClicked: {
                        if (root.swapAdaptor.validSwapProposalReceived) {
                            root.addMetricsEvent("next button pressed")
                            if (root.swapAdaptor.swapOutputData.approvalNeeded && !root.swapAdaptor.approvalSuccessful)
                                Global.openPopup(swapApproveModalComponent)
                            else
                                Global.openPopup(swapSignModalComponent)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: swapApproveModalComponent
        SwapApproveCapModal {
            destroyOnClose: true

            formatBigNumber: (number, symbol, noSymbolOption) => root.swapAdaptor.currencyStore.formatBigNumber(number, symbol, noSymbolOption)

            loginType: d.selectedAccount.migratedToKeycard ? Constants.LoginType.Keycard : root.loginType
            feesLoading: root.swapAdaptor.swapProposalLoading

            fromTokenSymbol: root.swapAdaptor.fromToken.symbol
            fromTokenAmount: root.swapInputParamsForm.fromTokenAmount
            fromTokenContractAddress: SQUtils.ModelUtils.getByKey(root.swapAdaptor.fromToken.addressPerChain,
                                                                  "chainId", root.swapInputParamsForm.selectedNetworkChainId,
                                                                  "address")

            accountName: d.selectedAccount.name
            accountAddress: d.selectedAccount.address
            accountEmoji: d.selectedAccount.emoji
            accountColor: Utils.getColorForId(d.selectedAccount.colorId)
            accountBalanceFormatted: d.selectedAccount.accountBalance.formattedBalance

            networkShortName: networkFilter.singleSelectionItemData.shortName
            networkName: networkFilter.singleSelectionItemData.chainName
            networkIconPath: Theme.svg(networkFilter.singleSelectionItemData.iconUrl)
            networkBlockExplorerUrl: networkFilter.singleSelectionItemData.blockExplorerURL

            fiatFees: {
                const feesInFloat = root.swapAdaptor.currencyStore.getFiatValue(root.swapAdaptor.swapOutputData.approvalGasFees, Constants.ethToken)
                return root.swapAdaptor.currencyStore.formatCurrencyAmount(feesInFloat, root.swapAdaptor.currencyStore.currentCurrency)
            }
            cryptoFees: root.swapAdaptor.currencyStore.formatCurrencyAmount(parseFloat(root.swapAdaptor.swapOutputData.approvalGasFees), Constants.ethToken)
            estimatedTime: root.swapAdaptor.swapOutputData.estimatedTime

            serviceProviderName: root.swapAdaptor.swapOutputData.txProviderName
            serviceProviderURL: Constants.swap.paraswapUrl // TODO https://github.com/status-im/status-desktop/issues/15329
            serviceProviderTandCUrl: Constants.swap.paraswapTermsAndConditionUrl // TODO https://github.com/status-im/status-desktop/issues/15329
            serviceProviderIcon: Theme.png("swap/%1".arg(Constants.swap.paraswapIcon)) // FIXME svg
            serviceProviderContractAddress: root.swapAdaptor.swapOutputData.approvalContractAddress
            serviceProviderHostname: Constants.swap.paraswapHostname

            onRejected: root.addMetricsEvent("rejected approve")
            onAccepted: {
                root.addMetricsEvent("send approve tx")
                root.swapAdaptor.sendApproveTx()
            }
        }
    }

    Component {
        id: swapSignModalComponent
        SwapSignModal {
            destroyOnClose: true

            title: root.swapAdaptor.swapOutputData.approvalNeeded && root.swapAdaptor.approvalSuccessful? qsTr("Swap") : qsTr("Sign Swap")
            signButtonText: root.swapAdaptor.swapOutputData.approvalNeeded && root.swapAdaptor.approvalSuccessful? qsTr("Swap") : qsTr("Sign")

            formatBigNumber: (number, symbol, noSymbolOption) => root.swapAdaptor.currencyStore.formatBigNumber(number, symbol, noSymbolOption)

            loginType: d.selectedAccount.migratedToKeycard ? Constants.LoginType.Keycard : root.loginType
            feesLoading: root.swapAdaptor.swapProposalLoading

            fromTokenSymbol: root.swapAdaptor.fromToken.symbol
            fromTokenAmount: root.swapInputParamsForm.fromTokenAmount
            fromTokenContractAddress: SQUtils.ModelUtils.getByKey(root.swapAdaptor.fromToken.addressPerChain,
                                                                  "chainId", root.swapInputParamsForm.selectedNetworkChainId,
                                                                  "address")

            toTokenSymbol: root.swapAdaptor.toToken.symbol
            toTokenAmount: root.swapAdaptor.swapOutputData.toTokenAmount
            toTokenContractAddress: SQUtils.ModelUtils.getByKey(root.swapAdaptor.toToken.addressPerChain,
                                                                "chainId", root.swapInputParamsForm.selectedNetworkChainId,
                                                                "address")

            accountName: d.selectedAccount.name
            accountAddress: d.selectedAccount.address
            accountEmoji: d.selectedAccount.emoji
            accountColor: Utils.getColorForId(d.selectedAccount.colorId)

            networkShortName: networkFilter.singleSelectionItemData.shortName
            networkName: networkFilter.singleSelectionItemData.chainName
            networkIconPath: Theme.svg(networkFilter.singleSelectionItemData.iconUrl)
            networkBlockExplorerUrl: networkFilter.singleSelectionItemData.blockExplorerURL

            fiatFees: root.swapAdaptor.currencyStore.formatCurrencyAmount(root.swapAdaptor.swapOutputData.totalFees,
                                                                          root.swapAdaptor.currencyStore.currentCurrency)
            cryptoFees: {
                const cryptoValue = root.swapAdaptor.currencyStore.getCryptoValue(root.swapAdaptor.swapOutputData.totalFees, Constants.ethToken)
                return root.swapAdaptor.currencyStore.formatCurrencyAmount(cryptoValue, Constants.ethToken)
            }
            slippage: root.swapInputParamsForm.selectedSlippage

            serviceProviderName: root.swapAdaptor.swapOutputData.txProviderName
            serviceProviderURL: Constants.swap.paraswapUrl // TODO https://github.com/status-im/status-desktop/issues/15329
            serviceProviderTandCUrl: Constants.swap.paraswapTermsAndConditionUrl // TODO https://github.com/status-im/status-desktop/issues/15329

            onRejected: root.addMetricsEvent("rejected sign")
            onAccepted: {
                root.addMetricsEvent("send swap tx")
                root.swapAdaptor.sendSwapTx()
                root.close()
            }
        }
    }
}
