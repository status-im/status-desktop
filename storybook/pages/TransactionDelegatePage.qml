import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import Storybook 1.0
import utils 1.0

import shared.controls 1.0

SplitView {
    id: root

    readonly property QtObject mockupModelData: QtObject {
        property int timestamp: Date.now() / 1000
        property int txStatus: 0
        property string from: "0xfB8131c260749c7835a08ccBdb64728De432858E"
        property string to: "0x3fb81384583b3910BB14Cc72582E8e8a56E83ae9"
        property bool isNFT: false
        property string tokenID: "4981676894159712808201908443964193325271219637660871887967796332739046670337"
        property string nftName: "Happy Meow"
        property string nftImageUrl: Style.png("collectibles/HappyMeow")
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
                    transactionStatus: Constants.TransactionStatus.Pending
                    transactionType: Constants.TransactionType.Send
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
                    ListElement { name: "Sent"; type: Constants.TransactionType.Send }
                    ListElement { name: "Receive"; type: Constants.TransactionType.Receive }
                    ListElement { name: "Buy"; type: Constants.TransactionType.Buy }
                    ListElement { name: "Sell"; type: Constants.TransactionType.Sell }
                    ListElement { name: "Destroy"; type: Constants.TransactionType.Destroy }
                    ListElement { name: "Swap"; type: Constants.TransactionType.Swap }
                    ListElement { name: "Bridge"; type: Constants.TransactionType.Bridge }
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
                    ListElement { name: "Pending"; status: Constants.TransactionStatus.Pending }
                    ListElement { name: "Failed"; status: Constants.TransactionStatus.Failed }
                    ListElement { name: "Complete"; status: Constants.TransactionStatus.Complete }
                    ListElement { name: "Finished"; status: Constants.TransactionStatus.Finished }
                }
                onActivated: delegate.transactionStatus = model.get(currentIndex).status
            }
        }
    }
}
