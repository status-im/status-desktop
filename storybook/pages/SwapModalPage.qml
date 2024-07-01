import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2
import QtTest 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import utils 1.0
import Storybook 1.0
import Models 1.0

import shared.stores 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.popups.swap 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    QtObject {
        id: d
        readonly property var tokenBySymbolModel: TokensBySymbolModel {}

        function launchPopup() {
            swapModal.createObject(root)
        }

        readonly property SwapTransactionRoutes dummySwapTransactionRoutes: SwapTransactionRoutes{}

        property string uuid

        function resetValues() {
            accountComboBox.currentIndex = 0
            fromTokenComboBox.currentIndex = 0
            swapInput.text = ""
            fetchSuggestedRoutesSpy.clear()
            authenticateAndTransferSpy.clear()
        }
    }

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !swapModal.visible

            onClicked: d.launchPopup()
        }

        Component.onCompleted: d.launchPopup()

        SwapStore {
            id: dSwapStore
            signal suggestedRoutesReady(var txRoutes)
            signal transactionSent(var chainId,var txHash, var uuid, var error)
            signal transactionSendingComplete(var txHash,  var success)

            readonly property var accounts: WalletAccountsModel {}
            readonly property var flatNetworks: NetworksModel.flatNetworks
            readonly property bool areTestNetworksEnabled: areTestNetworksEnabledCheckbox.checked

            function fetchSuggestedRoutes(uuid, accountFrom, accountTo, amount, tokenFrom, tokenTo,
                                          disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts) {
                console.debug("fetchSuggestedRoutes called >> uuid = ", uuid, " accountFrom = ", accountFrom, " accountTo =",
                              accountTo, "amount = ", amount, " tokenFrom = ", tokenFrom, " tokenTo = ", tokenTo,
                              " disabledFromChainIDs = ", disabledFromChainIDs, " disabledToChainIDs = ", disabledToChainIDs,
                              " preferredChainIDs = ", preferredChainIDs, " sendType =", sendType, " lockedInAmounts = ", lockedInAmounts)
                fetchSuggestedRoutesSignal()
            }
            function authenticateAndTransfer(uuid, accountFrom, accountTo, tokenFrom,
                                             tokenTo, sendType, tokenName, tokenIsOwnerToken, paths) {
                console.debug("authenticateAndTransfer called >> uuid ", uuid, " accountFrom = ",accountFrom, " accountTo =",
                              accountTo, "tokenFrom = ",tokenFrom, " tokenTo = ",tokenTo, " sendType = ", sendType,
                              " tokenName = ", tokenName, " tokenIsOwnerToken = ", tokenIsOwnerToken, " paths = ", paths)
                d.uuid = uuid
                authenticateAndTransferSignal()
            }
            function getWei2Eth(wei, decimals) {
                return wei/(10**decimals)
            }

            // only for testing
            signal fetchSuggestedRoutesSignal()
            signal authenticateAndTransferSignal()
        }

        SignalSpy {
            id: fetchSuggestedRoutesSpy
            target: dSwapStore
            signalName: "fetchSuggestedRoutesSignal"
        }

        SignalSpy {
            id: authenticateAndTransferSpy
            target: dSwapStore
            signalName: "authenticateAndTransferSignal"
        }

        TokensStore {
            id: tokensStore
            plainTokensBySymbolModel: TokensBySymbolModel {}
            getDisplayAssetsBelowBalanceThresholdDisplayAmount: () => 0
        }

        SwapModalAdaptor {
            id: adaptor
            swapStore: dSwapStore
            walletAssetsStore: WalletAssetsStore {
                id: thisWalletAssetStore
                walletTokensStore: tokensStore
                readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
            }
            currencyStore: CurrenciesStore {}
            swapFormData: SwapInputParamsForm {
                defaultToTokenKey: "STT"
                onSelectedAccountAddressChanged: {
                    if (selectedAccountAddress !== accountComboBox.currentValue)
                        accountComboBox.currentIndex = accountComboBox.indexOfValue(selectedAccountAddress)
                }
            }
            swapOutputData: SwapOutputData {}
        }

        Component {
            id: swapModal
            SwapModal {
                id: modal
                visible: true
                modal: false
                closePolicy: Popup.CloseOnEscape
                destroyOnClose: true
                swapInputParamsForm: adaptor.swapFormData
                swapAdaptor: adaptor
                plainTokensBySymbolModel: ListModel {
                    ListElement {
                        key: "aave"
                        name: "Aave"
                        symbol: "AAVE"
                        image: "https://cryptologos.cc/logos/aave-aave-logo.png"
                        communityId: ""
                        decimals: 18
                        marketDetails: []
                    }
                    ListElement {
                        key: "usdc"
                        name: "USDC"
                        symbol: "USDC"
                        image: ""
                        communityId: ""
                        decimals: 18
                        marketDetails: []
                    }
                    ListElement {
                        key: "hst"
                        name: "Decision Token"
                        symbol: "HST"
                        image: ""
                        communityId: ""
                        decimals: 18
                        marketDetails: []
                    }
                }
                Binding {
                    target: swapInputParamsForm
                    property: "fromTokensKey"
                    value: fromTokenComboBox.currentValue ?? ""
                }
                Binding {
                    target: swapInputParamsForm
                    property: "toTokenKey"
                    value: toTokenComboBox.currentValue ?? ""
                }
                Binding {
                    target: swapInputParamsForm
                    property: "selectedNetworkChainId"
                    value: networksComboBox.currentValue ?? -1
                }
                Binding {
                    target: swapInputParamsForm
                    property: "selectedAccountAddress"
                    value: accountComboBox.currentValue ?? ""
                }
                Binding {
                    target: swapInputParamsForm
                    property: "fromTokenAmount"
                    value: swapInput.text
                }
                Binding {
                    target: swapInputParamsForm
                    property: "selectedNetworkChainId"
                    value: networksComboBox.currentValue ?? -1
                }
                Binding {
                    target: swapInputParamsForm
                    property: "selectedAccountAddress"
                    value: accountComboBox.currentValue ?? ""
                }
                Binding {
                    target: swapInputParamsForm
                    property: "fromTokenAmount"
                    value: swapInput.text
                }

                Connections {
                    target: approveTxButton
                    function onClicked() {
                      modal.swapAdaptor.sendApproveTx()
                    }
                }
            }
        }
    }

    ScrollView {
        id: rightPanel
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
        SplitView.minimumHeight: 300

        ColumnLayout {
            spacing: 10

            CheckBox {
                id: areTestNetworksEnabledCheckbox
                text: "areTestNetworksEnabled"
                checked: true
                onToggled: networksComboBox.currentIndex = 0
            }

            StatusBaseText {
                text:"Selected Account"
            }
            ComboBox {
                id: accountComboBox
                textRole: "name"
                valueRole: "address"
                model: adaptor.nonWatchAccounts
                currentIndex: 0
            }

            StatusBaseText {
                text: "Selected Network"
            }
            ComboBox {
                id: networksComboBox
                textRole: "chainName"
                valueRole: "chainId"
                model: adaptor.filteredFlatNetworksModel
                currentIndex: 0
                onCountChanged: currentIndex = 0
            }

            StatusBaseText {
                text: "From Token"
            }
            ComboBox {
                id: fromTokenComboBox
                textRole: "name"
                valueRole: "key"
                model: d.tokenBySymbolModel
            }

            StatusInput {
                id: swapInput
                Layout.preferredWidth: 250
                label: "Token amount to swap"
                text: ""
            }

            StatusBaseText {
                text: "To Token"
            }
            ComboBox {
                id: toTokenComboBox
                textRole: "name"
                valueRole: "key"
                model: d.tokenBySymbolModel
                currentIndex: 1
            }

            Button {
                text: "simulate happy path no approval needed"
                onClicked: {
                    d.resetValues()
                    fromTokenComboBox.currentIndex = 0
                    swapInput.text = "0.2"
                    fetchSuggestedRoutesSpy.wait()
                    Backpressure.debounce(this, 250, () => {
                                              dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRouteNoApproval)
                                          })()
                }
            }

            Button {
                text: "simulate happy path with approval needed"
                onClicked: {
                    d.resetValues()
                    accountComboBox.currentIndex = 2
                    fromTokenComboBox.currentIndex = 2
                    swapInput.text = "0.1"
                    fetchSuggestedRoutesSpy.wait()
                    Backpressure.debounce(this, 1000, () => {
                                              dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded)
                                          })()
                    Backpressure.debounce(this, 1500, () => {approveTxButton.clicked()})()
                    authenticateAndTransferSpy.wait()
                    Backpressure.debounce(this, 1000, () => {
                                              dSwapStore.transactionSent(networksComboBox.currentValue, "0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", d.uuid, "")
                                          })()
                    Backpressure.debounce(this, 2000, () => {
                                              dSwapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", true)
                                          })()
                    fetchSuggestedRoutesSpy.wait()
                    Backpressure.debounce(this, 1000, () => {
                                              dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRouteNoApproval)
                                          })()
                }
            }

            Button {
                text: "simulate fetching proposal error"
                onClicked: {
                    d.resetValues()
                    fromTokenComboBox.currentIndex = 0
                    swapInput.text = "0.2"
                    fetchSuggestedRoutesSpy.wait()
                    Backpressure.debounce(this, 250, () => {
                                              dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txNoRoutes)

                    })()
                }
            }

            Button {
                text: "simulate approval failed"
                onClicked: {
                    d.resetValues()
                    accountComboBox.currentIndex = 2
                    fromTokenComboBox.currentIndex = 2
                    swapInput.text = "0.1"
                    fetchSuggestedRoutesSpy.wait()
                    Backpressure.debounce(this, 1000, () => {
                                              dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded)
                                          })()
                    Backpressure.debounce(this, 1500, () => {approveTxButton.clicked()})()
                    authenticateAndTransferSpy.wait()
                    Backpressure.debounce(this, 1000, () => {
                                              dSwapStore.transactionSent(networksComboBox.currentValue, "0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", d.uuid, "")
                                          })()
                    Backpressure.debounce(this, 2000, () => {
                                              dSwapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", false)
                                          })()
                }
            }

            CheckBox {
                id: advancedSignalsCheckBox
                text: "show advanced signals for testing"
                checked: false
            }

            Button {
                text: "emit no routes found event"
                onClicked: {
                    dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txNoRoutes)
                }
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                text: "emit no approval needed route"
                onClicked: {
                    dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRouteNoApproval)
                }
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                text: "emit approval needed route"
                onClicked: {
                    dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded)
                }
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                id: approveTxButton
                text: "call approveTX"
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                text: "emit transactionSent successful"
                onClicked: {
                    dSwapStore.transactionSent(networksComboBox.currentValue, "0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", d.uuid, "")
                }
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                text: "emit transactionSent failure"
                onClicked: {
                    dSwapStore.transactionSent(networksComboBox.currentValue, "", d.uuid, "no password given")
                }
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                text: "emit approval completed successfully"
                onClicked: {
                    dSwapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", true)
                }
                visible: advancedSignalsCheckBox.checked
            }

            Button {
                text: "emit approval completed with failure"
                onClicked: {
                    dSwapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", false)
                }
                visible: advancedSignalsCheckBox.checked
            }
        }
    }
}

// category: Popups
