import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2
import QtTest 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import Storybook 1.0
import Models 1.0

import mainui 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Chat.popups 1.0
import AppLayouts.stores 1.0 as AppLayoutStores
import shared.stores 1.0 as SharedStores

// TODO_ES remove unneeded imports

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

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
        readonly property var tokenBySymbolModel: TokensBySymbolModel {}

        function launchPopup() {
            requestPaymentModalComponent.createObject(root)
        }

        readonly property var accounts: WalletAccountsModel {}
        readonly property SharedStores.CurrenciesStore currencyStore: SharedStores.CurrenciesStore {}
        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property var walletAssetsStore: WalletStores.WalletAssetsStore {
            id: thisWalletAssetStore
            walletTokensStore: WalletStores.TokensStore {
                plainTokensBySymbolModel: TokensBySymbolModel {}
            }
            readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
            assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
        }

        readonly property string selectedAccountAddress: ctrlAccount.currentValue ?? ""
        readonly property int selectedNetworkChainId: ctrlSelectedNetworkChainId.currentValue ?? -1

        readonly property SharedStores.RequestPaymentStore requestPaymentStore: SharedStores.RequestPaymentStore {
            currencyStore: d.currencyStore
            flatNetworksModel: d.flatNetworks
            processedAssetsModel: d.walletAssetsStore.renamedTokensBySymbolModel
            accountsModel: d.accounts
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
            enabled: !requestPaymentModalComponent.visible

            onClicked: d.launchPopup()
        }

        Component.onCompleted: d.launchPopup()

        Component {
            id: requestPaymentModalComponent
            RequestPaymentModal {
                id: requestPaymentModal
                visible: true
                modal: false
                closePolicy: Popup.CloseOnEscape
                destroyOnClose: true

                store: d.requestPaymentStore

                Connections {
                    target: d
                    function onSelectedNetworkChainIdChanged() {
                        requestPaymentModal.selectedNetworkChainId = d.selectedNetworkChainId
                    }
                    function onSelectedAccountAddressChanged() {
                        requestPaymentModal.selectedAccountAddress = d.selectedAccountAddress
                    }
                }
                Component.onCompleted: {
                    if (d.selectedNetworkChainId > -1)
                        requestPaymentModal.selectedNetworkChainId = d.selectedNetworkChainId
                    if (!!d.selectedAccountAddress)
                        requestPaymentModal.selectedAccountAddress = d.selectedAccountAddress
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
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            spacing: 10

            Label {
                text: "pre-selection:"
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Chain:"
                }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlSelectedNetworkChainId
                    model: d.flatNetworks
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
                    displayText: currentText || "----"
                    model: SortFilterProxyModel {
                        sourceModel: d.accounts
                        sorters: RoleSorter { roleName: "position" }
                    }
                    currentIndex: -1
                }
            }
        }
    }
}

// category: Popups
