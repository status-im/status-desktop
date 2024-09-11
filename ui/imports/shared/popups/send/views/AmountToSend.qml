import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Validators 0.1

import utils 1.0
import shared.controls 1.0

Control {
    id: root

    /* Crypto value in a base unit as a string integer, e.g. 1000000000000000000
     * for 1 ETH */
    readonly property alias amount: d.amountBaseUnit

    /* In fiat mode the input value is meant to be a fiat value, conversely,
     * crypto value otherwise. */
    readonly property alias fiatMode: d.fiatMode

    /* Indicates whether toggling the fiatMode is enabled for the user */
    property bool fiatInputInteractive: interactive

    /* Indicates if input represent valid number. E.g. empty input or containing
     * only decimal point is not valid. */
    readonly property alias valid: textField.acceptableInput
    readonly property bool empty: textField.length === 0

    // TODO: remove, temporarily for backward compatibility. External components
    // should not rely on formatted amount because formatting rules are internal
    // detail of that component.
    readonly property alias text: textField.text

    /* Decimal point character to be displayed. Both "." and "," will be
     * replaced by the provided decimal point on the fly */
    property alias decimalPoint: validator.decimalPoint

    /* Number of fiat decimal places used to limit allowed decimal places in
     * fiatMode */
    property int fiatDecimalPlaces: 2

    /* Specifies how divisible given cryptocurrency is, e.g. 18 for ETH. Used
     * for limiting allowed decimal places and computing final amount as an
     * integer value */
    property int multiplierIndex: 18

    /* Price of one unit of given cryptocurrency (e.g. price for 1 ETH) */
    property real price: 1.0

    property alias caption: captionText.text
    property bool interactive: true

    readonly property bool cursorVisible: textField.cursorVisible
    readonly property alias placeholderText: textField.placeholderText

    /* Loading states for the input and text below */
    property bool mainInputLoading
    property bool bottomTextLoading

    /* Allows mark input as invalid when it's valid number but doesn't satisfy
     * arbitrary external criteria, e.g. is higher than maximum expected value. */
    property bool markAsInvalid: false

    /* Methods for formatting crypto and fiat value expecting double values,
       e.g. 1.0 for 1 ETH or 1.0 for 1 USD. */
    property var formatFiat: balance =>
                             `${balance.toLocaleString(Qt.locale())} FIAT`
    property var formatBalance: balance =>
                                `${balance.toLocaleString(Qt.locale())} CRYPTO`

    /* Allows to set value to be displayed. The value is expected to be a not
       localized string like "1", "1.1" or "0.000000023400234222". Provided
       value will be formatted and displayed. Depending on the fiatMode flag
       it will affect output amount appropriately. */
    function setValue(valueString) {
        if (!valueString)
            valueString = "0"

        const decimalPlaces = d.fiatMode ? root.fiatDecimalPlaces
                                         : root.multiplierIndex

        const stringNumber = SQUtils.AmountsArithmetic.fromString(
                               valueString).toFixed(decimalPlaces)

        const trimmed = d.fiatMode
                      ? stringNumber
                      : d.removeDecimalTrailingZeros(stringNumber)

        textField.text = d.localize(trimmed)
    }

    function clear() {
        textField.clear()
    }

    function forceActiveFocus() {
        textField.forceActiveFocus()
    }

    QtObject {
        id: d

        property bool fiatMode: false

        readonly property string inputDelocalized:
            root.valid && textField.length !== 0
                ? textField.text.replace(root.decimalPoint, ".") : "0"

        function removeDecimalTrailingZeros(num) {
            if (!num.includes("."))
                return num

            return num.replace(/\.?0*$/g, "")
        }

        function localize(num) {
            return num.replace(".", root.decimalPoint)
        }

        readonly property string amountBaseUnit: {
            if (d.fiatMode)
                return secondaryValue

            const multiplier = SQUtils.AmountsArithmetic.fromExponent(
                                 root.multiplierIndex)

            return SQUtils.AmountsArithmetic.times(
                        SQUtils.AmountsArithmetic.fromString(inputDelocalized),
                        multiplier).toFixed()
        }

        readonly property string secondaryValue: {
            const price = isNaN(root.price) ? 0 : root.price

            if (!d.fiatMode)
                return SQUtils.AmountsArithmetic.times(
                            SQUtils.AmountsArithmetic.fromString(inputDelocalized),
                            SQUtils.AmountsArithmetic.fromNumber(
                                price * (10 ** root.fiatDecimalPlaces))).toFixed()

            if (!price) // prevent div by zero below
                return 0

            const multiplier = SQUtils.AmountsArithmetic.fromExponent(
                                 root.multiplierIndex)

            return SQUtils.AmountsArithmetic.div(
                        SQUtils.AmountsArithmetic.times(
                            SQUtils.AmountsArithmetic.fromString(inputDelocalized),
                            multiplier),
                        SQUtils.AmountsArithmetic.fromNumber(price)).toFixed()
        }
    }

    contentItem: ColumnLayout {
        StatusBaseText {
            id: captionText

            Layout.fillWidth: true

            visible: text.length > 0

            font.pixelSize: 13
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.directColor1
            elide: Text.ElideRight
        }

        RowLayout {
            StatusTextField {
                id: textField

                objectName: "amountToSend_textField"

                Layout.fillWidth: true

                implicitHeight: 44
                padding: 0
                background: null

                readOnly: !root.interactive

                color: text.length === 0 || (root.valid && !root.markAsInvalid)
                       ? Theme.palette.directColor1
                       : Theme.palette.dangerColor1

                placeholderText: {
                    if (!d.fiatMode || root.fiatDecimalPlaces === 0)
                        return "0"

                    return "0" + root.decimalPoint
                            + "0".repeat(root.fiatDecimalPlaces)
                }

                font.pixelSize: Utils.getFontSizeBasedOnLetterCount(text)

                validator: AmountValidator {
                    id: validator

                    maxDecimalDigits: d.fiatMode ? root.fiatDecimalPlaces
                                                 : root.multiplierIndex
                    locale: root.locale.name
                }
                visible: !root.mainInputLoading
            }
            LoadingComponent {
                objectName: "topAmountToSendInputLoadingComponent"
                Layout.preferredWidth: textField.width
                Layout.preferredHeight: textField.height
                visible: root.mainInputLoading
            }
        }

        StatusBaseText {
            id: bottomItem

            objectName: "bottomItemText"

            Layout.fillWidth: true

            text: {
                const divisor = SQUtils.AmountsArithmetic.fromExponent(
                                  d.fiatMode ? root.multiplierIndex
                                             : root.fiatDecimalPlaces)
                const divided = SQUtils.AmountsArithmetic.div(
                                  SQUtils.AmountsArithmetic.fromString(
                                      d.secondaryValue), divisor)
                const asNumber = SQUtils.AmountsArithmetic.toNumber(divided)

                return d.fiatMode ? root.formatBalance(asNumber)
                                  : root.formatFiat(asNumber)
            }

            elide: Text.ElideMiddle
            font.pixelSize: 13
            color: Theme.palette.directColor5

            MouseArea {
                objectName: "amountToSend_mouseArea"

                anchors.fill: parent
                cursorShape: enabled ? Qt.PointingHandCursor : undefined
                enabled: root.fiatInputInteractive

                onClicked: {
                    const secondaryValue = d.secondaryValue

                    d.fiatMode = !d.fiatMode

                    if (textField.length === 0)
                        return

                    const decimalPlaces = d.fiatMode ? root.fiatDecimalPlaces
                                                     : root.multiplierIndex
                    const divisor = SQUtils.AmountsArithmetic.fromExponent(
                                      decimalPlaces)

                    const stringNumber = SQUtils.AmountsArithmetic.div(
                        SQUtils.AmountsArithmetic.fromString(secondaryValue),
                        divisor).toFixed(decimalPlaces)

                    const trimmed = d.fiatMode
                                  ? stringNumber
                                  : d.removeDecimalTrailingZeros(stringNumber)

                    textField.text = d.localize(trimmed)
                }
            }
            visible: !root.bottomTextLoading
        }

        LoadingComponent {
            objectName: "bottomItemTextLoadingComponent"
            Layout.preferredWidth: bottomItem.width
            Layout.preferredHeight: bottomItem.height
            visible: root.bottomTextLoading
        }
    }
}
