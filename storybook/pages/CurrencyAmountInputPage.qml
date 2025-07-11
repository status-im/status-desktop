import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import utils

import shared.controls

SplitView {
    id: root

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        CurrencyAmountInput {
            id: input
            anchors.centerIn: parent
            currencySymbol: ctrlCurrencySymbol.text
            decimals: ctrlDecimals.value
            readOnly: ctrlReadOnly.checked
            enabled: ctrlEnabled.checked
            value: ctrlAmount.text
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400

        SplitView.fillHeight: true

        ColumnLayout {
            Layout.fillWidth: true
            RowLayout {
                Label {
                    text: "Value:\t"
                }
                TextField {
                    id: ctrlAmount
                    text: "0.10"
                    placeholderText: "Numeric value"
                    onEditingFinished: input.value = text
                }
            }
            RowLayout {
                Label {
                    text: "Currency:\t"
                }
                TextField {
                    id: ctrlCurrencySymbol
                    text: "EUR"
                    placeholderText: "Currency symbol"
                }
            }
            RowLayout {
                Label {
                    text: "Decimals:\t"
                }
                SpinBox {
                    id: ctrlDecimals
                    from: 0
                    to: 18
                    value: 2
                }
            }
            Switch {
                id: ctrlReadOnly
                text: "Read only"
            }
            Switch {
                id: ctrlEnabled
                text: "Enabled"
                checked: true
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                Label {
                    text: "Numeric value:"
                }
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    font.bold: true
                    text: input.asString
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Valid:"
                }
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    font.bold: true
                    text: input.valid ? "true" : "false"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Formatted as locale string:"
                }
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    font.bold: true
                    text: input.asLocaleString
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Locale:"
                }
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    font.bold: true
                    text: input.locale
                }
            }
        }
    }
}

// category: Controls

// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=305-139866&mode=design&t=g49O9LFh8PkuPxZB-0
