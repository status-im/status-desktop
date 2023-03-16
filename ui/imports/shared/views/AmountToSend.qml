import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

import "../controls"

import utils 1.0

ColumnLayout {
    id: root

    property alias input: topAmountToSendInput

    property var selectedAsset
    property bool isBridgeTx: false
    property bool interactive: false
    property var maxFiatBalance
    property bool inputIsFiat: false
    property var cryptoValueToSend
    Binding {
        target: root
        property: "cryptoValueToSend"
        value: {
            const value = !inputIsFiat ? getCryptoCurrencyAmount(LocaleUtils.numberFromLocaleString(topAmountToSendInput.text)) : getCryptoValue(fiatValueToSend ? fiatValueToSend.amount : 0.0)
            return root.selectedAsset, value
        }
        delayed: true
    }
    property var fiatValueToSend
    Binding {
        target: root
        property: "fiatValueToSend"
        value: {
            const value = inputIsFiat ? getFiatCurrencyAmount(LocaleUtils.numberFromLocaleString(topAmountToSendInput.text)) : getFiatValue(cryptoValueToSend ? cryptoValueToSend.amount : 0.0)
            return root.selectedAsset, value
        }
        delayed: true
    }
    property string currentCurrency
    property var getFiatValue: function(cryptoValue) {}
    property var getCryptoValue: function(fiatValue) {}
    property var getFiatCurrencyAmount: function(fiatValue) {}
    property var getCryptoCurrencyAmount: function(cryptoValue) {}

    signal reCalculateSuggestedRoute()

    QtObject {
        id: d
        readonly property string zeroString: LocaleUtils.numberToLocaleString(0, 2)
        property Timer waitTimer: Timer {
            interval: 1000
            onTriggered: reCalculateSuggestedRoute()
        }

        function formatValue(value) {
            if (!value) {
                return zeroString
            }
            return LocaleUtils.currencyAmountToLocaleString(value)
        }
    }

    onMaxFiatBalanceChanged: {
        floatValidator.top = maxFiatBalance ? maxFiatBalance.amount : 0.0
        input.validate()
    }

    StatusBaseText {
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        text: root.isBridgeTx ? qsTr("Amount to bridge") : qsTr("Amount to send")
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.directColor1
    }
    RowLayout {
        id: topItem
        property var topAmountToSend: !inputIsFiat ? cryptoValueToSend : fiatValueToSend
        Layout.alignment: Qt.AlignLeft
        AmountInputWithCursor {
            id: topAmountToSendInput
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.maximumWidth: 163
            Layout.preferredWidth: (!!text) ? input.edit.paintedWidth : textMetrics.advanceWidth
            placeholderText: d.zeroString
            input.edit.color: input.valid ? Theme.palette.directColor1 : Theme.palette.dangerColor1
            input.edit.readOnly: !root.interactive
            validators: [
                StatusFloatValidator {
                    id: floatValidator
                    bottom: 0
                    top: root.maxFiatBalance.amount
                    errorMessage: ""
                }
            ]
            TextMetrics {
                id: textMetrics
                text: topAmountToSendInput.placeholderText
                font: topAmountToSendInput.input.placeholder.font
            }
            Keys.onReleased: {
                const amount = topAmountToSendInput.text.trim()
                if (!Utils.containsOnlyDigits(amount) || isNaN(amount)) {
                    return
                }
                d.waitTimer.restart()
            }
        }
    }
    Item {
        id: bottomItem
        property var bottomAmountToSend: inputIsFiat ? cryptoValueToSend : fiatValueToSend
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        Layout.preferredWidth: txtBottom.width
        Layout.preferredHeight: txtBottom.height
        StatusBaseText {
            id: txtBottom
            anchors.top: parent.top
            anchors.left: parent.left
            text: d.formatValue(bottomItem.bottomAmountToSend)
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                topAmountToSendInput.validate()
                if(!!topAmountToSendInput.text) {
                    topAmountToSendInput.text = LocaleUtils.currencyAmountToLocaleString(bottomItem.bottomAmountToSend, {onlyAmount: true})
                }
                inputIsFiat = !inputIsFiat
                d.waitTimer.restart()
            }
        }
    }
}

