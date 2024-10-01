import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.stores 1.0
import shared.stores.send 1.0

import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.controls 1.0

import AppLayouts.Wallet.popups.swap 1.0

import Models 1.0
import Storybook 1.0

import SortFilterProxyModel 0.2

SplitView {
    id: root

    Logs { id: logs }

    ListModel {
        id: plainTokensModel
        ListElement {
            key: "aave"
            name: "Aave"
            symbol: "AAVE"
            image: "https://cryptologos.cc/logos/aave-aave-logo.png"
            communityId: ""
        }
        ListElement {
            key: "usdc"
            name: "USDC"
            symbol: "USDC"
            image: ""
            communityId: ""
        }
        ListElement {
            key: "hst"
            name: "Decision Token"
            symbol: "HST"
            image: "https://etherscan.io/token/images/horizonstate2_28.png"
            communityId: ""
        }
    }

    QtObject {
        id: d

        readonly property SwapInputParamsForm swapInputParamsForm: SwapInputParamsForm {
            selectedAccountAddress: ctrlAccount.currentValue ?? ""
            selectedNetworkChainId: ctrlSelectedNetworkChainId.currentValue ?? -1
            fromTokensKey: ctrlFromTokensKey.text
            fromTokenAmount: ctrlFromTokenAmount.text
            toTokenKey: ctrlToTokenKey.text
            toTokenAmount: ctrlToTokenAmount.text
            defaultToTokenKey: "STT"
        }

        readonly property SwapModalAdaptor adaptor: SwapModalAdaptor {
            swapStore: SwapStore {
                readonly property var accounts: WalletAccountsModel {}
                readonly property var flatNetworks: NetworksModel.flatNetworks
                readonly property bool areTestNetworksEnabled: true
                signal suggestedRoutesReady(var txRoutes, string errCode, string errDescription)
                signal transactionSent(var chainId, var txHash, var uuid, var error)
                signal transactionSendingComplete(var txHash, var status)
            }
            walletAssetsStore: WalletAssetsStore {
                id: thisWalletAssetStore
                walletTokensStore: TokensStore {
                    plainTokensBySymbolModel: TokensBySymbolModel {}
                }
                readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
            }
            currencyStore: CurrenciesStore {}
            swapFormData: d.swapInputParamsForm
            swapOutputData: SwapOutputData {}
        }
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.baseColor3

        Item {
            width: 492
            height: payPanel.height + receivePanel.height + 4
            anchors.centerIn: parent

            SwapInputPanel {
                id: payPanel
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                currencyStore: d.adaptor.currencyStore
                flatNetworksModel: d.adaptor.swapStore.flatNetworks
                processedAssetsModel: d.adaptor.walletAssetsStore.groupedAccountAssetsModel
                plainTokensBySymbolModel: plainTokensModel

                selectedNetworkChainId: d.swapInputParamsForm.selectedNetworkChainId
                selectedAccountAddress: d.swapInputParamsForm.selectedAccountAddress
                nonInteractiveTokensKey: receivePanel.selectedHoldingId

                tokenKey: d.swapInputParamsForm.fromTokensKey
                tokenAmount: d.swapInputParamsForm.fromTokenAmount

                swapSide: SwapInputPanel.SwapSide.Pay
                fiatInputInteractive: ctrlFiatInputInteractive.checked
                swapExchangeButtonWidth: swapButton.width
                mainInputLoading: ctrlMainInputLoading.checked
                bottomTextLoading: ctrlBottomTextLoading.checked
            }

            SwapInputPanel {
                id: receivePanel
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                currencyStore: d.adaptor.currencyStore
                flatNetworksModel: d.adaptor.swapStore.flatNetworks
                processedAssetsModel: d.adaptor.walletAssetsStore.groupedAccountAssetsModel
                plainTokensBySymbolModel: plainTokensModel

                selectedNetworkChainId: d.swapInputParamsForm.selectedNetworkChainId
                selectedAccountAddress: d.swapInputParamsForm.selectedAccountAddress
                nonInteractiveTokensKey: payPanel.selectedHoldingId

                tokenKey: d.swapInputParamsForm.toTokenKey
                tokenAmount: d.swapInputParamsForm.toTokenAmount

                swapSide: SwapInputPanel.SwapSide.Receive
                fiatInputInteractive: ctrlFiatInputInteractive.checked
                swapExchangeButtonWidth: swapButton.width
                mainInputLoading: ctrlMainInputLoading.checked
                bottomTextLoading: ctrlBottomTextLoading.checked
            }

            SwapExchangeButton {
                id: swapButton
                anchors.centerIn: parent
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 250
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Chain:"
                }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlSelectedNetworkChainId
                    model: d.adaptor.swapStore.flatNetworks
                    textRole: "chainName"
                    valueRole: "chainId"
                    displayText: currentIndex === -1 ? "All chains" : currentText
                    currentIndex: -1 // all chains
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Account:" }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlAccount
                    textRole: "name"
                    valueRole: "address"
                    displayText: currentText || "All accounts"
                    model: SortFilterProxyModel {
                        sourceModel: d.adaptor.swapStore.accounts
                        sorters: RoleSorter { roleName: "position" }
                    }
                    currentIndex: -1
                }
            }


            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Pay symbol:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlFromTokensKey
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Pay amount:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlFromTokenAmount
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Receive symbol:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlToTokenKey
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Receive amount:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlToTokenAmount
                }
            }
            Switch {
                id: ctrlFiatInputInteractive
                text: "Fiat input interactive"
                checked: false
            }
            Switch {
                id: ctrlMainInputLoading
                text: "mainInputLoading"
            }
            Switch {
                id: ctrlBottomTextLoading
                text: "bottomTextLoading"
            }

            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "<b>Pay:</b><ul><li>Symbol: %1<li>Amount: %2<li>Valid: %3"
                  .arg(payPanel.selectedHoldingId || "N/A")
                  .arg(payPanel.value.toString())
                  .arg(payPanel.valueValid ? "true" : "false")
            }
            Label {
                Layout.fillWidth: true
                font.weight: Font.Medium
                text: "<b>Receive:</b><ul><li>Symbol: %1<li>Amount: %2<li>Valid: %3"
                  .arg(receivePanel.selectedHoldingId || "N/A")
                  .arg(receivePanel.value.toString())
                  .arg(receivePanel.valueValid ? "true" : "false")
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Panels

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3404-111405&t=G96tBLQr2j73HT9X-0
