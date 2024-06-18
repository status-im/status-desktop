import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.adaptors 1.0

import shared.stores 1.0
import utils 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: d

        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property var currencyStore: CurrenciesStore {}
        readonly property var assetsStore: WalletAssetsStore {
            id: thisWalletAssetStore
            walletTokensStore: TokensStore {
                plainTokensBySymbolModel: TokensBySymbolModel {}
            }
            readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
            assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
        }

        readonly property var walletAccountsModel: WalletAccountsModel {}

        readonly property var adaptor: TokenSelectorViewAdaptor {
            assetsModel: d.assetsStore.groupedAccountAssetsModel
            flatNetworksModel: d.flatNetworks
            currentCurrency: d.currencyStore.currentCurrency

            enabledChainIds: ctrlNetwork.currentValue ? [ctrlNetwork.currentValue] : []
            accountAddress: ctrlAccount.currentValue ?? ""
            showCommunityAssets: ctrlShowCommunityAssets.checked
            searchString: tokenSelector.searchString
        }
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor3
        }

        TokenSelector {
            id: tokenSelector
            anchors.centerIn: parent

            nonInteractiveDelegateKey: ctrlNonInteractiveDelegateKey.text

            model: d.adaptor.outputAssetsModel
            onTokenSelected: (tokensKey) => {
                                 console.warn("!!! TOKEN SELECTED:", tokensKey)
                                 logs.logEvent("TokenSelector::onTokenSelected", ["tokensKey"], arguments)
                             }
            onActivated: ctrlSelectedAsset.currentIndex = ctrlSelectedAsset.indexOfValue(currentTokensKey)
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 320
        SplitView.preferredHeight: 320

        logsView.logText: logs.logText

        RowLayout {
            anchors.fill: parent

            ColumnLayout {
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Selected asset:" }
                    ComboBox {
                        Layout.fillWidth: true
                        id: ctrlSelectedAsset
                        model: d.assetsStore.groupedAccountAssetsModel
                        textRole: "name"
                        valueRole: "tokensKey"
                        displayText: currentText || "N/A"
                        onActivated: tokenSelector.selectToken(currentValue)
                    }
                    TextField {
                        id: ctrlNonInteractiveDelegateKey
                        placeholderText: "Non interactive delegate token key"
                    }
                }

                Button {
                    text: "Reset"
                    onClicked: {
                        tokenSelector.reset()
                        ctrlSelectedAsset.currentIndex = -1
                        ctrlNonInteractiveDelegateKey.clear()
                    }
                }

                Switch {
                    id: ctrlShowCommunityAssets
                    text: "Show community assets"
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Network:" }
                    ComboBox {
                        Layout.fillWidth: true
                        id: ctrlNetwork
                        textRole: "chainName"
                        valueRole: "chainId"
                        displayText: currentText || "All networks"
                        model: d.flatNetworks
                        currentIndex: -1
                    }
                }
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: "Selected: %1".arg(ctrlNetwork.currentValue ? ctrlNetwork.currentValue.toString() : "All")
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
                            sourceModel: d.walletAccountsModel
                            sorters: RoleSorter { roleName: "position" }
                        }
                        currentIndex: -1
                    }
                }
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: "Selected: %1".arg(ctrlAccount.currentValue ?? "all")
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}

// category: Controls

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3406-231273&t=Ncl9lN1umbGEMxOn-0
