import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.popups.swap 1.0

import utils 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    property var dialog

    function createAndOpenDialog() {
        dialog = dlgComponent.createObject(popupBg)
        dialog.open()
    }

    Component.onCompleted: createAndOpenDialog()

    QtObject {
        id: d

        readonly property var accountsModel: WalletAccountsModel {}
        readonly property var selectedAccount: selectedAccountEntry.item

        readonly property var networksModel: NetworksModel.flatNetworks
        readonly property var selectedNetwork: selectedNetworkEntry.item
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: d.accountsModel
        key: "address"
        value: ctrlAccount.currentValue
    }

    ModelEntry {
        id: selectedNetworkEntry
        sourceModel: d.networksModel
        key: "chainId"
        value: ctrlNetwork.currentValue
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: createAndOpenDialog()
            }

            Component {
                id: dlgComponent
                SwapSignModal {
                    anchors.centerIn: parent
                    destroyOnClose: true
                    modal: false
                    closePolicy: Popup.NoAutoClose

                    fromTokenSymbol: ctrlFromSymbol.text
                    fromTokenAmount: ctrlFromAmount.text
                    fromTokenContractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F"

                    toTokenSymbol: ctrlToSymbol.text
                    toTokenAmount: ctrltoAmount.text
                    toTokenContractAddress: "0xdAC17F958D2ee523a2206206994597C13D831ec7"

                    accountName: d.selectedAccount.name
                    accountAddress: d.selectedAccount.address
                    accountEmoji: d.selectedAccount.emoji
                    accountColorId: d.selectedAccount.colorId

                    networkShortName: d.selectedNetwork.shortName
                    networkName: d.selectedNetwork.chainName
                    networkIconPath: Style.svg(d.selectedNetwork.iconUrl)
                    networkBlockExplorerUrl: d.selectedNetwork.blockExplorerUrl

                    currentCurrency: "EUR"
                    fiatFees: "1.54"
                    cryptoFees: "0.001"
                    slippage: 0.5

                    loginType: ctrlLoginType.currentIndex

                    loading: ctrlLoading.checked
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 250
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            Layout.fillWidth: true
            TextField {
                Layout.fillWidth: true
                id: ctrlFromSymbol
                text: "DAI"
                placeholderText: "From symbol"
            }
            TextField {
                Layout.fillWidth: true
                id: ctrlFromAmount
                text: "100"
                placeholderText: "From amount"
            }
            TextField {
                Layout.fillWidth: true
                id: ctrlToSymbol
                text: "USDT"
                placeholderText: "To symbol"
            }
            TextField {
                Layout.fillWidth: true
                id: ctrltoAmount
                text: "100"
                placeholderText: "To amount"
            }

            Text {
                text: "Selected Account"
            }
            ComboBox {
                id: ctrlAccount
                textRole: "name"
                valueRole: "address"
                model: d.accountsModel
                currentIndex: 0
            }

            Text {
                text: "Selected Network"
            }
            ComboBox {
                id: ctrlNetwork
                textRole: "chainName"
                valueRole: "chainId"
                model: d.networksModel
                currentIndex: 0
            }

            Switch {
                id: ctrlLoading
                text: "Loading"
            }

            Text {
                text: "Login Type"
            }
            ComboBox {
                id: ctrlLoginType
                model: Constants.authenticationIconByType
            }
        }
    }
}

// category: Popups

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3542-497191&t=ndwmuh3ZXlycGYWa-0
