import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import shared.popups.send.views 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    readonly property var tokensBySymbolModel: TokensBySymbolModel {}

    readonly property double maxCryptoBalance: parseFloat(maxCryptoBalanceText.text)
    readonly property int decimals: parseInt(decimalsText.text)

    Logs { id: logs }

    Component.onCompleted: amountToSendInput.input.forceActiveFocus()

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
                selectedHolding: tokensBySymbolModel.data[0]

                inputIsFiat: fiatInput.checked

                maxInputBalance: inputIsFiat ? root.maxCryptoBalance*amountToSendInput.selectedHolding.marketDetails.currencyPrice.amount
                                             : root.maxCryptoBalance
                currentCurrency: "Fiat"
                formatCurrencyAmount: function(amount, symbol, options, locale) {
                    const currencyAmount = {
                        amount: amount,
                        symbol: symbol,
                        displayDecimals: root.decimals,
                        stripTrailingZeroes: true
                    }
                    return LocaleUtils.currencyAmountToLocaleString(currencyAmount, options, locale)
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
