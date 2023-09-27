import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls.Validators 0.1

import "../controls"

import utils 1.0

ColumnLayout {
    id: root

    readonly property alias input: topAmountToSendInput
    readonly property bool inputNumberValid: !!input.text && !isNaN(d.parsedInput)

    readonly property int minSendCryptoDecimals:
        !inputIsFiat ? LocaleUtils.fractionalPartLength(d.inputNumber) : 0
    readonly property int minReceiveCryptoDecimals:
        !inputIsFiat ? minSendCryptoDecimals + 1 : 0
    readonly property int minSendFiatDecimals:
        inputIsFiat ? LocaleUtils.fractionalPartLength(d.inputNumber) : 0
    readonly property int minReceiveFiatDecimals:
        inputIsFiat ? minSendFiatDecimals + 1 : 0

    property string selectedSymbol // Crypto asset symbol like ETH
    property string currentCurrency // Fiat currency symbol like USD

    property int multiplierIndex // How divisible the token is, 18 for ETH

    property double maxInputBalance

    property bool isBridgeTx: false
    property bool interactive: false
    property bool inputIsFiat: false

    // Crypto value to send expressed in base units (like wei for ETH),
    // as a string representing integer decimal
    readonly property alias cryptoValueToSend: d.cryptoValueRawToSend

    readonly property alias cryptoValueToSendFloat: d.cryptoValueToSend


    property var getFiatValue: cryptoValue => {}
    property var getCryptoValue: fiatValue => {}

    property var formatCurrencyAmount:
        (amount, symbol, options = null, locale = null) => {}

    signal reCalculateSuggestedRoute()

    QtObject {
        id: d

        property double cryptoValueToSend
        property double fiatValueToSend

        Binding on cryptoValueToSend {
            value: {
                root.selectedSymbol
                return root.inputIsFiat ? root.getCryptoValue(d.fiatValueToSend)
                                        : d.inputNumber
            }
            delayed: true
        }

        Binding on fiatValueToSend {
            value: {
                root.selectedSymbol
                return root.inputIsFiat ? d.inputNumber
                                        : root.getFiatValue(d.cryptoValueToSend)
            }
            delayed: true
        }

        readonly property string cryptoValueRawToSend: {
            if (!root.inputNumberValid)
                return "0"

            return SQUtils.AmountsArithmetic.fromNumber(
                        d.cryptoValueToSend, root.multiplierIndex).toString()
        }

        readonly property string zeroString:
            LocaleUtils.numberToLocaleString(0, 2, LocaleUtils.userInputLocale)

        readonly property double parsedInput:
            LocaleUtils.numberFromLocaleString(topAmountToSendInput.text,
                                               LocaleUtils.userInputLocale)

        readonly property double inputNumber:
            root.inputNumberValid ? d.parsedInput : 0

        readonly property Timer waitTimer: Timer {
            interval: 1000
            onTriggered: reCalculateSuggestedRoute()
        }
    }

    onMaxInputBalanceChanged: {
        input.validate()
    }

    StatusBaseText {
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop

        text: root.isBridgeTx ? qsTr("Amount to bridge")
                              : qsTr("Amount to send")
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.directColor1
    }

    RowLayout {
        id: topItem

        property double topAmountToSend: !inputIsFiat ? d.cryptoValueToSend
                                                      : d.fiatValueToSend
        property string topAmountSymbol: !inputIsFiat ? root.selectedSymbol
                                                      : root.currentCurrency
        Layout.alignment: Qt.AlignLeft

        AmountInputWithCursor {
            id: topAmountToSendInput
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.maximumWidth: 250
            Layout.preferredWidth: !!text ? input.edit.paintedWidth
                                          : textMetrics.advanceWidth
            placeholderText: d.zeroString
            input.edit.color: input.valid ? Theme.palette.directColor1
                                          : Theme.palette.dangerColor1
            input.edit.readOnly: !root.interactive

            validators: [
                StatusFloatValidator {
                    id: floatValidator
                    bottom: 0
                    errorMessage: ""
                    locale: LocaleUtils.userInputLocale
                },
                StatusValidator {
                    errorMessage: ""

                    validate: (text) => {
                        const num = parseFloat(text)

                        if (isNaN(num))
                            return true

                        return num <= root.maxInputBalance
                    }
                }
            ]

            TextMetrics {
                id: textMetrics
                text: topAmountToSendInput.placeholderText
                font: topAmountToSendInput.input.placeholder.font
            }

            Keys.onReleased: {
                const amount = LocaleUtils.numberFromLocaleString(
                                 topAmountToSendInput.text,
                                 LocaleUtils.userInputLocale)
                if (!isNaN(amount))
                    d.waitTimer.restart()
            }
        }
    }
    Item {
        id: bottomItem

        property double bottomAmountToSend: inputIsFiat ? d.cryptoValueToSend
                                                        : d.fiatValueToSend
        property string bottomAmountSymbol: inputIsFiat ? selectedSymbol
                                                        : currentCurrency

        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        Layout.preferredWidth: txtBottom.width
        Layout.preferredHeight: txtBottom.height

        StatusBaseText {
            id: txtBottom
            anchors.top: parent.top
            anchors.left: parent.left
            text: root.formatCurrencyAmount(bottomItem.bottomAmountToSend,
                                            bottomItem.bottomAmountSymbol)
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                topAmountToSendInput.validate()
                if(!!topAmountToSendInput.text) {
                    topAmountToSendInput.text = root.formatCurrencyAmount(
                                bottomItem.bottomAmountToSend,
                                bottomItem.bottomAmountSymbol,
                                { noSymbol: true, rawAmount: true },
                                LocaleUtils.userInputLocale)
                }
                inputIsFiat = !inputIsFiat
                d.waitTimer.restart()
            }
        }
    }
}

