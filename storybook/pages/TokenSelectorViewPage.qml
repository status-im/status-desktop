import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.views 1.0
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

        property var enabledChainIds: []
        function addFilter(chainId) {
            if (d.enabledChainIds.includes(chainId))
                return
            const newFilters = d.enabledChainIds.concat(chainId)
            d.enabledChainIds = newFilters
        }
        function removeFilter(chainId) {
            const newFilters = d.enabledChainIds.filter((filter) => filter !== chainId)
            d.enabledChainIds = newFilters
        }
        function rebuildFilter() {
            let newFilters = []
            for (let i = 0; i < chainIdsRepeater.count; i++) {
                const item = chainIdsRepeater.itemAt(i)
                if (!!item && item.checked) {
                    newFilters.push(item.chainId)
                }
            }
            d.enabledChainIds = newFilters
        }

        readonly property string enabledChainIdsString: enabledChainIds.join(":")

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
            enabledChainIds: d.enabledChainIds
            currentCurrency: d.currencyStore.currentCurrency

            accountAddress: ctrlAccount.currentValue ?? ""
            showCommunityAssets: ctrlShowCommunityAssets.checked
            searchString: ctrlSearch.text
        }
    }

    Component.onCompleted: d.rebuildFilter()

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor3
        }

        Rectangle {
            width: 380
            height: 200
            color: Theme.palette.statusListItem.backgroundColor
            border.color: Theme.palette.primaryColor1
            border.width: 1
            anchors.centerIn: parent

            // tokensKey, name, symbol, decimals, currentCurrencyBalance (computed), marketDetails, balances -> [ chainId, address, balance, iconUrl ]
            TokenSelectorView {
                anchors.fill: parent

                model: d.adaptor.outputAssetsModel

                onTokenSelected: (tokensKey) => {
                                     console.warn("!!! TOKEN SELECTED:", tokensKey)
                                     logs.logEvent("TokenSelectorView::onTokenSelected", ["tokensKey"], arguments)
                                 }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 400
        SplitView.preferredHeight: 400

        logsView.logText: logs.logText

        RowLayout {
            anchors.fill: parent

            ColumnLayout {
                CheckBox {
                    id: ctrlTestNetworks
                    text: "Test networks enabled"
                    tristate: true
                    checkState: Qt.PartiallyChecked
                    onClicked: d.rebuildFilter()
                }

                Repeater {
                    id: chainIdsRepeater
                    model: SortFilterProxyModel {
                        sourceModel: d.flatNetworks
                        filters: ValueFilter {
                            roleName: "isTest"
                            value: ctrlTestNetworks.checked
                            enabled: ctrlTestNetworks.checkState !== Qt.PartiallyChecked
                        }
                    }
                    delegate: CheckBox {
                        required property int chainId
                        required property string chainName
                        required property string shortName
                        required property bool isEnabled
                        checked: isEnabled
                        opacity: enabled ? 1 : 0.3
                        text: "%1 (%2) - %3".arg(chainName).arg(shortName).arg(chainId)
                        onToggled: {
                            if (checked)
                                d.addFilter(chainId)
                            else
                                d.removeFilter(chainId)
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: "Enabled chain ids: %1".arg(d.enabledChainIdsString)
                }
            }

            ColumnLayout {
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Search:" }
                    TextField {
                        Layout.fillWidth: true
                        id: ctrlSearch
                        placeholderText: "Token name or symbol"
                    }
                }
                Switch {
                    id: ctrlShowCommunityAssets
                    text: "Show community assets"
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Account:" }
                    ComboBox {
                        Layout.fillWidth: true
                        id: ctrlAccount
                        textRole: "name"
                        valueRole: "address"
                        displayText: currentIndex === -1 ? "All accounts" : currentText
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

// category: Views
