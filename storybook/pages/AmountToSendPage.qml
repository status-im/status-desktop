import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import shared.popups.send.views 1.0

import Storybook 1.0

SplitView {
    id: root

    readonly property double maxCryptoBalance: parseFloat(maxCryptoBalanceText.text)
    readonly property double rate: parseFloat(rateText.text)
    readonly property int decimals: parseInt(decimalsText.text)

    Logs { id: logs }
    
    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            AmountToSend {
                id: amountToSendInput
                isBridgeTx: false
                interactive: true
                selectedSymbol: "Crypto"

                inputIsFiat: fiatInput.checked

                maxInputBalance: inputIsFiat ? getFiatValue(root.maxCryptoBalance)
                                             : root.maxCryptoBalance
                currentCurrency: "Fiat"
                getFiatValue: function(cryptoValue) {
                    return cryptoValue * root.rate
                }
                getCryptoValue: function(fiatValue) {
                    return fiatValue / root.rate
                }
                formatCurrencyAmount: function(amount, symbol, options = null, locale = null) {
                    const currencyAmount = {
                      amount: amount,
                      symbol: symbol,
                      displayDecimals: root.decimals,
                      stripTrailingZeroes: true
                    }
                    return LocaleUtils.currencyAmountToLocaleString(currencyAmount, options)
                }
                onReCalculateSuggestedRoute: function() {
                    logs.logEvent("onReCalculateSuggestedRoute")
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Max Crypto Balance"
            }

            TextField {
                id: maxCryptoBalanceText
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "1000000"
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Fiat/Crypto rate"
            }

            TextField {
                id: rateText
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "10"
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Decimals"
            }

            TextField {
                id: decimalsText
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "6"
            }

            CheckBox {
                id: fiatInput

                text: "Fiat input value"
            }
        }
    }
}

// category: Components
