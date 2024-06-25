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
        readonly property var tokenBySymbolModel: TokensBySymbolModel {}

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
            readonly property var accounts: WalletAccountsModel {}
            readonly property var flatNetworks: NetworksModel.flatNetworks
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
            swapOutputData: SwapOutputData{}
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
