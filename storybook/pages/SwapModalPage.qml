import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2

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
        readonly property var accountsModel: WalletAccountsModel {}
        readonly property var tokenBySymbolModel: TokensBySymbolModel {}
        readonly property var flatNetworksModel: NetworksModel.flatNetworks
        readonly property var filteredNetworksModel: SortFilterProxyModel {
            sourceModel: d.flatNetworksModel
            filters: ValueFilter { roleName: "isTest"; value: areTestNetworksEnabledCheckbox.checked }
        }
        function launchPopup() {
            swapModal.createObject(root)
        }

        readonly property SwapTransactionRoutes dummySwapTransactionRoutes: SwapTransactionRoutes{}
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
            readonly property var accounts: d.accountsModel
            readonly property var flatNetworks: d.flatNetworksModel
            readonly property bool areTestNetworksEnabled: areTestNetworksEnabledCheckbox.checked

            function fetchSuggestedRoutes(accountFrom, accountTo, amount, tokenFrom, tokenTo,
                                          disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts) {
                console.debug("fetchSuggestedRoutes called >> accountFrom = ",accountFrom, " accountTo =",
                              accountTo, "amount = ",amount, " tokenFrom = ",tokenFrom, " tokenTo = ", tokenTo,
                              " disabledFromChainIDs = ",disabledFromChainIDs, " disabledToChainIDs = ",disabledToChainIDs,
                              " preferredChainIDs = ",preferredChainIDs, " sendType =", sendType, " lockedInAmounts = ",lockedInAmounts)
            }
            function authenticateAndTransfer(uuid, accountFrom, accountTo, tokenFrom,
                                             tokenTo, sendType, tokenName, tokenIsOwnerToken, paths) {
                console.debug("authenticateAndTransfer called >> uuid ", uuid, " accountFrom = ",accountFrom, " accountTo =",
                              accountTo, "tokenFrom = ",tokenFrom, " tokenTo = ",tokenTo, " sendType = ", sendType,
                              " tokenName = ", tokenName, " tokenIsOwnerToken = ", tokenIsOwnerToken, " paths = ", paths)
            }
            function getWei2Eth(wei, decimals) {
                return wei/(10**decimals)
            }
        }

        TokensStore {
            id: tokensStore
            readonly property var plainTokensBySymbolModel: TokensBySymbolModel {}
            getDisplayAssetsBelowBalanceThresholdDisplayAmount: () => 0
        }

        Component {
            id: swapModal
            SwapModal {
                id: modal
                visible: true
                modal: false
                closePolicy: Popup.CloseOnEscape
                destroyOnClose: true
                swapInputParamsForm: SwapInputParamsForm {
                    onSelectedAccountAddressChanged: {
                        if (selectedAccountAddress !== accountComboBox.currentValue)
                            accountComboBox.currentIndex = accountComboBox.indexOfValue(selectedAccountAddress)
                    }
                    fromTokenAmount: swapInput.text
                }
                swapAdaptor: SwapModalAdaptor {
                    swapStore: dSwapStore
                    walletAssetsStore: WalletAssetsStore {
                        id: thisWalletAssetStore
                        walletTokensStore: tokensStore
                        readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                        assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
                    }
                    currencyStore: CurrenciesStore {}
                    swapFormData: modal.swapInputParamsForm
                    swapOutputData: SwapOutputData{}
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
            }
        }
    }

    Pane {
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
                model: SortFilterProxyModel {
                    sourceModel: d.accountsModel
                    filters: ValueFilter {
                        roleName: "walletType"
                        value: Constants.watchWalletType
                        inverted: true
                    }
                    sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
                }
                currentIndex: 0
            }

            StatusBaseText {
                text: "Selected Network"
            }
            ComboBox {
                id: networksComboBox
                textRole: "chainName"
                valueRole: "chainId"
                model: d.filteredNetworksModel
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
                text: "emit no routes found event"
                onClicked: {
                    dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txNoRoutes)
                }
            }

            Button {
                text: "emit no approval needed route"
                onClicked: {
                    dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRouteNoApproval)
                }
            }

            Button {
                text: "emit approval needed route"
                onClicked: {
                    dSwapStore.suggestedRoutesReady(d.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded)
                }
            }
        }
    }
}

// category: Popups
