import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1

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
    topPadding: 0
    bottomPadding: Style.current.xlPadding
    leftPadding: Style.current.xlPadding
    rightPadding: Style.current.xlPadding
    backgroundColor: Theme.palette.baseColor3

    QtObject {
        id: d
         property var debounceFetchSuggestedRoutes: Backpressure.debounce(root, 1000, function() {
                 root.swapAdaptor.fetchSuggestedRoutes(payPanel.rawValue)
         })

        function fetchSuggestedRoutes() {
            if (payPanel.valueValid) {
                root.swapAdaptor.newFetchReset()
                root.swapAdaptor.swapProposalLoading = true
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
            payPanel.reevaluateSelectedId()
        }
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 1000; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
    }
    
    onClosed: root.swapAdaptor.reset()

    header: Item {
        height: selector.height
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

    contentItem: ColumnLayout {
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
                    id: modalHeader
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
                // TODO: update this once https://github.com/status-im/status-desktop/issues/14780 is ready
                NetworkFilter {
                    id: networkFilter
                    objectName: "networkFilter"
                    Layout.alignment: Qt.AlignVCenter
                    multiSelection: false
                    showRadioButtons: false
                    showTitle: false
                    flatNetworks: root.swapAdaptor.filteredFlatNetworksModel
                    onToggleNetwork: (network) => {
                                         root.swapInputParamsForm.selectedNetworkChainId = network.chainId
                                     }
                    Component.onCompleted: {
                        if(root.swapInputParamsForm.selectedNetworkChainId !== -1)
                            networkFilter.setChain(root.swapInputParamsForm.selectedNetworkChainId)
                    }
                }

                Connections {
                    target: root.swapInputParamsForm
                    function onSelectedNetworkChainIdChanged() {
                        networkFilter.setChain(root.swapInputParamsForm.selectedNetworkChainId)
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.topMargin: 2
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
                flatNetworksModel: root.swapAdaptor.filteredFlatNetworksModel
                processedAssetsModel: root.swapAdaptor.processedAssetsModel

                tokenKey: root.swapInputParamsForm.fromTokensKey
                tokenAmount: {
                    // Only update if there is different in amount displayed
                    if (root.swapInputParamsForm.fromTokenAmount !==
                            SQUtils.AmountsArithmetic.fromString(value).toLocaleString(locale, 'f', -128)){
                        return root.swapInputParamsForm.fromTokenAmount
                    }
                    return payPanel.tokenAmount
                }

                swapSide: SwapInputPanel.SwapSide.Pay
                swapExchangeButtonWidth: swapButton.width

                onSelectedHoldingIdChanged: root.swapInputParamsForm.fromTokensKey = selectedHoldingId
                onValueChanged: root.swapInputParamsForm.fromTokenAmount = value.toLocaleString(locale, 'f', -128)
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
                flatNetworksModel: root.swapAdaptorfilteredFlatNetworksModel
                processedAssetsModel: root.swapAdaptor.processedAssetsModel

                tokenKey: root.swapInputParamsForm.toTokenKey
                tokenAmount: root.swapAdaptor.validSwapProposalReceived && root.swapAdaptor.toToken ? root.swapAdaptor.swapOutputData.toTokenAmount: root.swapInputParamsForm.toTokenAmount

                swapSide: SwapInputPanel.SwapSide.Receive
                swapExchangeButtonWidth: swapButton.width

                mainInputLoading: root.swapAdaptor.swapProposalLoading
                bottomTextLoading: root.swapAdaptor.swapProposalLoading

                onSelectedHoldingIdChanged: root.swapInputParamsForm.toTokenKey = selectedHoldingId

                /* TODO: keep this input as disabled until the work for adding a param to handle to
                   and from tokens inputed is supported by backend under
                   https://github.com/status-im/status-desktop/issues/15095 */
                interactive: false
            }

            SwapExchangeButton {
                id: swapButton
                anchors.centerIn: parent
            }
        }

        /* TODO: remove! Needed only till sign after approval is implemented under
           https://github.com/status-im/status-desktop/issues/14833 */
        StatusButton {
            text: "Final Swap after Approval"
            visible: root.swapAdaptor.validSwapProposalReceived && root.swapAdaptor.swapOutputData.approvalNeeded
            onClicked: {
                swapAdaptor.sendSwapTx()
                close()
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
                if (payPanel.amountEnteredGreaterThanBalance)   {
                    return qsTr("Insufficient funds for swap")
                }
                return qsTr("An error has occured, please try again")
            }
            buttonText: qsTr("Buy crypto")
            buttonVisible: payPanel.amountEnteredGreaterThanBalance
            onButtonClicked: Global.openBuyCryptoModalRequested()
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
                    font.pixelSize: 15
                    font.weight: Font.Medium
                }
                RowLayout {
                    StatusBaseText {
                        objectName: "maxSlippageValue"
                        text: "%1%".arg(LocaleUtils.numberToLocaleString(root.swapInputParamsForm.selectedSlippage))
                        color: Theme.palette.directColor4
                        font.pixelSize: 15
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
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                    StatusTextWithLoadingState {
                        objectName: "maxFeesValue"
                        text: loading ? Constants.dummyText :
                                        root.swapAdaptor.validSwapProposalReceived ?
                                            root.swapAdaptor.currencyStore.formatCurrencyAmount(
                                                root.swapAdaptor.swapOutputData.totalFees,
                                                root.swapAdaptor.currencyStore.currentCurrency) :
                                            "--"
                        customColor: Theme.palette.directColor4
                        font.pixelSize: 15
                        font.weight: Font.Medium
                        loading: root.swapAdaptor.swapProposalLoading
                    }
                }
                StatusButton {
                    objectName: "signButton"
                    icon.name: "password"
                    /* TODO: Handling the next step agter approval of spending cap TBD under
                       https://github.com/status-im/status-desktop/issues/14833 */
                    text: root.swapAdaptor.validSwapProposalReceived &&
                          root.swapAdaptor.swapOutputData.approvalNeeded ?
                              qsTr("Approve %1").arg(!!root.swapAdaptor.fromToken ? root.swapAdaptor.fromToken.symbol: "") :
                              qsTr("Swap")
                    disabledColor: Theme.palette.directColor8
                    enabled: root.swapAdaptor.validSwapProposalReceived &&
                             editSlippagePanel.valid &&
                             !payPanel.amountEnteredGreaterThanBalance
                    onClicked: {
                        if (root.swapAdaptor.validSwapProposalReceived ){
                            if(root.swapAdaptor.swapOutputData.approvalNeeded) {
                                swapAdaptor.sendApproveTx()
                            }
                            else {
                                swapAdaptor.sendSwapTx()
                                close()
                            }
                        }
                    }
                }
            }
        }
    }
}

