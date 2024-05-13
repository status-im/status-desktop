import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import utils 1.0
import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.popups.swap 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    QtObject {
        id: d
        readonly property var tokenBySymbolModel: TokensBySymbolModel {}
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
            formData: SwapFormData {
                selectedAccountIndex: accountComboBox.currentIndex
                selectedNetworkChainId: {
                    if (NetworksModel.flatNetworks.count > 0) {
                        return ModelUtils.get(NetworksModel.flatNetworks, networksComboBox.currentIndex).chainId
                    }
                    return -1
                }
                fromTokensKey: {
                    if (d.tokenBySymbolModel.count > 0) {
                        return ModelUtils.get(d.tokenBySymbolModel, fromTokenComboBox.currentIndex).key
                    }
                    return ""
                }
                fromTokenAmount: swapInput.text
                toTokenKey: {
                    if (d.tokenBySymbolModel.count > 0) {
                        return ModelUtils.get(d.tokenBySymbolModel, toTokenComboBox.currentIndex).key
                    }
                    return ""
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

            StatusBaseText {
                text:"Selected Account"
            }
            ComboBox {
                id: accountComboBox
                textRole: "name"
                model: WalletSendAccountsModel {}
                currentIndex: 0
            }

            StatusBaseText {
                text: "Selected Network"
            }
            ComboBox {
                id: networksComboBox
                textRole: "chainName"
                model: NetworksModel.flatNetworks
                currentIndex: 0
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
