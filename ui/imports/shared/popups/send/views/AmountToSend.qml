import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Controls.Validators 0.1

import "../controls"

import utils 1.0

ColumnLayout {
    id: root

    readonly property alias input: topAmountToSendInput
    readonly property bool inputNumberValid: !!input.text && !isNaN(d.parsedInput) && input.valid

    readonly property int minSendCryptoDecimals:
        !inputIsFiat ? LocaleUtils.fractionalPartLength(d.inputNumber) : 0
    readonly property int minReceiveCryptoDecimals:
        !inputIsFiat ? minSendCryptoDecimals + 1 : 0
    readonly property int minSendFiatDecimals:
        inputIsFiat ? LocaleUtils.fractionalPartLength(d.inputNumber) : 0
    readonly property int minReceiveFiatDecimals:
        inputIsFiat ? minSendFiatDecimals + 1 : 0

    property var selectedHolding // Crypto asset symbol like ETH
    property string currentCurrency // Fiat currency symbol like USD

    property int multiplierIndex // How divisible the token is, 18 for ETH

    property double maxInputBalance

    property bool isBridgeTx: false
    property bool interactive: false
    property bool inputIsFiat: false

    property string caption: isBridgeTx ? qsTr("Amount to bridge") : qsTr("Amount to send")

    property bool fiatInputInteractive: true

    // Crypto value to send expressed in base units (like wei for ETH),
    // as a string representing integer decimal
    readonly property alias cryptoValueToSend: d.cryptoValueRawToSend

    readonly property alias cryptoValueToSendFloat: d.cryptoValueToSend

    property var formatCurrencyAmount:
        (amount, symbol, options = null, locale = null) => {}

    property bool loading

    signal reCalculateSuggestedRoute()

    QtObject {
        id: d

        property double cryptoValueToSend
        property double fiatValueToSend

        Binding on cryptoValueToSend {
            value: {
                root.selectedHolding
                if(!root.selectedHolding || !root.selectedHolding.marketDetails || !root.selectedHolding.marketDetails.currencyPrice) {
                    return 0
                }
                return root.inputIsFiat ? d.fiatValueToSend/root.selectedHolding.marketDetails.currencyPrice.amount
                                        : d.inputNumber
            }
            delayed: true
        }

        Binding on fiatValueToSend {
            value: {
                root.selectedHolding
                if(!root.selectedHolding || !root.selectedHolding.marketDetails || !root.selectedHolding.marketDetails.currencyPrice) {
                    return 0
                }
                return root.inputIsFiat ? d.inputNumber
                                        : d.cryptoValueToSend * root.selectedHolding.marketDetails.currencyPrice.amount
            }
            delayed: true
        }

        readonly property string selectedSymbol: !!root.selectedHolding && !!root.selectedHolding.symbol ? root.selectedHolding.symbol: ""

        readonly property string cryptoValueRawToSend: {
            if (!root.inputNumberValid)
                return "0"

            return SQUtils.AmountsArithmetic.fromNumber(
                        d.cryptoValueToSend, root.multiplierIndex).toString()
        }

        readonly property string zeroString:
            LocaleUtils.numberToLocaleString(0, 2, topAmountToSendInput.locale)

        readonly property double parsedInput:
            LocaleUtils.numberFromLocaleString(topAmountToSendInput.text,
                                               topAmountToSendInput.locale)

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
        text: root.caption
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.directColor1
    }

    RowLayout {
        Layout.fillWidth: true
        id: topItem

        property double topAmountToSend: !inputIsFiat ? d.cryptoValueToSend
                                                      : d.fiatValueToSend
        property string topAmountSymbol: !inputIsFiat ? d.selectedSymbol
                                                      : root.currentCurrency
        AmountInputWithCursor {
            id: topAmountToSendInput
            Layout.fillWidth: true
            Layout.maximumWidth: 250
            Layout.preferredWidth: !!text ? input.edit.paintedWidth + 2
                                          : textMetrics.advanceWidth
            placeholderText: d.zeroString
            input.edit.color: input.valid ? Theme.palette.directColor1
                                          : Theme.palette.dangerColor1
            input.edit.readOnly: !root.interactive
            validationMode: StatusInput.ValidationMode.Always
            validators: [
                StatusValidator {
                    errorMessage: ""

                    validate: (text) => {
                                  var num = 0
                                  try {
                                      num = Number.fromLocaleString(topAmountToSendInput.locale, text)
                                  } catch (e) {
                                      console.warn(e, "(Error parsing number from text: %1)".arg(text))
                                      return false
                                  }

                                  return num > 0 && num <= root.maxInputBalance
                              }
                }
            ]

            TextMetrics {
                id: textMetrics
                text: topAmountToSendInput.placeholderText
                font: topAmountToSendInput.placeholderFont
            }

            Keys.onReleased: {
                const amount = LocaleUtils.numberFromLocaleString(
                                 topAmountToSendInput.text,
                                 locale)
                if (!isNaN(amount))
                    d.waitTimer.restart()
            }

            visible: !root.loading
        }
        LoadingComponent {
            objectName: "topAmountToSendInputLoadingComponent"
            Layout.preferredWidth: topAmountToSendInput.width
            Layout.preferredHeight: topAmountToSendInput.height
            visible: root.loading
        }
    }

    StatusBaseText {
        Layout.maximumWidth: parent.width
        id: bottomItem
        objectName: "bottomItemText"

        readonly property double bottomAmountToSend: inputIsFiat ? d.cryptoValueToSend
                                                                 : d.fiatValueToSend
        readonly property string bottomAmountSymbol: inputIsFiat ? d.selectedSymbol
                                                                 : root.currentCurrency
        elide: Text.ElideMiddle
        text: root.formatCurrencyAmount(bottomAmountToSend, bottomAmountSymbol)
        font.pixelSize: 13
        color: Theme.palette.directColor5

        MouseArea {
            anchors.fill: parent
            cursorShape: enabled ? Qt.PointingHandCursor : undefined
            enabled: root.fiatInputInteractive && !!root.selectedHolding

            onClicked: {
                topAmountToSendInput.validate()
                if(!!topAmountToSendInput.text) {
                    topAmountToSendInput.text = root.formatCurrencyAmount(
                                bottomItem.bottomAmountToSend,
                                bottomItem.bottomAmountSymbol,
                                { noSymbol: true, rawAmount: true },
                                topAmountToSendInput.locale)
                }
                root.inputIsFiat = !root.inputIsFiat
                d.waitTimer.restart()
            }
        }
        visible: !root.loading
    }

    LoadingComponent {
        objectName: "bottomItemTextLoadingComponent"
        Layout.preferredWidth: bottomItem.width
        Layout.preferredHeight: bottomItem.height
        visible: root.loading
    }
}
