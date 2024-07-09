import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1

import shared.popups.send.controls 1.0
import shared.controls 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0

StatusDialog {
    id: root

    /* This should be the only property which should be used to input
    parameters to the modal when being launched from elsewhere */
    required property SwapInputParamsForm swapInputParamsForm
    required property SwapModalAdaptor swapAdaptor

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
            if (payPanel.valueValid && root.swapInputParamsForm.isFormFilledCorrectly()) {
                root.swapAdaptor.validSwapProposalReceived = false
                root.swapAdaptor.swapProposalLoading = true
                root.swapAdaptor.approvalPending = false
                root.swapAdaptor.approvalSuccessful = false
                root.swapAdaptor.swapOutputData.resetAllButReceivedTokenValuesForSwap()
                debounceFetchSuggestedRoutes()
            }
        }
    }

    Connections {
        target: root.swapInputParamsForm
        function onFormValuesChanged() {
            d.fetchSuggestedRoutes()
        }
        // refresh the selected asset in payPanel when account/network changes
        function onSelectedAccountAddressChanged() {
            payPanel.reevaluateSelectedId()
        }
        function onSelectedNetworkChainIdChanged() {
            networkFilter.selection = [root.swapInputParamsForm.selectedNetworkChainId]
            payPanel.reevaluateSelectedId()
        }
    }

    Connections {
        target: root.swapAdaptor
        function onApprovalSuccessfulChanged() {
            // perform a recalculation to make sure expected outcome shown is accurate
            if(root.swapAdaptor.approvalSuccessful) {
                d.fetchSuggestedRoutes()
            }
        }
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 1000; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
    }

    onClosed: root.swapAdaptor.reset()

    header: Item {
        implicitHeight: selector.implicitHeight
        implicitWidth: selector.implicitWidth
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        AccountSelectorHeader {
            id: selector
            control.popup.width: 512
            model: root.swapAdaptor.nonWatchAccounts
            selectedAddress: root.swapInputParamsForm.selectedAccountAddress
            onCurrentAccountAddressChanged: {
                if (currentAccountAddress !== "" && currentAccountAddress !== root.swapInputParamsForm.selectedAccountAddress) {
                    root.swapInputParamsForm.selectedAccountAddress = currentAccountAddress
                }
            }
        }
    }

    StatusScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        topPadding: 0
        bottomPadding: Style.current.xlPadding

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: Style.current.halfPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.halfPadding
            spacing: Style.current.padding
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
                                        root.swapInputParamsForm.resetFromTokenValues()
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

                    selectedNetworkChainId: root.swapInputParamsForm.selectedNetworkChainId
                    selectedAccountAddress: root.swapInputParamsForm.selectedAccountAddress
                    nonInteractiveTokensKey: receivePanel.selectedHoldingId

                    swapSide: SwapInputPanel.SwapSide.Pay
                    swapExchangeButtonWidth: swapExchangeButton.width

                    onSelectedHoldingIdChanged: root.swapInputParamsForm.fromTokensKey = selectedHoldingId
                    onRawValueChanged: {
                        if(root.swapInputParamsForm.fromTokensKey === selectedHoldingId) {
                            const amount = !tokenAmount && value === 0 ? "" :
                                                                         SQUtils.AmountsArithmetic.div(SQUtils.AmountsArithmetic.fromString(rawValue),
                                                                                                       SQUtils.AmountsArithmetic.fromNumber(1, rawValueMultiplierIndex)).toString()
                            root.swapInputParamsForm.fromTokenAmount = amount
                        }
                    }
                    onValueValidChanged: d.fetchSuggestedRoutes()
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
                    onClicked: {
                        const tempPayToken = root.swapInputParamsForm.fromTokensKey
                        const tempPayAmount = root.swapInputParamsForm.fromTokenAmount
                        root.swapInputParamsForm.fromTokensKey = root.swapInputParamsForm.toTokenKey
                        root.swapInputParamsForm.fromTokenAmount = !!root.swapAdaptor.swapOutputData.toTokenAmount ? root.swapAdaptor.swapOutputData.toTokenAmount : root.swapInputParamsForm.toTokenAmount
                        root.swapInputParamsForm.toTokenKey = tempPayToken
                        root.swapInputParamsForm.toTokenAmount = tempPayAmount
                    }
                }
            }

            EditSlippagePanel {
                id: editSlippagePanel
                objectName: "editSlippagePanel"
                Layout.fillWidth: true
                Layout.topMargin: Style.current.padding
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
                visible: root.swapAdaptor.swapOutputData.hasError || payPanel.amountEnteredGreaterThanBalance
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Style.current.smallPadding
                text: {
                    if (payPanel.amountEnteredGreaterThanBalance) {
                        return qsTr("Insufficient funds for swap")
                    }
                    return qsTr("An error has occured, please try again")
                }
                buttonText: qsTr("Buy crypto")
                buttonVisible: payPanel.amountEnteredGreaterThanBalance
                onButtonClicked: Global.openBuyCryptoModalRequested()
            }
        }
    }

    footer: StatusDialogFooter {
        color: Theme.palette.baseColor3
        dropShadowEnabled: true
        leftButtons: ObjectModel {
            ColumnLayout {
                Layout.leftMargin: Style.current.padding
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
                        text: "%1%".arg(LocaleUtils.numberToLocaleString(root.swapInputParamsForm.selectedSlippage))
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
                Layout.rightMargin: Style.current.padding
                spacing: Style.current.bigPadding
                ColumnLayout {
                    StatusBaseText {
                        objectName: "maxFeesText"
                        text: qsTr("Max fees:")
                        color: Theme.palette.directColor5
                        font.weight: Font.Medium
                    }
                    StatusTextWithLoadingState {
                        objectName: "maxFeesValue"
                        text: {
                            if(root.swapAdaptor.swapProposalLoading) {
                                return Constants.dummyText
                            }

                            if(root.swapAdaptor.validSwapProposalReceived) {
                                if(root.swapAdaptor.swapOutputData.approvalNeeded) {
                                    let approvalGasFeesFiat = root.swapAdaptor.currencyStore.getFiatValue(root.swapAdaptor.swapOutputData.approvalGasFees, Constants.ethToken)
                                    return root.swapAdaptor.currencyStore.formatCurrencyAmount(
                                                approvalGasFeesFiat,
                                                root.swapAdaptor.currencyStore.currentCurrency)
                                } else {
                                    return root.swapAdaptor.currencyStore.formatCurrencyAmount(
                                                root.swapAdaptor.swapOutputData.totalFees,
                                                root.swapAdaptor.currencyStore.currentCurrency)
                                }
                            }

                            return "--"
                        }
                        customColor: Theme.palette.directColor4
                        font.weight: Font.Medium
                        loading: root.swapAdaptor.swapProposalLoading
                    }
                }
                /* TODO: https://github.com/status-im/status-desktop/issues/15313
                will introduce having loading button and showing text on the side*/
                StatusButton {
                    objectName: "signButton"
                    readonly property string fromTokenSymbol: !!root.swapAdaptor.fromToken ? root.swapAdaptor.fromToken.symbol ?? "" : ""
                    loading: root.swapAdaptor.approvalPending
                    icon.name: "password"
                    text: {
                        if(root.swapAdaptor.validSwapProposalReceived) {
                            if (root.swapAdaptor.approvalPending) {
                                return qsTr("Approving %1").arg(fromTokenSymbol)
                            } else if(root.swapAdaptor.swapOutputData.approvalNeeded) {
                                return qsTr("Approve %1").arg(fromTokenSymbol)
                            }
                        }
                        return qsTr("Swap")
                    }
                    tooltip.text: root.swapAdaptor.validSwapProposalReceived &&
                                  root.swapAdaptor.swapOutputData.approvalNeeded ?
                                      qsTr("Approve %1 spending cap to Swap").arg(fromTokenSymbol) : ""
                    disabledColor: Theme.palette.directColor8
                    enabled: root.swapAdaptor.validSwapProposalReceived &&
                             editSlippagePanel.valid &&
                             !payPanel.amountEnteredGreaterThanBalance &&
                             !root.swapAdaptor.approvalPending
                    onClicked: {
                        if (root.swapAdaptor.validSwapProposalReceived) {
                            let txType = root.swapAdaptor.swapOutputData.approvalNeeded ? SwapSignApprovePopup.TxType.Approve : SwapSignApprovePopup.TxType.Swap
                            Global.openPopup(swapSignApprovePopup, {"txType": txType})
                        }
                    }
                }
            }
        }
    }

    /* TODO: this is only temporary placeholder and should be replaced completely by
    https://github.com/status-im/status-desktop/issues/14785 */
    Component {
        id: swapSignApprovePopup
        SwapSignApprovePopup {
            id: approvePopup
            destroyOnClose: true
            loading: root.swapAdaptor.swapProposalLoading
            swapSignApproveInputForm: SwapSignApproveInputForm {
                selectedAccountAddress: root.swapInputParamsForm.selectedAccountAddress
                selectedNetworkChainId: root.swapInputParamsForm.selectedNetworkChainId
                estimatedTime: root.swapAdaptor.swapOutputData.estimatedTime
                swapProviderName: root.swapAdaptor.swapOutputData.txProviderName
                approvalGasFees: root.swapAdaptor.swapOutputData.approvalGasFees
                approvalAmountRequired: root.swapAdaptor.swapOutputData.approvalAmountRequired
                approvalContractAddress: root.swapAdaptor.swapOutputData.approvalContractAddress
                fromTokensKey: root.swapInputParamsForm.fromTokensKey
                fromTokensAmount:  root.swapInputParamsForm.fromTokenAmount
                toTokensKey: root.swapInputParamsForm.toTokenKey
                toTokensAmount: root.swapAdaptor.swapOutputData.toTokenAmount
                swapFees: root.swapAdaptor.swapOutputData.totalFees
                selectedSlippage: root.swapInputParamsForm.selectedSlippage
            }
            adaptor: SwapSignApproveAdaptor {
                swapStore: root.swapAdaptor.swapStore
                walletAssetsStore: root.swapAdaptor.walletAssetsStore
                currencyStore: root.swapAdaptor.currencyStore
                inputFormData: approvePopup.swapSignApproveInputForm
            }
            onSign: {
                if(txType === SwapSignApprovePopup.TxType.Approve) {
                    root.swapAdaptor.sendApproveTx()
                    close()
                } else {
                    root.swapAdaptor.sendSwapTx()
                    close()
                    root.close()
                }
            }
            onReject: close()
        }
    }
}
