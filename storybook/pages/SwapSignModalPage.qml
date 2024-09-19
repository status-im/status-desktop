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
                SwapSignModal {
                    anchors.centerIn: parent
                    destroyOnClose: true
                    modal: false

                    formatBigNumber: (number, symbol, noSymbolOption) => parseFloat(number).toLocaleString(Qt.locale(), 'f', 2)
                                     + (noSymbolOption ? "" : " " + (symbol || Qt.locale().currencySymbol(Locale.CurrencyIsoCode)))

                    fromTokenSymbol: ctrlFromSymbol.text
                    fromTokenAmount: ctrlFromAmount.text
                    fromTokenContractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F"

                    toTokenSymbol: ctrlToSymbol.text
                    toTokenAmount: ctrltoAmount.text
                    toTokenContractAddress: "0xdAC17F958D2ee523a2206206994597C13D831ec7"

                    accountName: priv.selectedAccount.name
                    accountAddress: priv.selectedAccount.address
                    accountEmoji: priv.selectedAccount.emoji
                    accountColor: Utils.getColorForId(priv.selectedAccount.colorId)

                    networkShortName: priv.selectedNetwork.shortName
                    networkName: priv.selectedNetwork.chainName
                    networkIconPath: Style.svg(priv.selectedNetwork.iconUrl)
                    networkBlockExplorerUrl: priv.selectedNetwork.blockExplorerURL

                    serviceProviderName: Constants.swap.paraswapName
                    serviceProviderURL: Constants.swap.paraswapUrl
                    serviceProviderTandCUrl: Constants.swap.paraswapTermsAndConditionUrl

                    fiatFees: formatBigNumber(42.542567, "EUR")
                    cryptoFees: formatBigNumber(0.06, "ETH")
                    slippage: 0.5

                    loginType: ctrlLoginType.currentIndex

                    feesLoading: ctrlLoading.checked

                    expirationSeconds: !!ctrlExpiration.text && parseInt(ctrlExpiration.text) ? parseInt(ctrlExpiration.text) : 0
                    onExpirationSecondsChanged: requestTimestamp = new Date()

                    onAccepted: logs.logEvent("accepted")
                    onRejected: logs.logEvent("rejected")
                    onClosed: logs.logEvent("closed")
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
                currentIndex: 0
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

            TextField {
                id: ctrlExpiration
                placeholderText: "Expiration in seconds"
            }
        }
    }
}

// category: Popups

// https://www.figma.com/design/TS0eQX9dAZXqZtELiwKIoK/Swap---Milestone-1?node-id=3542-497191&t=ndwmuh3ZXlycGYWa-0
