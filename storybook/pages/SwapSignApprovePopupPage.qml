import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
        function launchPopup() {
            swapSignApproveModal.createObject(root)
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
            enabled: !swapSignApproveModal.visible

            onClicked: d.launchPopup()
        }

        Component.onCompleted: d.launchPopup()

        Component {
            id: swapSignApproveModal
            SwapSignApprovePopup {
                id: modal
                visible: true
                modal: false
                closePolicy: Popup.CloseOnEscape
                destroyOnClose: true
                title: qsTr("Approve spending cap")
                loading: loadingCheckBox.checked
                swapSignApproveInputForm: SwapSignApproveInputForm {
                    selectedAccountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                    selectedNetworkChainId: 11155111
                    tokensKey: "DAI"
                    estimatedTime: 3
                    swapProviderName: "ParaSwap"
                    approvalGasFees: "2.789231893824e-06"
                    approvalAmountRequired: "10000000000000"
                    approvalContractAddress: "0x216b4b4ba9f3e719726886d34a177484278bfcae"
                }
                adaptor: SwapSignApproveAdaptor {
                    swapStore: SwapStore {
                        readonly property var accounts: WalletAccountsModel {}
                        readonly property var flatNetworks: NetworksModel.flatNetworks
                    }
                    walletAssetsStore: WalletAssetsStore {
                        id: thisWalletAssetStore
                        walletTokensStore: TokensStore {
                            readonly property var plainTokensBySymbolModel: TokensBySymbolModel {}
                            getDisplayAssetsBelowBalanceThresholdDisplayAmount: () => 0
                        }
                        readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                        assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
                    }
                    currencyStore: CurrenciesStore {}
                    inputFormData: modal.swapSignApproveInputForm
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
                id: loadingCheckBox
                text: "loading"
                checked: false
            }
        }
    }
}

// category: Popups
