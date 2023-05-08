import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import Storybook 1.0
import utils 1.0

import shared.controls 1.0

SplitView {
    id: root

    property QtObject mockupModelData: QtObject {
        property int id: 0
        property var type
        property string address
        property var blockNumber
        property var blockHash
        property int timestamp: Date.now() / 1000
        property var gasPrice
        property var gasLimit
        property var gasUsed
        property var nonce
        property int txStatus: 0
        property var value
        property string from: "0xfB8131c260749c7835a08ccBdb64728De432858E"
        property string to: "0x3fb81384583b3910BB14Cc72582E8e8a56E83ae9"
        property var contract
        property var chainId
        property var maxFeePerGas
        property var maxPriorityFeePerGas
        property var input
        property var txHash
        property var multiTransactionID
        property var isTimeStamp
        property bool isNFT
        property var baseGasFees
        property var totalFees
        property var maxTotalFees
        property var symbol
        property bool loadingTransaction
        property string tokenID: "4981676894159712808201908443964193325271219637660871887967796332739046670337"
        property string nftName: "Happy Meow"
        property string nftImageUrl: Style.png("collectibles/HappyMeow")
    }

    property QtObject mockupRootStore: QtObject {
        function formatCurrencyAmount(value, currency) {
            if (isNaN(amount)) {
                return "N/A"
            }
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.fill: column
                anchors.margins: -1
                border.color: "lightgray"
            }

            ColumnLayout {
                id: column

                anchors.centerIn: parent

                width: 600

                TransactionDelegate {
                    id: delegate
                    Layout.fillWidth: true
                    modelData: root.mockupModelData
                    swapCryptoValue: 0.18
                    swapFiatValue: 340
                    swapSymbol: "SNT"
                    timeStampText: LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000)
                    cryptoValue: 0.1234
                    fiatValue: 123123
                    currentCurrency: "USD"
                    networkName: "Optimism"
                    symbol: "ETH"
                    bridgeNetworkName: "Mainnet"
                    feeFiatValue: 10.34
                    feeCryptoValue: 0.013
                    transactionStatus: TransactionDelegate.Pending
                    transactionType: TransactionDelegate.Send
                    formatCurrencyAmount: function(amount, symbol, options = null, locale = null) {
                        const currencyAmount = {
                            amount: amount,
                            symbol: symbol,
                            displayDecimals: 8,
                            stripTrailingZeroes: true
                        }
                        return LocaleUtils.currencyAmountToLocaleString(currencyAmount, options)
                    }
                }
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            SplitView.fillWidth: true
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            CheckBox {
                text: "Is loading"
                checked: delegate.loading
                onToggled: delegate.loading = checked
            }
            CheckBox {
                text: "Is activity details header"
                readonly property string headerState: "header"
                checked: delegate.state === headerState
                onToggled: delegate.state = checked ? headerState : ""
            }

            CheckBox {
                text: "Is NFT"
                checked: delegate.isNFT
                onToggled: root.mockupModelData.isNFT = checked
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Transaction type:"
            }

            ComboBox {
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "type"
                model: ListModel {
                    ListElement { name: "Sent"; type: TransactionDelegate.Send }
                    ListElement { name: "Receive"; type: TransactionDelegate.Receive }
                    ListElement { name: "Buy"; type: TransactionDelegate.Buy }
                    ListElement { name: "Sell"; type: TransactionDelegate.Sell }
                    ListElement { name: "Destroy"; type: TransactionDelegate.Destroy }
                    ListElement { name: "Swap"; type: TransactionDelegate.Swap }
                    ListElement { name: "Bridge"; type: TransactionDelegate.Bridge }
                }
                onActivated: delegate.transactionType = model.get(currentIndex).type
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Transaction status:"
            }

            ComboBox {
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "type"
                model: ListModel {
                    ListElement { name: "Pending"; status: TransactionDelegate.Pending }
                    ListElement { name: "Failed"; status: TransactionDelegate.Failed }
                    ListElement { name: "Verified"; status: TransactionDelegate.Verified }
                    ListElement { name: "Finished"; status: TransactionDelegate.Finished }
                }
                onActivated: delegate.transactionStatus = model.get(currentIndex).status
            }
        }
    }
}
