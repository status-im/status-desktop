import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import utils

Input {
    id: root

    property var locale: LocaleUtils.userInputLocale

    readonly property alias amount: d.amount
    property alias multiplierIndex: d.multiplierIndex

    readonly property bool valid: validationError.length === 0
    property bool allowDecimals: true
    property int tokenDecimals: 0

    property bool validateMaximumAmount: false
    property string maximumAmount: "0"
    property bool allowZero: true

    property alias labelText: labelText.text

    property string maximumExceededErrorText: qsTr("Amount exceeds balance")

    validationErrorTopMargin: 8
    fontPixelSize: 13
    customHeight: 36
    placeholderText: locale.zeroDigit

    textField.rightPadding: labelText.implicitWidth + labelText.anchors.rightMargin
                            + textField.leftPadding

    function setAmount(amount, multiplierIndex = 0) {
        console.assert(typeof amount === "string")

        d.multiplierIndex = multiplierIndex
        const amountNumber = SQUtils.AmountsArithmetic.toNumber(
                               amount, multiplierIndex)

        const precision = LocaleUtils.fractionalPartLength(amountNumber)
        root.text = LocaleUtils.numberToLocaleString(amountNumber, precision, root.locale)
    }

    onTextChanged: d.validate()
    onValidateMaximumAmountChanged: d.validate()
    onMaximumAmountChanged: d.validate()
    onMultiplierIndexChanged: d.validate()

    QtObject {
        id: d

        property string amount: "0"
        property int multiplierIndex: 0

        function getEffectiveDigitsCount(str) {
            const digits = LocaleUtils.getLocalizedDigitsCount(text, root.locale)
            return str.startsWith(root.locale.decimalPoint) ? digits + 1 : digits
        }

        function validate() {
            if (!root.allowDecimals)
                root.text = root.text.replace(root.locale.decimalPoint, "")

            if (root.text.length === 0) {
                d.amount = "0"
                root.validationError = ""
                return
            }

            const amountNumber = LocaleUtils.numberFromLocaleString(root.text, root.locale)
            if (isNaN(amountNumber)) {
                d.amount = "0"
                root.validationError = qsTr("Invalid amount format")
                return
            }

            const fractionalPartLength = LocaleUtils.fractionalPartLength(amountNumber)
            if (fractionalPartLength > root.tokenDecimals) {
                d.amount = "0"
                root.validationError = qsTr("Max %n decimal place(s) for this asset", "", root.tokenDecimals)
                return
            }

            if (!root.allowZero && amountNumber === 0) {
                d.amount = "0"
                root.validationError = qsTr("Amount must be greater than 0")
                return
            }

            const amount = SQUtils.AmountsArithmetic.fromNumber(amountNumber, d.multiplierIndex)

            if (root.validateMaximumAmount && root.maximumAmount && root.maximumAmount.length > 0) {
                const maximumAmount = SQUtils.AmountsArithmetic.fromString(root.maximumAmount)
                const maxExceeded = SQUtils.AmountsArithmetic.cmp(amount, maximumAmount) === 1

                if (maxExceeded) {
                    root.validationError = root.maximumExceededErrorText
                    return
                }
            }

            // Fallback to handle float amounts for permissions
            // As a target amount should be always integer number
            if (!Number.isInteger(amountNumber) && d.multiplierIndex === 0) {
                d.amount = amount.toString()
            } else {
                d.amount = amount.toFixed(0)
            }

            root.validationError = ""
        }
    }

    validator: DoubleValidator {
        decimals: root.allowDecimals ? 100 : 0
        bottom: 0
        notation: DoubleValidator.StandardNotation
        locale: root.locale.name.split("_")[0]  // For whatever reason, this doesn't work properly when being
                                                // passed "language_country". We pass only the language part.
    }

    StatusBaseText {
        id: labelText

        parent: root.textField

        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("Amount")
        font.pixelSize: Theme.additionalTextSize
        color: Theme.palette.baseColor1
    }
}
