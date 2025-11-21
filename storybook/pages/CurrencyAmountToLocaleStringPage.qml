import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme

import utils

import Storybook

SplitView {
    id: root

    Logs { id: logs }

    QtObject {
        id: d

        readonly property var currencyAmount: {
            "amount": parseFloat(ctrlAmount.text),
            "symbol": ctrlSymbol.text,
            "displayDecimals": ctrlDisplayDecimals.value,
            "stripTrailingZeroes": ctrlStripTrailingZeroes.checked
        }

        readonly property var options: {
            let ret = {}
            if (ctrlNoSymbolOption.checked) {
                ret.noSymbol = true
            }
            if (ctrlRawAmountOption.checked) {
                ret.rawAmount = true
            }
            if (ctrlMinDecimalsOption.checked) {
                ret.minDecimals = ctrlMinDecimalsOptionValue.value
            }
            if (ctrlRoundingModeOption.checked) {
                ret.roundingMode = ctrlRoundingModeOptionValue.currentValue
            }
            return ret
        }
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.baseColor3

        StatusBaseText {
            id: formattedText
            //anchors.fill: parent
            anchors.centerIn: parent
            text: {
                return LocaleUtils.currencyAmountToLocaleString(d.currencyAmount, d.options)
            }
            font.pixelSize: Theme.fontSize(24)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 400
        SplitView.preferredWidth: 400

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Amount:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlAmount
                    text: "123.456789"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Symbol:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlSymbol
                    text: "ETH"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Display decimals:"
                }
                SpinBox {
                    id: ctrlDisplayDecimals
                    value: 4
                    from: 0
                }
            }
            Switch {
                id: ctrlStripTrailingZeroes
                text: "Strip trailing zeroes"
                checked: false
            }

            Switch {
                id: ctrlNoSymbolOption
                text: "No symbol"
                checked: false
            }

            Switch {
                id: ctrlRawAmountOption
                text: "Raw amount"
                checked: false
            }

            RowLayout {
                Layout.fillWidth: true
                Switch {
                    id: ctrlMinDecimalsOption
                    text: "Min decimals"
                    checked: false
                }
                SpinBox {
                    id: ctrlMinDecimalsOptionValue
                    value: 6
                    from: 0
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Switch {
                    id: ctrlRoundingModeOption
                    text: "Rounding mode"
                    checked: false
                }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlRoundingModeOptionValue
                    textRole: "text"
                    valueRole: "value"
                    model: ListModel {
                        ListElement { text: "Default"; value: LocaleUtils.RoundingMode.Default }
                        ListElement { text: "Up"; value: LocaleUtils.RoundingMode.Up }
                        ListElement { text: "Down"; value: LocaleUtils.RoundingMode.Down }
                    }
                    currentIndex: 0
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Utils
