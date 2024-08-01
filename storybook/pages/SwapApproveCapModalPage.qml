import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet 1.0
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
        id: priv

        readonly property var accountsModel: WalletAccountsModel {}
        readonly property var selectedAccount: selectedAccountEntry.item

        readonly property var networksModel: NetworksModel.flatNetworks
        readonly property var selectedNetwork: selectedNetworkEntry.item
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: priv.accountsModel
        key: "address"
        value: ctrlAccount.currentValue
    }

    ModelEntry {
        id: selectedNetworkEntry
        sourceModel: priv.networksModel
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
                SwapApproveCapModal {
                    anchors.centerIn: parent
                    destroyOnClose: true
                    modal: false
                    closePolicy: Popup.NoAutoClose

                    formatBigNumber: (number, symbol, noSymbolOption) => parseFloat(number).toLocaleString(Qt.locale(), 'f', 2)
                                     + (noSymbolOption ? "" : " " + (symbol || Qt.locale().currencySymbol(Locale.CurrencyIsoCode)))

                    fromTokenSymbol: ctrlFromSymbol.text
                    fromTokenAmount: ctrlFromAmount.text
                    fromTokenContractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F"

                    accountName: priv.selectedAccount.name
                    accountAddress: priv.selectedAccount.address
                    accountEmoji: priv.selectedAccount.emoji
                    accountColor: Utils.getColorForId(priv.selectedAccount.colorId)
                    accountBalanceFormatted: formatBigNumber(120.55489)

                    networkShortName: priv.selectedNetwork.shortName
                    networkName: priv.selectedNetwork.chainName
                    networkIconPath: Style.svg(priv.selectedNetwork.iconUrl)
                    networkBlockExplorerUrl: priv.selectedNetwork.blockExplorerURL

                    fiatFees: formatBigNumber("1.542567673454567457567678678678989234")
                    cryptoFees: formatBigNumber("0.001", "ETH")
                    estimatedTime: ctrlEstimatedTime.currentValue

                    loginType: ctrlLoginType.currentIndex

                    feesLoading: ctrlLoading.checked
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
                text: "115.478"
                placeholderText: "From amount"
            }

            Text {
                text: "Selected Account"
            }
            ComboBox {
                id: ctrlAccount
                textRole: "name"
                valueRole: "address"
                model: priv.accountsModel
                currentIndex: 0
            }

            Text {
                text: "Selected Network"
            }
            ComboBox {
                id: ctrlNetwork
                textRole: "chainName"
                valueRole: "chainId"
                model: priv.networksModel
                currentIndex: 2
            }

            Switch {
                id: ctrlLoading
                text: "Fees loading"
            }

            Text {
                text: "Login Type"
            }
            ComboBox {
                id: ctrlLoginType
                model: Constants.authenticationIconByType
            }

            Text {
                text: "Estimated time"
            }
            ComboBox {
                id: ctrlEstimatedTime
                model: [Constants.TransactionEstimatedTime.Unknown,
                    Constants.TransactionEstimatedTime.LessThanOneMin,
                    Constants.TransactionEstimatedTime.LessThanThreeMins,
                    Constants.TransactionEstimatedTime.LessThanFiveMins,
                    Constants.TransactionEstimatedTime.MoreThanFiveMins
                ]
                displayText: WalletUtils.getLabelForEstimatedTxTime(currentValue)
            }
        }
    }
}

// category: Popups

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3517-435657&t=sRX8mAj4irR1bOuT-0
