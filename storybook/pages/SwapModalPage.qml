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
    }

    PopupBackground {
        id: popupBg

        property var popupIntance: null

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !swapModal.visible

            onClicked: swapModal.open()
        }

        SwapModal {
            id: swapModal
            visible: true
            swapInputParamsForm: SwapInputParamsForm {
                selectedAccountIndex: accountComboBox.currentIndex
                selectedNetworkChainId: {
                    if (networksComboBox.model.count > 0 && networksComboBox.currentIndex >= 0) {
                        return ModelUtils.get(networksComboBox.model, networksComboBox.currentIndex, "chainId")
                    }
                    return -1
                }
                fromTokensKey: {
                    if (d.tokenBySymbolModel.count > 0) {
                        return ModelUtils.get(d.tokenBySymbolModel, fromTokenComboBox.currentIndex, "key")
                    }
                    return ""
                }
                fromTokenAmount: swapInput.text
                toTokenKey: {
                    if (d.tokenBySymbolModel.count > 0) {
                        return ModelUtils.get(d.tokenBySymbolModel, toTokenComboBox.currentIndex, "key")
                    }
                    return ""
                }
            }
            swapAdaptor: SwapModalAdaptor {
                swapStore: SwapStore {
                    readonly property var accounts: d.accountsModel
                    readonly property var flatNetworks: d.flatNetworksModel
                    readonly property bool areTestNetworksEnabled: areTestNetworksEnabledCheckbox.checked
                }
                walletAssetsStore: WalletAssetsStore {
                    id: thisWalletAssetStore
                    walletTokensStore: TokensStore {
                        readonly property var plainTokensBySymbolModel: TokensBySymbolModel {}
                    }
                    readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                    assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
                }
                currencyStore: CurrenciesStore {}
                swapFormData: swapModal.swapInputParamsForm
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
                onCheckedChanged: networksComboBox.currentIndex = 0
            }

            StatusBaseText {
                text:"Selected Account"
            }
            ComboBox {
                id: accountComboBox
                textRole: "name"
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
                onCurrentIndexChanged: {
                    swapModal.swapInputParamsForm.selectedAccountIndex = currentIndex
                }
            }

            StatusBaseText {
                text: "Selected Network"
            }
            ComboBox {
                id: networksComboBox
                textRole: "chainName"
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
                model: d.tokenBySymbolModel
                currentIndex: 0
            }

            StatusInput {
                id: swapInput
                Layout.preferredWidth: 100
                label:  "Token mount to swap"
                text: "100"
            }

            StatusBaseText {
                text: "To Token"
            }
            ComboBox {
                id: toTokenComboBox
                textRole: "name"
                model: d.tokenBySymbolModel
                currentIndex: 1
            }
        }
    }
}

// category: Popups